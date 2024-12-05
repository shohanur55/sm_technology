import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:sm_technology/Services/user_message/devMode.dart';
import 'package:sm_technology/controller/screenController/jsonPlacerListScreenController.dart';
import 'package:sm_technology/view/screens/listViewPart/jsonPlacceListScreen.dart';
import 'package:sm_technology/view/screens/weather_part/weather_screen.dart';

import '../../Services/local_database/databaseHelper.dart';
import '../../Services/user_message/snackbar.dart';
import '../../component.dart';
import '../../model/api_model/jsonPlacerListResponseModel.dart';
import '../../model/api_model/weather_data_model.dart';
import '../../model/app_model/page_model.dart';
import '../dataController/dataController.dart';

class DashboardWrapperScreenController extends GetxController {
  DataController controller=DataController();
  @override
  void onInit() {
    // TODO: implement onInit

    super.onInit();
    controller.initApp();

    if (_isLoading.isTrue) {
      getLocation();
    } else {
      getIndex();
    }

  }




  // create various variables
  final RxBool _isLoading = true.obs;
  final RxDouble _lattitude = 0.0.obs;
  final RxDouble _longitude = 0.0.obs;
  final RxInt _currentIndex = 0.obs;

  // instance for them to be called
  RxBool checkLoading() => _isLoading;
  RxDouble getLattitude() => _lattitude;
  RxDouble getLongitude() => _longitude;

  //final weatherData = WeatherData().obs;
  final Rx<WeatherDataModel?> weatherData = Rx<WeatherDataModel?>(null);

  Future<void> getData() async{
    DatabaseHelper dbHelper = DatabaseHelper();
   weatherData.value=await controller.getWeatherData(_lattitude.value, _longitude.value);
    _isLoading.value=false;
    if (controller.isConnected.value) saveDataLocal();
  }



  Future<void> getLocation() async {
    bool isServiceEnabled;
    LocationPermission locationPermission;

    // Check if location services are enabled
    isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      return Future.error("Location not enabled");
    }

    // Check and request permissions
    locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.deniedForever) {
      return Future.error("Location permission denied forever");
    } else if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        return Future.error("Location permission is denied");
      }
    }

    // Get the current position
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Update latitude and longitude
    _lattitude.value = position.latitude;
    _longitude.value = position.longitude;

    // Fetch weather data after successfully getting location
    if (position.latitude != 0.0 && position.longitude != 0.0)
      {
        await getData();
      }

  }

  RxInt getIndex() {
    return _currentIndex;
  }


  Future<void> saveDataLocal() async {
    DevMode.devPrint("save data local called-----------------------------------------------------------------------------------------------------------------");
    final List<JsonPlacerListModel>? jsonList =
    await controller.getJsonPlacerList();

    if (jsonList == null ||jsonList.isEmpty) {
      DevMode.devPrint("No data found to save.");
      return;
    }

    DatabaseHelper dbHelper = DatabaseHelper();

    int col = await dbHelper.deleteLocalData();
    DevMode.devPrint("Delete ${col} of database successfylly");

    for (JsonPlacerListModel jsonModel in jsonList) {
      await dbHelper.insertJsonPlacerList(jsonModel);
    }

    DevMode.devPrint("Data saved to local database successfully.");

    final WeatherDataModel jsonModel = await controller.getWeatherData(_lattitude.value, _longitude.value);

    if (jsonModel == null) {
      DevMode.devPrint("No data found to save.");
      return;
    }



    // Insert the single weather data model into the local database
    await dbHelper.insertWeatherData(jsonModel);

    DevMode.devPrint("Data saved to local database successfully.");
  }



  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController scrollController = ScrollController();
  final ScrollController calenderScroll = ScrollController();



  @override
  dispose() {
    scrollController.dispose();
    calenderScroll.dispose();
    super.dispose();
  }



  final RxInt currentPageIndex = 1.obs;
  final PageController pageController = PageController(initialPage: 1);

  final List<PageModel> bottomNavBarList = [
    PageModel(pageHeading: "ListView", svg: "assets/icons/listView.svg", page: JsonplacerListScreen()),
    PageModel(pageHeading: "Home", svg: "assets/icons/home_icon.svg", page: WeatherScreen()),
    PageModel(pageHeading: "ListView", svg: "assets/icons/listView.svg", page:  JsonplacerListScreen()),
  ];

  void changePage(int index) {
    currentPageIndex.value = index;

    if (pageController.hasClients) pageController.animateToPage(index, duration: Duration(milliseconds: defaultDuration.inMilliseconds ~/ 3), curve: Curves.easeInOut);
  }

}
