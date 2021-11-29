import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef OnViewModelCreated<T> = void Function(T t);

/// Stateful widgets that listen for state change based on Provider
class ProviderWidget<T extends ChangeNotifier> extends StatefulWidget {
  final T viewModel;
  final Widget Function(BuildContext context, T viewModel, Widget? child)
      builder;
  final OnViewModelCreated<T>? onViewModelCreated;
  final Widget? child;

  const ProviderWidget({
    Key? key,
    required this.viewModel,
    required this.builder,
    this.onViewModelCreated,
    this.child,
  }) : super(key: key);

  @override
  ProviderWidgetState<T> createState() => ProviderWidgetState<T>();
}

class ProviderWidgetState<T extends ChangeNotifier>
    extends State<ProviderWidget<T>> {
  late T viewModel;

  @override
  void initState() {
    viewModel = widget.viewModel;
    if (widget.onViewModelCreated != null) {
      widget.onViewModelCreated!(viewModel);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => viewModel,
      child: Consumer<T>(
        builder: widget.builder,
        child: widget.child,
      ),
    );
  }
}

class ProviderWidget2<A extends ChangeNotifier, B extends ChangeNotifier>
    extends StatefulWidget {
  final A viewModelA;
  final B viewModelB;
  final Widget Function(
      BuildContext context, A viewModelA, B viewModelB, Widget? child) builder;
  final Function(A, B)? onViewModelCreated;
  final Widget? child;

  const ProviderWidget2({
    Key? key,
    required this.viewModelA,
    required this.viewModelB,
    required this.builder,
    this.onViewModelCreated,
    this.child,
  }) : super(key: key);

  @override
  _ProviderWidgetState2<A, B> createState() => _ProviderWidgetState2<A, B>();
}

class _ProviderWidgetState2<A extends ChangeNotifier, B extends ChangeNotifier>
    extends State<ProviderWidget2<A, B>> {
  late A viewModelA;
  late B viewModelB;

  @override
  void initState() {
    viewModelA = widget.viewModelA;
    viewModelB = widget.viewModelB;

    if (widget.onViewModelCreated != null) {
      widget.onViewModelCreated!(viewModelA, viewModelB);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<A>(
            create: (context) => viewModelA,
          ),
          ChangeNotifierProvider<B>(
            create: (context) => viewModelB,
          )
        ],
        child: Consumer2<A, B>(
          builder: widget.builder,
          child: widget.child,
        ));
  }
}
