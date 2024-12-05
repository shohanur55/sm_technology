import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io' show Platform;



Future<void> showSnackBar({
  required String title,
  required String message,
  Widget? icon,
  SnackPosition snackPosition = SnackPosition.TOP,
  void Function(SnackbarStatus? status)? snackbarStatus,
  TextButton? mainButton,
  Duration duration = const Duration(seconds: 3),
  Duration? animationDuration,
  Completer<void>? completer,
  EdgeInsets? padding,
  EdgeInsets? margin,
}) async {
  final Completer<void> c = completer ?? Completer<void>();
  try {
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
  } catch (_) {}

  Get.snackbar(
    title,
    message,
    icon: icon,
    borderRadius: 24 / 2,
    padding: padding ?? EdgeInsets.all(24),
    margin: margin ?? EdgeInsets.all(24),
    snackPosition: snackPosition,
    snackbarStatus: (status) async {
      if (snackbarStatus != null) snackbarStatus(status);
      if (status == SnackbarStatus.CLOSED && !c.isCompleted) {
        await Future.delayed(const Duration(milliseconds: 100));
        c.complete();
      }
    },
    colorText: Get.theme.shadowColor,
    maxWidth: 400,
    backgroundColor: Get.theme.canvasColor.withOpacity(0.7),
    mainButton: mainButton,
    duration: duration,
    animationDuration: animationDuration,
  );

  await c.future;
}

Future<void> showToast({String? title, required String message}) async {
  bool isAndroid = Platform.isAndroid;
  bool isIOS = Platform.isIOS;
  bool isWeb = kIsWeb;

  if (isAndroid || isIOS || isWeb) {
    Fluttertoast.showToast(msg: "${title == null ? "" : "$title: "}$message");
  } else {
    showSnackBar(title: title ?? "", message: message);
  }
}

Future<bool> showConfirmationMessage({
  required String heading,
  required String message,
  Completer<void>? completer,
}) async {
  bool res = true;
  await showSnackBar(
    completer: completer,
    animationDuration: const Duration(milliseconds: 100),
    icon: const Icon(Icons.info),
    title: heading,
    message: message,
    snackPosition: SnackPosition.BOTTOM,
    padding: EdgeInsets.symmetric(
        horizontal: 24 / 2, vertical: 24),
    mainButton: TextButton(
      onPressed: () {
        res = false;
        Get.closeCurrentSnackbar();
      },
      child: const Text(
        "Undo",
        style: TextStyle(color: Colors.green),
      ),
    ),
  );

  return res;
}
