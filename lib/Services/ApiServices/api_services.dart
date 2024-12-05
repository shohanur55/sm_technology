import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sm_technology/model/api_model/jsonPlacerListResponseModel.dart';

import '../../model/api_model/weather_data_current_model.dart';
import '../../model/api_model/weather_data_daily_model.dart';
import '../../model/api_model/weather_data_hourly_model.dart';
import '../../model/api_model/weather_data_model.dart';
import 'http_call.dart';

class Detect {
  String? token;
  final HttpCall _httpCall = HttpCall();

  // Future<List<GetCompanies>> getCompanies() async {
  //   String httpLink = "/api/Companies";
  //
  //   http.Response res = await _httpCall.get(httpLink, token: token ?? "");
  //   if (res.statusCode == 200) {
  //     var metaData = jsonDecode(res.body) as List;
  //     return metaData.map((company) => GetCompanies.fromJson(company)).toList();
  //   }
  //   throw res.statusCode;
  // }
//
  Future<List<JsonPlacerListModel>> getJsonPlacerList() async {
    String httpLink = "https://jsonplaceholder.typicode.com/posts";

    http.Response res = await _httpCall.get(httpLink, token: token ?? "");
    if (res.statusCode == 200) {
      var metaData = jsonDecode(res.body) as List;
      return metaData
          .map((company) => JsonPlacerListModel.fromJson(company))
          .toList();
    }
    throw res.statusCode;
  }

  Future<WeatherDataModel> getWeatherData(var lat, var lon) async {
   // var apiKey = "834309a4b5e7014844664b27df92edcd";
    var apiKey = "64cf32e7d7abc7be01f2fcf07717352f";
    String httpLink =
        "https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&appid=$apiKey&units=metric&exclude=minutely";
    WeatherDataModel? weatherData;
    http.Response res = await _httpCall.get(httpLink, token: token ?? "");
    if (res.statusCode == 200) {
      var metaData = jsonDecode(res.body);
      weatherData = WeatherDataModel(
          WeatherDataCurrentModel.fromJson(metaData),
          WeatherDataHourlyModel.fromJson(metaData),
          WeatherDataDailyModel.fromJson(metaData));
    }
    return weatherData!;
  }
}
