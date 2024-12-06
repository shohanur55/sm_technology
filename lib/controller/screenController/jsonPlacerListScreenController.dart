import 'package:get/get.dart';
import 'package:sm_technology/Services/user_message/devMode.dart';
import 'package:sm_technology/model/api_model/jsonPlacerListResponseModel.dart';

import '../../Services/local_database/databaseHelper.dart';
import '../dataController/dataController.dart';

class JsonPlacerListScreenController extends GetxController {
  DataController controller = DataController();

  @override
  void onInit() {
    // TODO: implement onInit

    super.onInit();
    controller.initApp();
     getJsonDataList();

  }

  DatabaseHelper dbHelper = DatabaseHelper();

  final Rxn<List<JsonPlacerListModel>> response =
      Rxn<List<JsonPlacerListModel>>();
  RxBool isLoading = false.obs;

 Future<void> getJsonDataList() async {
    isLoading.value = true;

    DevMode.devPrint("is have internet =   ${controller.isConnected.value}");

    if (controller.isConnected.value) {
      response.value = await controller.getJsonPlacerList();
      print("response =${response.value.toString()}");
    } else {
      response.value = await dbHelper.getJsonPlacerLocalDatabaseData();
    }

    isLoading.value = false;

    if (controller.isConnected.value) saveDataLocal();
    DevMode.devPrint("is have internet =   ${controller.isConnected.value}");
  }

  //FOR SAVE DATA INTO LOCAL DATABASE---------------------------
  Future<void> saveDataLocal() async {

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
  }
}
