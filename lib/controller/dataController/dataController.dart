import 'package:connection_notifier/connection_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sm_technology/model/api_model/weather_data_model.dart';
import 'package:tuple/tuple.dart';

import '../../Services/ApiServices/api_services.dart';
import '../../Services/handle_error/error_handler.dart';
import '../../model/api_model/jsonPlacerListResponseModel.dart';

class DataController extends GetxController {
  late final Detect _apiServices;

   RxBool isConnected = false.obs;

  //! ---------------------------------------------------------------------------------------------- Error Handler
  Future<bool> _errorHandler(
      {showError = true, required Future Function() function}) async {
    Tuple2<ErrorType, Object?> res = await ErrorHandler.errorHandler(
      showError: showError,
      function: () async => await function(),
    );
    return res.item1 == ErrorType.done;
  }



  Future<void> initApp() async {

    WidgetsFlutterBinding.ensureInitialized();
    _apiServices = Detect();
    await _networkConnectivity();

  }

  Future<void> _networkConnectivity() async {
    await ConnectionNotifierTools.initialize();
    isConnected.value = ConnectionNotifierTools.isConnected;

    ConnectionNotifierTools.onStatusChange.listen((event) async {
      isConnected.value = event;
    });
  }

  Future<List<JsonPlacerListModel>> getJsonPlacerList() async {
    List<JsonPlacerListModel> res = [];
    await _errorHandler(
        function: () async => res = await _apiServices.getJsonPlacerList());
    return res;
  }

  Future<WeatherDataModel> getWeatherData(var lat, var lon) async {
    WeatherDataModel? res;
    await _errorHandler(
        function: () async => res = await _apiServices.getWeatherData(lat, lon));
    return res!;
  }
}
