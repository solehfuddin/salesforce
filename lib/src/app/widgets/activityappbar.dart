import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class ActivityAppbar extends StatefulWidget implements PreferredSizeWidget {
  bool? isHorizontal = false;
  Function(String)? onTitleChange;

  ActivityAppbar({this.isHorizontal, this.onTitleChange});

  @override
  State<ActivityAppbar> createState() => _ActivityAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(isHorizontal! ? 370.h : 250.h);
}

class _ActivityAppbarState extends State<ActivityAppbar> {
  TextEditingController controllerTitle = new TextEditingController();
  String title = "Kunjungan Sales";

  @override
  initState() {
    super.initState();
    controllerTitle.text = title;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return activityAppbar(isHorizontal: true);
      }

      return activityAppbar(isHorizontal: false);
    });
  }

  Widget activityAppbar({bool isHorizontal = false}) {
    return Container(
      width: double.infinity.w,
      height: isHorizontal ? 350.h : 250.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 30.r),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: isHorizontal ? 25.r : 15.r,
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(CircleBorder()),
                    padding: MaterialStateProperty.all(EdgeInsets.all(8.r)),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.r),
                child: Text(
                  'Rincian Aktivitas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isHorizontal ? 28.sp : 18.sp,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: false,
                child: Padding(
                  padding: EdgeInsets.only(top: 30.r),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.delete_sharp,
                      size: isHorizontal ? 28.r : 18.r,
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(CircleBorder()),
                      padding: MaterialStateProperty.all(EdgeInsets.all(8.r)),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 25.h : 15.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Agenda',
                      style: TextStyle(
                        fontSize: isHorizontal ? 35.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: 8.w,
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return dialogAgenda(
                                isHorizontal: isHorizontal,
                              );
                            }).then((_) => setState(() {
                              title = controllerTitle.text;
                              widget.onTitleChange!(title);
                            }));
                      },
                      child: Ink(
                        color: Colors.grey,
                        child: Container(
                          padding: EdgeInsets.all(7.h),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white12,
                          ),
                          child: Icon(
                            Icons.mode_edit_rounded,
                            size: isHorizontal ? 25.r : 14.r,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 3.h,
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isHorizontal ? 35.sp : 18.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 25.h,
                ),
              ],
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg_task.png'),
          fit: isHorizontal ? BoxFit.cover : BoxFit.fill,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }

  Widget dialogAgenda({bool isHorizontal = false}) {
    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        scrollable: true,
        title: Text('Agenda'),
        content: Container(
          height: isHorizontal ? 190.h : 150.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 350.w,
                padding: EdgeInsets.symmetric(
                  horizontal: 5.r,
                  vertical: 10.r,
                ),
                color: Colors.white,
                height: 80.h,
                child: TextFormField(
                  autocorrect: true,
                  decoration: InputDecoration(
                    hintText: 'Masukkan agenda',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white70,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 3.r,
                      horizontal: 10.r,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
                      borderSide: BorderSide(color: Colors.grey, width: 2.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0.r)),
                      borderSide: BorderSide(color: Colors.blue, width: 2.r),
                    ),
                  ),
                  controller: controllerTitle,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.r,
                  vertical: 5.r,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text("Simpan"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
