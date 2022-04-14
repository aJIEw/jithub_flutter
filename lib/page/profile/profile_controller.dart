import 'package:jithub_flutter/core/base/base_controller.dart';
import 'package:jithub_flutter/core/http/http_client.dart';

class ProfileController extends BaseController {
  @override
  Future loadData() async {
    var response = await HttpClient.get('/user');

    if (response.ok) {
    } else {
      onRequestError(response);
      return Future.error(response.error?.message ?? '');
    }
  }
}
