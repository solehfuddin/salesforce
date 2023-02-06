import 'package:flutter/material.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/utils/dbhelper.dart';
import 'package:sample/src/domain/entities/notifikasi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotifScreen extends StatefulWidget {
  const NotifScreen({Key? key}) : super(key: key);
  @override
  State<NotifScreen> createState() => _NotifScreenState();
}

class _NotifScreenState extends State<NotifScreen> {
  DbHelper dbHelper = DbHelper.instance;
  Future<List<Notifikasi>>? listNotif;
  List<Notifikasi> tempList = List.empty(growable: true);
  String? id = '';
  String? role = '';
  String? username = '';
  String? divisi = '';
  String? userUpper = '';

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      userUpper = username!.toUpperCase();
      divisi = preferences.getString("divisi");

      print('ID USER : $id');
      listNotif = getLocalData();
    });
  }

  void checkedRead(Notifikasi item) async {
    item.isRead = "1";
    int result = await dbHelper.update(item);
    if (result > 0) {
      getLocalData();
    }
  }

  Future<List<Notifikasi>> getLocalData() async {
    List<Notifikasi> lokalList = await dbHelper.getAllNotifikasi();
    if (lokalList.isNotEmpty) {
      tempList.addAll(lokalList);
    }

    lokalList.forEach((element) {
      print("Lokal data : ${element.judul}");
    });
   
    return lokalList;
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  Future<void> _refreshData() async {
    setState(() {
      listNotif = getLocalData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 700 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childNotif(isHorizontal: true);
      }

      return childNotif(isHorizontal: false);
    });
  }

  Widget childNotif({bool isHorizontal = false}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Pusat Notifikasi',
          style: TextStyle(
            color: Colors.black54,
            fontSize: isHorizontal ? 22.sp : 16.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              if (role == 'ADMIN') {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AdminScreen()));
              } else if (role == 'SALES') {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              }
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black54,
              size: isHorizontal ? 22.r : 16.r,
            )),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 35.r : 20.r,
              vertical: isHorizontal ? 10.r : 5.r,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                tempList.length > 0
                    ? InkWell(
                        child: Text(
                          'Tandai sudah dibaca semua',
                          style: TextStyle(
                            fontFamily: 'Segoe ui',
                            fontSize: isHorizontal ? 18.sp : 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.end,
                        ),
                        onTap: () {
                          setState(() {
                            for (int i = 0; i < tempList.length; i++) {
                              checkedRead(tempList[i]);
                            }
                          });
                        },
                      )
                    : SizedBox(
                        width: 5.w,
                      ),
              ],
            ),
          ),
          tempList.length > 0
                  ? Expanded(
                      child: SizedBox(
                        height: 100.h,
                        child: FutureBuilder(
                            future: listNotif,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Notifikasi>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasError) {
                                  return Column(
                                    children: [
                                      Center(
                                        child: Image.asset(
                                          'assets/images/not_found.png',
                                          width: isHorizontal ? 150.w : 230.w,
                                          height: isHorizontal ? 150.h : 230.h,
                                        ),
                                      ),
                                      Text(
                                        'Data tidak ditemukan',
                                        style: TextStyle(
                                          fontSize:
                                              isHorizontal ? 16.sp : 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red[600],
                                          fontFamily: 'Montserrat',
                                        ),
                                      )
                                    ],
                                  );
                                } else {
                                  return listViewWidget(
                                    snapshot.data!,
                                    snapshot.data!.length,
                                    isHorizontal: isHorizontal,
                                  );
                                }
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }),
                      ),
                    )
                  : Column(
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/not_found.png',
                            width: isHorizontal ? 350.r : 300.r,
                            height: isHorizontal ? 350.r : 300.r,
                          ),
                        ),
                        Text(
                          'Data tidak ditemukan',
                          style: TextStyle(
                            fontSize: isHorizontal ? 28.sp : 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[600],
                            fontFamily: 'Montserrat',
                          ),
                        )
                      ],
                    ),
        ],
      ),
    );
  }

  Widget listViewWidget(List<Notifikasi> item, int len,
      {bool isHorizontal = false}) {
    return RefreshIndicator(
      child: ListView.builder(
          itemCount: len,
          padding: EdgeInsets.only(
            left: isHorizontal ? 20.r : 5.r,
            right: isHorizontal ? 20.r : 5.r,
          ),
          itemBuilder: (context, position) {
            return InkWell(
              child: Container(
                decoration: BoxDecoration(
                  color: item[position].isRead != "0"
                      ? Colors.white
                      : Colors.grey.shade100,
                ),
                child: Container(
                  height: isHorizontal ? 150.h : 90.h,
                  margin: EdgeInsets.symmetric(
                    horizontal: isHorizontal ? 15.r : 10.r,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              isHorizontal ? 28.r : 15.r,
                            ),
                            child: Image.asset(
                              getNotifImg(
                                template: int.parse(
                                  item[position].typeTemplate,
                                ),
                              ),
                              width: isHorizontal ? 46.r : 30.r,
                              height: isHorizontal ? 46.r : 30.r,
                            ),
                          ),
                          SizedBox(
                            width: isHorizontal ? 15.r : 8.r,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item[position].judul,
                                      style: TextStyle(
                                        fontSize: isHorizontal ? 21.sp : 14.sp,
                                        fontFamily: 'Montserrrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      convertDateWithMonthHourNoSecond(
                                        item[position].tanggal,
                                        isPukul: false,
                                      ),
                                      style: TextStyle(
                                        fontSize: isHorizontal ? 17.sp : 11.sp,
                                        fontFamily: 'Montserrrat',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                Text(
                                  item[position].isi,
                                  style: TextStyle(
                                    fontSize: isHorizontal ? 18.sp : 12.sp,
                                    fontFamily: 'Segoe ui',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () {
                setState(() {
                  checkedRead(item[position]);
                });
              },
            );
          }),
      onRefresh: _refreshData,
    );
  }
}
