import 'dart:async';

import 'package:event_bus/event_bus.dart';

class EventObject {}

// 封装 EventBus 的工具类
class XEvent {
  XEvent._internal();

  static Map<String, EventBus> sEventPool = {};

  static Map<String, List<StreamSubscription>> sStreamPool = {};

  static EventBus getEvent(String eventName, {bool isSync = false}) {
    EventBus? event = sEventPool[eventName];
    if (event == null) {
      event = EventBus(sync: isSync);
      sEventPool[eventName] = event;
    }
    return event;
  }

  /// 订阅信息，默认是异步的
  static StreamSubscription<T> on<T>(
    String eventName,
    void Function(T event) onData, {
    bool isSync = false,
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final StreamSubscription<T> stream = getEvent(eventName, isSync: isSync)
        .on<T>()
        .listen(
          onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );

    List<StreamSubscription>? streams = sStreamPool[eventName];
    if (streams == null) {
      streams = [];
      streams.add(stream);
      sStreamPool[eventName] = streams;
    } else {
      streams.add(stream);
    }
    return stream;
  }

  /// 发送事件
  static void post(String eventName, event) {
    final EventBus eventBus = getEvent(eventName);
    eventBus.fire(event);
  }

  /// 取消订阅
  static void cancel(String eventName, StreamSubscription? subscription) {
    if (subscription == null) return;
    final List<StreamSubscription>? streams = sStreamPool[eventName];
    if (streams != null) {
      subscription.cancel();
      streams.remove(subscription);
    }
  }

  /// 取消全部订阅
  static void cancelAll(String eventName) {
    final List<StreamSubscription>? streams = sStreamPool[eventName];
    if (streams != null) {
      for (final StreamSubscription item in streams) {
        item.cancel();
      }
      streams.clear();
    }
  }
}
