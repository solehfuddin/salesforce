import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/pages/admin/admin_view.dart';
import 'package:sample/src/app/pages/cashback/cashback_customerlist.dart';
import 'package:sample/src/app/pages/home/home_view.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/app/widgets/custompagesearch.dart';
import 'package:sample/src/domain/entities/account_session.dart';
import 'package:sample/src/domain/entities/opticwithaddress.dart';
import 'package:sample/src/domain/service/service_cashback.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';

class CashbackScreen extends StatefulWidget {
  const CashbackScreen({Key? key}) : super(key: key);

  @override
  State<CashbackScreen> createState() => _CashbackScreenState();
}

class _CashbackScreenState extends State<CashbackScreen> {
  TextEditingController txtSearch = new TextEditingController();
  ServiceCashback serviceCashback = new ServiceCashback();
  ServicePosMaterial servicePosMaterial = new ServicePosMaterial();
  AccountSession _session = new AccountSession();

  Future<List<OpticWithAddress>>? _listOptic;

  int totalItem = 0;
  int totalPage = 0;
  int limit = 4;
  int offset = 0;
  int page = 1;

  @override
  void initState() {
    super.initState();
    getAccountSession().then((value) {
      _session = value;

      _listOptic = servicePosMaterial.findAllCustWithAddress(
        context,
        mounted,
        txtSearch.text,
      );

      setState(() {});
    });
  }

  handleSearch(dynamic returnVal,
      {int limitVal = 4, int offsetVal = 0, int pageVal = 1}) {
    setState(() {
      page = pageVal;
      limit = limitVal;
      offset = offsetVal;

      _listOptic = servicePosMaterial.findAllCustWithAddress(
          context, mounted, txtSearch.text);
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _listOptic = servicePosMaterial.findAllCustWithAddress(
          context, mounted, txtSearch.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childWidget(isHorizontal: true);
      }

      return childWidget(isHorizontal: false);
    });
  }

  Widget childWidget({bool isHorizontal = false}) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: MyColors.greenAccent,
        title: Text(
          'List Customer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontFamily: 'Segoe ui',
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            paginateClear();

            if (_session.role == 'ADMIN') {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => AdminScreen()));
            } else if (_session.role == 'SALES') {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => HomeScreen()));
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FutureBuilder(
            future: _listOptic,
            builder: (BuildContext context,
                AsyncSnapshot<List<OpticWithAddress>> snapshot) {
              if (snapshot.hasData) {
                return CustomPageSearch(
                  isHorizontal: isHorizontal,
                  showControl: false,
                  totalItem: totalItem,
                  limit: limit,
                  page: page,
                  totalPage: totalPage,
                  setColor: MyColors.greenAccent,
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
          Expanded(
            child: SizedBox(
              height: 100.h,
              child: FutureBuilder(
                future: _listOptic,
                builder: (BuildContext context,
                    AsyncSnapshot<List<OpticWithAddress>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return RefreshIndicator(
                        child: CashbackCustomerList(
                          isHorizontal: isHorizontal,
                          listOptic: snapshot.data!,
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
