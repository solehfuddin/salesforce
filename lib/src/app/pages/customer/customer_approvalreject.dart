import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/change_customer.dart';
import '../../../domain/entities/change_rescustomer.dart';
import '../../../domain/service/service_customer.dart';
import '../../utils/colors.dart';
import '../../utils/custom.dart';
import '../../widgets/custompagesearch.dart';
import 'customer_dialogstatus.dart';

// ignore: must_be_immutable
class CustomerApprovalReject extends StatefulWidget {
  Color defaultColor;
  bool isPending;
  CustomerApprovalReject({
    Key? key,
    this.defaultColor = MyColors.greenAccent,
    this.isPending = false,
  }) : super(key: key);

  @override
  State<CustomerApprovalReject> createState() => _CustomerApprovalRejectState();
}

class _CustomerApprovalRejectState extends State<CustomerApprovalReject> {
  ServiceCustomer serviceCustomer = new ServiceCustomer();
  TextEditingController txtSearch = new TextEditingController();

  Future<ChangeResCustomer>? _listCustomer;

  String? id = '';
  String? role = '';
  String? username = '';
  String? divisi = '';
  String? ttdPertama = '';

  int totalItem = 0;
  int totalPage = 0;
  int limit = 5;
  int offset = 0;
  int page = 1;

