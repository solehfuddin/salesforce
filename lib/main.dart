// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:sample/src/app/controllers/contractpromo_controller.dart';
import 'package:sample/src/app/controllers/marketingexpense_controller.dart';
import 'package:sample/src/app/controllers/my_controller.dart';
import 'package:sample/src/app/controllers/posmaterial_controller.dart';
import 'package:sample/src/app/controllers/training_controller.dart';
import 'package:sample/src/app/navigator/routing.dart';
import 'package:sample/src/app/navigator/splash.dart';

void main() async {
  // await AndroidAlarmManager.initialize();
  
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(MyController());
  Get.put(MarketingExpenseController());
  Get.put(ContractPromoController());
  Get.put(TrainingController());
  Get.put(PosmaterialController());

  // await Permission.notification.request();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  // FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // localNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

  FlutterError.onError = (FlutterErrorDetails details) {
    print('Error : ${details.stack.toString()}');
  };

  await initializeDateFormatting('id_ID', null).then((_) => runApp(Test()));
}

// ignore: must_be_immutable
class Test extends StatelessWidget {
  RoutingPage routingPage = RoutingPage();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      designSize: const Size(
        360,
        690,
      ),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // return MaterialApp(
        //   home: SplashScreen(),
        //   debugShowCheckedModeBanner: false,
        // );
        return GetMaterialApp(
          home: SplashScreen(),
          initialRoute: '/',
          debugShowCheckedModeBanner: false,
          getPages: routingPage.pages,
        );
      },
    );
  }
}
