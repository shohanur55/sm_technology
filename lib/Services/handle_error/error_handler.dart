import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sm_technology/Services/handle_error/string_controller.dart';

import 'package:tuple/tuple.dart';


import 'app_exceptions.dart';



class ErrorHandler {
  // Handle Error
  static Future<Tuple2<ErrorType, Object?>> errorHandler({bool showError = true, required Function function}) async {
    try {
      await function();
      return const Tuple2(ErrorType.done, null);
    } on SocketException {
      if (kDebugMode) print("ErrorHandler: SocketException");
      if (showError) InternetException();
      return const Tuple2(ErrorType.internetException, null);
    } on TimeoutException {
      if (kDebugMode) print("ErrorHandler: TimeoutException");
      if (showError) RequestTimeOut();
      return const Tuple2(ErrorType.requestTimeOut, null);
    } on ServiceUnavailable {
      if (kDebugMode) print("ErrorHandler: ServiceUnavailableException");
      if (showError) ServiceUnavailable();
      return const Tuple2(ErrorType.serviceUnavailable, null);
    } catch (e) {
      if (e == 401) {
        if (kDebugMode) print("ErrorHandler: UnauthorizedException");
        if (showError) InvalidUser();
        return const Tuple2(ErrorType.invalidUser, null);
      } else {
        if (kDebugMode) print("ErrorHandler: ${cutString(e.toString())}");
        if (showError) InternalError(message: "Code: ${cutString(e.toString())}");
        return Tuple2(ErrorType.unknownError, e);
      }
    }
  }
}

enum ErrorType {
  done,
  internetException,
  requestTimeOut,
  invalidUser,
  serviceUnavailable,
  unknownError,
}