  @override
  void initState() {
    super.initState();
    getRole();
    paginatePref(page, 0);
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");
      ttdPertama = preferences.getString("ttduser") ?? '';

      if (role == 'ADMIN' && divisi == 'SALES') {
        callApi(int.parse(id!), false, 2, txtSearch.text, limit, offset);
      }
      else if (role == 'ADMIN' && divisi == 'AR') {
        callApi(0, true, 2, txtSearch.text, limit, offset);
      }
    });
  }

  void callApi(
      int idSalesArea, bool isArManager, int status, String search, int limit, int offset) {
    _listCustomer = serviceCustomer.getChangeCustomer(
      mounted,
      context,
      idManager: idSalesArea,
      isArManager: isArManager,
      status: status,
      search: search,
      limit: limit,
      offset: offset,
    );

    setState(() {
      _listCustomer?.then((value) {
        totalItem = value.total ?? 0;
        totalPage = initalizePage(value.total ?? 0);
        print("Total row : $totalItem");
      });
    });
  }

  // void callApiManager(
  //   bool isBrandManager,
  //   int status,
  //   String search,
  //   int limit,
  //   int offset,
  // ) {
  //   _listCashback = serviceCashback.getCashbackManager(
  //     mounted,
  //     context,
  //     status: status,
  //     search: search,
  //     limit: limit,
  //     offset: offset,
  //   );

  //   setState(() {
  //     _listCashback?.then((value) {
  //       totalItem = value.total ?? 0;
  //       totalPage = initalizePage(value.total ?? 0);
  //       print("Total Row : $totalItem");
  //     });
  //   });
  // }

  int initalizePage(int totalData) {
    int totalPages = (totalData / limit).floor();
    if (totalData / limit > totalPages) {
      totalPages += 1;
    }

    return totalPages;
  }

  Future<void> _refreshData() async {
    setState(() {
      if (role == 'ADMIN' && divisi == 'SALES') {
        callApi(int.parse(id!), false, 2, txtSearch.text, limit, offset);
      }
      else if (role == 'ADMIN' && divisi == 'AR') {
        callApi(0, true, 2, txtSearch.text, limit, offset);
      }
    });
  }

  handleSearch(
    dynamic returnVal, {
    int limitVal = 5,
    int offsetVal = 0,
    int pageVal = 1,
  }) {
    setState(() {
      page = pageVal;
      limit = limitVal;
      offset = offsetVal;

      if (role == 'ADMIN' && divisi == 'SALES') {
        callApi(int.parse(id!), false, 2, txtSearch.text, limit, offset);
      }
      else if (role == 'ADMIN' && divisi == 'AR') {
        callApi(0, true, 2, txtSearch.text, limit, offset);
      }
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FutureBuilder(
          future: _listCustomer,
          builder: (context, AsyncSnapshot<ChangeResCustomer> snapshot) {
            if (snapshot.hasData && snapshot.data!.count! > 0) {
              return CustomPageSearch(
                isHorizontal: isHorizontal,
                showControl: true,
                totalItem: totalItem,
                limit: limit,
                page: page,
                totalPage: totalPage,
                setColor: widget.defaultColor,
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
            future: _listCustomer,
            builder: (context, AsyncSnapshot<ChangeResCustomer> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.total! > 0) {
                  return RefreshIndicator(
                    child: listViewWidget(
                      snapshot.data!.customer,
                      snapshot.data?.count ?? 0,
                      isHorizontal: isHorizontal,
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
    );
  }

  Widget listViewWidget(List<ChangeCustomer> customer, int len,
      {bool isHorizontal = false}) {
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: EdgeInsets.symmetric(
              horizontal: isHorizontal ? 23.r : 5.r,
              vertical: isHorizontal ? 12.r : 10.r,
            ),
            itemBuilder: (context, position) {
              return Card(
                elevation: 2,
                child: ClipPath(
                  child: InkWell(
                    child: Container(
                      height: isHorizontal ? 130.h : 100.h,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: Colors.deepOrange.shade300,
                            width: isHorizontal ? 4.w : 5.r,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isHorizontal ? 20.r : 15.r,
                          vertical: 8.r,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    customer[position].namaUsaha ?? '',
                                    style: TextStyle(
                                      fontSize: isHorizontal ? 20.sp : 15.sp,
                                      fontFamily: 'Segoe ui',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    height: 15.h,
                                  ),
                                  SizedBox(
                                    width: isHorizontal ? 250.w : 200.w,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 80.w,
                                          child: Text(
                                            'Tgl entry : ',
                                            style: TextStyle(
                                                fontSize: isHorizontal
                                                    ? 16.sp
                                                    : 11.sp,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'Pemilik : ',
                                            style: TextStyle(
                                                fontSize: isHorizontal
                                                    ? 16.sp
                                                    : 11.sp,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  SizedBox(
                                    width: 200.w,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 80.w,
                                          child: Text(
                                            convertDateIndo(
                                                customer[position].dateAdded ??
                                                    ''),
                                            style: TextStyle(
                                                fontSize: isHorizontal
                                                    ? 17.sp
                                                    : 12.sp,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            customer[position].nama ?? '',
                                            style: TextStyle(
                                                fontSize: isHorizontal
                                                    ? 17.sp
                                                    : 12.sp,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isHorizontal ? 10.h : 8.h,
                                vertical: isHorizontal ? 5.h : 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade900,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                  SizedBox(
                                    width: 3.w,
                                  ),
                                  Text(
                                    customer[position].namaSalesman!.length > 0
                                        ? capitalize(
                                            customer[position].namaSalesman ??
                                                '')
                                        : 'Admin',
                                    style: TextStyle(
                                      fontSize: isHorizontal ? 13.sp : 11.sp,
                                      fontFamily: 'Montserrat',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      // detailChangeContract(customer[position], divisi ?? '', role ?? '');
                      // widget.isPending
                      //     ? Navigator.of(context).push(
                      //         MaterialPageRoute(
                      //           builder: (context) => CashbackDetail(
                      //             isSales: isSales,
                      //             itemHeader: itemHeader!.cashback[position],
                      //             showDownload: showDownload,
                      //           ),
                      //         ),
                      //       )
                      //     : 
                          showModalBottomSheet(
                              context: context,
                              elevation: 2,
                              enableDrag: true,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(
                                    15.r,
                                  ),
                                  topRight: Radius.circular(
                                    15.r,
                                  ),
                                ),
                              ),
                              builder: (context) {
                                return CustomerDialogStatus(
                                  item: customer[position],
                                  isSales: role == "SALES" ? true : false,
                                  username: username,
                                  divisi: divisi,
                                  role: role,
                                );
                              });
                    },
                  ),
                  clipper: ShapeBorderClipper(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              );
            }),
      ),
      onRefresh: _refreshData,
    );
  }
}
