import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sample/src/app/pages/training/trainer_list.dart';

import '../../../domain/entities/trainer.dart';
import '../../controllers/marketingexpense_controller.dart';
import '../../widgets/custompagesearch.dart';

class TrainingAppointment extends StatefulWidget {
  const TrainingAppointment({Key? key}) : super(key: key);

  @override
  State<TrainingAppointment> createState() => _TrainingAppointmentState();
}

class _TrainingAppointmentState extends State<TrainingAppointment> {
  MarketingExpenseController meController =
      Get.find<MarketingExpenseController>();

  TextEditingController txtSearch = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  handleSearch(
    dynamic returnVal, {
    int limitVal = 5,
    int offsetVal = 0,
    int pageVal = 1,
  }) {
    setState(() {
     
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      if (constraint.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childWidget(isHorizontal: true);
      }

      return childWidget(isHorizontal: false);
    });
  }

  Widget childWidget({bool isHorizontal = false}) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FutureBuilder(
            future:
                meController.getAllTrainer(mounted, context, key: txtSearch.text),
            builder: (context, AsyncSnapshot<List<Trainer>> snapshot) {
              if (snapshot.hasData && snapshot.data!.length > 0) {
                return CustomPageSearch(
                  isHorizontal: isHorizontal,
                  showControl: false,
                  totalItem: 5,
                  limit: 5,
                  page: 1,
                  totalPage: 2,
                  setColor: Colors.white,
                  hintText: "Pencarian trainer ...",
                  txtSearch: txtSearch,
                  handleSearch: handleSearch,
                );
              } else {
                return SizedBox(
                  width: 10.w,
                );
              }
            },
          ),
          Flexible(
            child: FutureBuilder(
              future: meController.getAllTrainer(mounted, context,
                  key: txtSearch.text),
              builder: (context, AsyncSnapshot<List<Trainer>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data!.length > 0) {
                    return RefreshIndicator(
                      child: TrainerList(
                        list: snapshot.data,
                      ),
                      onRefresh: _refreshData,
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/not_found.png',
                            width: isHorizontal ? 150.w : 200.w,
                            height: isHorizontal ? 150.h : 200.h,
                          ),
                        ),
                        Text(
                          'Data tidak ditemukan',
                          style: TextStyle(
                            fontSize: isHorizontal ? 14.sp : 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[600],
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    );
                  }
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
