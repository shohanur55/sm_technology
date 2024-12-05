import 'package:flutter/foundation.dart';

class DevMode{

   static void devPrint(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}