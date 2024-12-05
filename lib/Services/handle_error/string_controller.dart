import 'package:flutter/services.dart';

import '../user_message/snackbar.dart';



String cutString(String input, {int maxLength = 100}) {
  if (input.length <= maxLength) {
    return input;
  } else {
    return "${input.substring(0, maxLength)}...";
  }
}

extension StringExtensions on String {
  Future<bool> get customCopyToClipboard async {
    try {
      await Clipboard.setData(ClipboardData(text: this));
      showToast(message: "Text copied", title: null);
      return true;
    } catch (e) {
      devPrint("customCopyToClipboard: $e");
      return false;
    }
  }

  
  void devPrint(String s) {}
}
