import 'package:get/get.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
// import 'package:sample/src/app/pages/customer/customer_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/pages/intro/intro_view.dart';
import 'package:sample/src/app/pages/login/login_view.dart';
import 'package:sample/src/app/pages/maintenance/maintenance_view.dart';
import 'package:sample/src/app/pages/marketingexpense/marketingexpense_form.dart';
import 'package:sample/src/app/pages/marketingexpense/marketingexpense_formtrainer.dart';
import 'package:sample/src/app/pages/marketingexpense/marketingexpense_screen.dart';
import 'package:sample/src/app/pages/staff/staff_view.dart';
import 'package:sample/src/app/pages/training/tab_training.dart';
import 'package:sample/src/app/pages/training/trainer_profile.dart';

import '../pages/trainer/trainer_view.dart';

class RoutingPage {
  List<GetPage<dynamic>>? pages = [
    GetPage(
      name: '/',
      page: () => IntroPage(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(
        seconds: 2,
      ),
    ),
    GetPage(
      name: '/login/',
      page: () => Login(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(
        milliseconds: 1500,
      ),
    ),
    GetPage(
      name: '/maintenance/',
      page: () => MaintenanceScreen(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(
        milliseconds: 1500,
      ),
    ),
    GetPage(
      name: '/admin/',
      page: () => AdminScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(
        milliseconds: 1500,
      ),
    ),
    GetPage(
      name: '/home/',
      page: () => HomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(
        milliseconds: 1500,
      ),
    ),
    GetPage(
      name: '/staff/',
      page: () => StaffScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(
        milliseconds: 1500,
      ),
    ),
    // GetPage(
    //   name: '/customer/:idOuter',
    //   page: () => CustomerScreen(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: Duration(
    //     milliseconds: 1500,
    //   ),
    // ),
    GetPage(
      name: '/marketingexpense/',
      page: () => Marketingexpense_Screen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(
        milliseconds: 1500,
      ),
    ),
    GetPage(
      name: '/marketingexpenseform/',
      page: () => Marketingexpense_Form(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(
        milliseconds: 1500,
      ),
    ),
    GetPage(
      name: '/marketingexpenseformtrainer/',
      page: () => Marketingexpense_Formtrainer(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(
        milliseconds: 1500,
      ),
    ),
    GetPage(
      name: '/tabTraining/',
      page: () => TabTraining(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(
        milliseconds: 1500,
      ),
    ),
    GetPage(
      name: '/trainerProfile/',
      page: () => TrainerProfile(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(
        milliseconds: 800,
      ),
    ),
    GetPage(
      name: '/trainerScreen/',
      page: () => TrainerScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(
        milliseconds: 800,
      ),
    ),
  ];
}
