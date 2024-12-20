import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:sm_technology/view/dashboard_wrapper_screen.dart';

import 'controller/dataController/dataController.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(//for resposnsive design
      fontSizeResolver: (fontSize, instance) => fontSize.toDouble(),
      designSize: Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      builder: (context, child) => GetMaterialApp(
        title: "SM technology",
        initialBinding: InitialBinding(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: {//for comfortable with mouse and touch
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
        }),
        home: child,
      ),
      child:  DashboardWrapperScreen(),
    );
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DataController());
  }
}
