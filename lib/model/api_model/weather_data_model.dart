import 'package:sm_technology/model/api_model/weather_data_current_model.dart';
import 'package:sm_technology/model/api_model/weather_data_daily_model.dart';
import 'package:sm_technology/model/api_model/weather_data_hourly_model.dart';

class WeatherDataModel {
  final WeatherDataCurrentModel? current;
  final WeatherDataHourlyModel? hourly;
  final WeatherDataDailyModel? daily;

  WeatherDataModel(
      [
        this.current,
        this.hourly,
        this.daily
      ]
      );

  // function to fetch these values
  WeatherDataCurrentModel getCurrentWeather() => current!;
  WeatherDataHourlyModel getHourlyWeather() => hourly!;
  WeatherDataDailyModel getDailyWeather() => daily!;
}
