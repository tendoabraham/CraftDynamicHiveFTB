// ignore_for_file: must_be_immutable

import 'package:craft_dynamic/dynamic_widget.dart';
import 'package:craft_dynamic/src/util/local_data_util.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../../../craft_dynamic.dart';
import '../../state/plugin_state.dart';

class RequestStatusScreen extends StatefulWidget {
  RequestStatusScreen({Key? key, required this.postDynamic, this.moduleItem})
      : super(key: key);

  PostDynamic postDynamic;
  ModuleItem? moduleItem;

  @override
  State<RequestStatusScreen> createState() => _RequestStatusScreenState();
}

class _RequestStatusScreenState extends State<RequestStatusScreen>
    with SingleTickerProviderStateMixin {
  final _sharedPref = CommonSharedPref();
  StatusCode statusCode = StatusCode.success;
  late var _controller;

  @override
  void initState() {
    Vibration.vibrate(duration: 500);
    super.initState();
    statusCode = StatusCode.values.firstWhere(
        (statusCode) => statusCode.statusCode == widget.postDynamic.status);
    _isChangePinCheck();
    _checkAddBenefiary();
    _setUpAnimationController();
    _isChangeBankType();
  }

  _setUpAnimationController() {
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 5000), () {
          if (!mounted) {
            _controller.forward(from: 0.0);
          }
        });
      }
    });
  }

  _checkAddBenefiary() async {
    if (widget.moduleItem?.moduleId == ModuleId.ADDBENEFICIARY.name) {
      var beneficiaries = widget.postDynamic.beneficiaries;
      if (beneficiaries != null && beneficiaries.isNotEmpty) {
        LocalDataUtil.refreshBeneficiaries(beneficiaries);
      }
    }
  }

  _isChangePinCheck() async {
    if (widget.moduleItem?.moduleId == ModuleId.PIN.name) {
      await _sharedPref.setBio(false);
    }
  }

  _isChangeBankType() async {
    if (widget.postDynamic.status == changeBankType) {
      var bankID = widget.postDynamic.formID ?? "";
      await _sharedPref.setBankID(bankID.isEmpty ? null : bankID);
    }
  }

  @override
  Widget build(BuildContext context) {
    var message = widget.postDynamic.notifyText == null ||
            widget.postDynamic.notifyText == ""
        ? widget.postDynamic.message
        : widget.postDynamic.notifyText;

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark),
        child: WillPopScope(
            onWillPop: () async {
              closeOrLogout();
              return true;
            },
            child: Scaffold(
              body: Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 12),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color:
                                Theme.of(context).primaryColor.withOpacity(.1)),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                  onPressed: () {
                                    closeOrLogout();
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: APIService.appPrimaryColor,
                                    size: 34,
                                  )),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Column(
                              children: [
                                Lottie.asset(getAvatarType(statusCode),
                                    height: 88,
                                    width: 88,
                                    controller: _controller, onLoaded: (comp) {
                                  _controller
                                    ..duration = comp.duration
                                    ..forward();
                                }),
                                const SizedBox(
                                  height: 44,
                                ),
                                Center(
                                    child: Text(
                                  message ?? "Please try again later!",
                                  style: const TextStyle(
                                      fontSize: 14, height: 1.5),
                                  textAlign: TextAlign.center,
                                )),
                              ],
                            ),
                            const SizedBox(
                              height: 44,
                            ),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: WidgetFactory.buildButton(
                                    context, closeOrLogout, "Done".tr())),
                          ],
                        ))),
              ),
            )));
  }

  String getAvatarType(StatusCode statusCode) {
    switch (statusCode) {
      case StatusCode.success:
        return "packages/craft_dynamic/assets/lottie/success.json";

      case StatusCode.failure:
        return "packages/craft_dynamic/assets/lottie/error.json";
      case StatusCode.token:
        break;
      case StatusCode.changeLanguage:
        break;
      case StatusCode.changePin:
        break;
      case StatusCode.unknown:
        break;
      case StatusCode.otp:
        break;
    }
    return "packages/craft_dynamic/assets/lottie/information.json";
  }

  closeOrLogout() {
    widget.moduleItem != null && widget.moduleItem?.moduleId == "PIN" ||
            widget.moduleItem?.moduleId == ModuleId.LANGUAGEPREFERENCE.name ||
            widget.postDynamic.status == StatusCode.changeBankType.statusCode
        ? logout()
        : closePage();
  }

  void logout() {
    Hive.close();
    Widget? logoutScreen =
        Provider.of<PluginState>(context, listen: false).logoutScreen;
    if (logoutScreen != null) {
      CommonUtils.navigateToRouteAndPopAll(
          context: context, widget: logoutScreen);
    }
  }

  void closePage() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
