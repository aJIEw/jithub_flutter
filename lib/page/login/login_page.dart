import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '/core/base/provider_widget.dart';
import '/core/extension/input_decoration.dart';
import '/core/util/logger.dart';
import '/core/util/toast.dart';
import '/core/widget/loading/loading_dialog.dart';
import '/provider/provider.dart';
import '/provider/state/user_profile.dart';
import '/router/router.dart';
import '../../core/base/base_page.dart';
import '../../core/widget/button/countdown_button.dart';
import 'login_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String phoneNumber = '';
  bool showInputCode = false;

  @override
  Widget build(BuildContext context) {
    var topBgColor = Theme.of(context).primaryColor;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: BasePageWrapper(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: Container(
                width: double.infinity,
                alignment: Alignment.bottomCenter,
                color: topBgColor,
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: FlutterLogo(size: 50)),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('app_title'.tr,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              ?.apply(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Container(
                color: topBgColor,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.elliptical(20, 12),
                      topRight: Radius.elliptical(20, 12)),
                  child: PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 600),
                    reverse: phoneNumber.isEmpty,
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                    ) {
                      return SharedAxisTransition(
                        child: child,
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                      );
                    },
                    child: showInputCode
                        ? ContentInputCode(
                            phoneNumber: phoneNumber,
                            onGoBack: () => setState(() {
                              phoneNumber = '';
                              showInputCode = false;
                            }),
                          )
                        : ContentInputPhoneNumber(
                            onCodeSent: (phone) => setState(() {
                              phoneNumber = phone;
                              showInputCode = true;
                            }),
                          ),
                  ),
                ),
              ),
            ),
          ],
        )));
  }
}

class ContentInputPhoneNumber extends StatefulWidget {
  const ContentInputPhoneNumber({Key? key, required this.onCodeSent})
      : super(key: key);

  final Function onCodeSent;

  @override
  _ContentInputPhoneNumberState createState() =>
      _ContentInputPhoneNumberState();
}

class _ContentInputPhoneNumberState extends State<ContentInputPhoneNumber> {
  final _controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final _focusNextStep = FocusNode();

  String phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                Icons.phone_iphone,
                color: Colors.grey[700],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'phone_number'.tr,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        hintText: 'input_phone_number'.tr)
                    .addClearableIcon(phoneNumber, _clearText),
                onChanged: (text) {
                  setState(() {
                    phoneNumber = text;
                  });
                },
                onFieldSubmitted: (String text) {
                  FocusScope.of(context).requestFocus(_focusNextStep);
                },
                validator: _phoneNumberValidator,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 30),
            child: ProviderWidget<LoginViewModel>(
              viewModel: LoginViewModel(),
              builder: (BuildContext context, LoginViewModel viewModel,
                  Widget? child) {
                return ElevatedButton(
                  focusNode: _focusNextStep,
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0.2),
                      backgroundColor: MaterialStateProperty.all(
                          phoneNumber.isNotEmpty
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300]),
                      minimumSize: MaterialStateProperty.all(
                          const Size(double.infinity, 50)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ))),
                  onPressed: () {
                    onClickNext(viewModel);
                  },
                  child: Text(
                    'next_step'.tr,
                    style: Theme.of(context).textTheme.bodyText1?.merge(
                        const TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.only(bottom: 20),
              child: Text.rich(TextSpan(
                children: [
                  TextSpan(
                      text: _getPrivacyText(context),
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          XRouter.goWeb(
                              context,
                              'http://your.domain.com/term_agreement',
                              _getPrivacyText(context));
                        }),
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }

  String? _phoneNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'text_form_warning_input_phone_number'.tr;
    }

    var input = int.parse(value);
    if (input.toString().length < 8) {
      return 'text_form_warning_input_correct_number'.tr;
    }

    // valid
    return null;
  }

  _clearText() {
    setState(() {
      phoneNumber = '';
    });

    _controller.clear();
  }

  String _getPrivacyText(BuildContext context) {
    return 'login_app_privacy_agreement'.trParams({'app_name': 'app_title'.tr});
  }

  void onClickNext(LoginViewModel viewModel) {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).requestFocus(_focusNextStep);

      showLoadingDialog();

      viewModel.getSmsCodeRequest(phoneNumber).then((sendSuccess) {
        if (sendSuccess) {
          widget.onCodeSent(phoneNumber);
        } else {
          ToastUtils.toast('sms_failed_alert'.tr);
        }

        dismissLoadingDialog();
      });
    }
  }
}

class ContentInputCode extends StatefulWidget {
  const ContentInputCode({Key? key, required this.phoneNumber, this.onGoBack})
      : super(key: key);

  final String phoneNumber;

  final VoidCallback? onGoBack;

  @override
  _ContentInputCodeState createState() => _ContentInputCodeState();
}

class _ContentInputCodeState extends State<ContentInputCode> {
  String codeNumber = '';

  @override
  Widget build(BuildContext context) {
    return ProviderWidget<LoginViewModel>(
      viewModel: LoginViewModel(),
      builder: (BuildContext context, LoginViewModel viewModel, Widget? child) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('input_sms_code'.tr,
                  style: Theme.of(context).textTheme.headline6),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                    'sms_has_sent_to'
                        .trParams({"phone_number": widget.phoneNumber}),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        ?.apply(color: Colors.grey)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  textStyle: const TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.normal),
                  onChanged: (String value) {
                    codeNumber = value;
                  },
                  pinTheme: PinTheme(
                    fieldWidth: 45,
                    fieldHeight: 45,
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    borderWidth: 1,
                    inactiveColor: Colors.grey[300],
                    activeColor: Colors.black54,
                    selectedColor: Colors.black54,
                  ),
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  cursorColor: Colors.black54,
                  onCompleted: (String code) {
                    showLoadingDialog();

                    viewModel
                        .loginRequest(widget.phoneNumber, code)
                        .then((loginInfo) {
                      dismissLoadingDialog();

                      if (loginInfo == null) {
                        logger.e('empty login info');
                        ToastUtils.toast('message_data_error'.tr);
                        return;
                      }

                      var userProfile = Store.value<UserProfile>(context);
                      userProfile.initWithLoginInfo(loginInfo);

                      XRouter.navigate(
                          XRouter.homePage, ModalRoute.withName('/'));
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: CountdownButton(
                    seconds: 59,
                    finalText: 'sms_resend'.tr,
                    onPressed: () {
                      viewModel.getSmsCodeRequest(widget.phoneNumber);
                    }),
              ),
              TextButton(
                  onPressed: () {
                    if (kDebugMode && widget.onGoBack != null) {
                      widget.onGoBack!();
                    }
                  },
                  child: Text('sms_not_received'.tr,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w300,
                      )))
            ],
          ),
        );
      },
    );
  }
}
