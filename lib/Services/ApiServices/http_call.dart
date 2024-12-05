import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sm_technology/Services/user_message/snackbar.dart';


class HttpCall {
  String _cookie = "";
  final Map<String, String> _header = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };


  //! Catch Cookie
  Future<http.Response> __catchCookie(Function function) async {
    http.Response res = await function();
    if (res.headers['set-cookie'] != null) {
      _cookie = res.headers['set-cookie']!.split(';')[0].trim();
    }
    return res;
  }

//! Get
  Future<http.Response> get(String url,
      {String token = '',
      Map<String, String>? headerParameter,
      int? timeout,
      bool addCookie = false}) async {
    final Map<String, String> header = {};
    header.addAll(headerParameter ?? _header);

    if (token.isNotEmpty) {
      header.addAll({HttpHeaders.authorizationHeader: token});
    }
    if (addCookie) {
      header.addAll({'Cookie': _cookie});
    }

    String link =  url;

    if (kDebugMode) {
      print(
          "HttpCall: Requesting: Get------------------------------------------ $link");
      showToast(message: link);
      header.forEach((key, value) {
        if (kDebugMode) print("$key: $value");
      });
    }

    http.Response res = await __catchCookie(() async => await http
        .get(Uri.parse(link), headers: header)
        .timeout(const Duration(seconds: 4)));
    if (kDebugMode) {
      print(
          "HttpCall: Response: GET ------------------------------------------------------------ $link --- Status Code: ${res.statusCode} --- Data: ${res.body}");
    }

    return res;
  }

//! Post
  Future<http.Response> post(String url,
      {String token = '',
      Map<String, String>? headerParameter,
      Object? body,
      int? requestTimeout,

      bool addCookie = false,
      bool doEncode = true}) async {
    final Map<String, String> header = {};
    header.addAll(headerParameter ?? _header);

    if (token.isNotEmpty) {
      header.addAll({"Authorization": token});
    }

    if (addCookie) {
      header.addAll({'Cookie': _cookie});
    }

    String link = url;

    if (kDebugMode) {
      print(
          "HttpCall: Requesting: POST------------------------------------------ $link ---- $body");
    }

    http.Response res = await http.post(
      Uri.parse(link),
      headers: header,
      body:  body,
    );

    if (kDebugMode) {
      print(
          "HttpCall: Response: POST------------------------------------------- $link --- Status Code: ${res.statusCode} --- Data: ${res.body}");
    }
    return res;
  }

}
