import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:on_process_button_widget/on_process_button_widget.dart';
import 'package:sm_technology/view/widgets/alive.dart';
import 'package:sm_technology/view/widgets/size_builder.dart';
import 'package:sm_technology/view/widgets/svg.dart';

import '../component.dart';
import '../controller/screenController/dashboard_wrapper_screen_controller.dart';

class DashboardWrapperScreen extends StatefulWidget {
  const DashboardWrapperScreen({super.key});

  @override
  State<DashboardWrapperScreen> createState() => _DashboardWrapperScreenState();
}

class _DashboardWrapperScreenState extends State<DashboardWrapperScreen> {
  final DashboardWrapperScreenController _controller = Get.put(DashboardWrapperScreenController());




  @override
  void dispose() {
    super.dispose();
    Get.delete<DashboardWrapperScreenController>();
  }

  @override
  Widget build(BuildContext context) {
    return  PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;

          if (_controller.currentPageIndex.value == 1) SystemNavigator.pop();

          _controller.changePage(1);
          return;
        },
        child: Scaffold(
          key: _controller.scaffoldKey,
          extendBody: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _HomeButton(),
          bottomNavigationBar: _BottomNavBar(),
          body: SafeArea(
            bottom: false,
            child: Obx(
              () => Column(
                children: [
                 // CustomLinearProgressBar.small(show: _controller.isLoading.value),
              if (_controller.weatherData.value== null)Text("No data available"),
                  Expanded(
                    child: PageView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _controller.pageController,
                      itemCount: _controller.bottomNavBarList.length,
                      onPageChanged: (value) => _controller.currentPageIndex.value = value,
                      itemBuilder: (context, index) {
                        return CustomAlive(
                          child: _controller.bottomNavBarList.elementAt(index).page,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewPadding.bottom)
                ],
              ),
            ),
          ),
        ),

    );
  }
}

class _HomeButton extends StatelessWidget {
  _HomeButton();
  final DashboardWrapperScreenController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: defaultPadding / 6,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(Theme.of(context).buttonTheme.height),
      child: OnProcessButtonWidget(

        margin: EdgeInsets.all(defaultPadding / 12),
        height: Theme.of(context).buttonTheme.height+10,
        width: Theme.of(context).buttonTheme.height+10,
        borderRadius: BorderRadius.circular(Theme.of(context).buttonTheme.height),
        onDone: (_) => _controller.changePage(1),
        child: CustomSizeBuilder(

          child: CustomSVG(_controller.bottomNavBarList.elementAt(1).svg, color: Colors.white),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  _BottomNavBar();
  final DashboardWrapperScreenController _controller = Get.find();
  Color _setColor(BuildContext context, int index) => _controller.currentPageIndex.value == index ? Theme.of(context).colorScheme.shadow : Theme.of(context).colorScheme.onTertiaryFixed;

  @override
  Widget build(BuildContext context) {
    final updatedColorScheme = Theme.of(context).colorScheme.copyWith(
      onTertiaryFixedVariant: Colors.greenAccent.shade200,
    );
    return Container(
color: Colors.transparent,
      child: BottomAppBar(
        // shadowColor: Colors.transparent,
        // surfaceTintColor: Colors.transparent,
        color: updatedColorScheme.onTertiaryFixedVariant,
        padding: EdgeInsets.only(top: 10),
        notchMargin: defaultPadding / 4,
        clipBehavior: Clip.antiAlias,
        height: 50.sp,
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            for (int i = 0; i < _controller.bottomNavBarList.length; i++)
              if (i != 1)
                Obx(
                  () => Expanded(
                    child: InkWell(
                      onTap: () =>_controller.changePage(i) ,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomSizeBuilder(
                            constraints: BoxConstraints(maxHeight: defaultPadding / 1.5, maxWidth: defaultPadding / 1.5),
                            child: CustomSVG(_controller.bottomNavBarList.elementAt(i).svg, color: _setColor(context, i)),
                          ),
                          SizedBox(height: defaultPadding / 8),
                          Flexible(
                            child: FittedBox(
                              child: Text(_controller.bottomNavBarList.elementAt(i).pageHeading, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: _setColor(context, i))),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
          ],
        ),
      ),
    );
  }
}
