import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../component.dart';
import '../../../controller/screenController/dashboard_wrapper_screen_controller.dart';
import 'comfort_level_section.dart';
import 'current_weather_section.dart';
import 'daily_data_forecast_section.dart';
import 'header_section.dart';
import 'hourly_data_section.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // call
  final DashboardWrapperScreenController controller =
      Get.put(DashboardWrapperScreenController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
// backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {
      if (controller.checkLoading().isTrue) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/icons/clouds.png",
                height: 200,
                width: 200,
              ),
              const CircularProgressIndicator(),
            ],
          ),
        );
      }
      else if (controller.weatherData.value == null) {
        return Center(
          child: Text("No data  are available"),
        );
      }
      else {
        final weatherData = controller.weatherData.value!;
        return Center(
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              const SizedBox(
                height: 20,
              ),
              const HeaderWidget(),
              // for our current temp ('current')
              CurrentWeatherWidget(
                weatherDataCurrent:
                weatherData.getCurrentWeather(),
              ),
              const SizedBox(
                height: 20,
              ),
              HourlyDataWidget(
                  weatherDataHourly:
                  weatherData.getHourlyWeather()),
              DailyDataForecast(
                weatherDataDaily:
                weatherData.getDailyWeather(),
              ),
              Container(
                height: 1,
                color: CustomColors.dividerLine,
              ),
              const SizedBox(
                height: 10,
              ),
              ComfortLevel(
                  weatherDataCurrent:
                  weatherData.getCurrentWeather())
            ],
          ),
        );
      }
        }
        ),
      ),
    );
  }
}
