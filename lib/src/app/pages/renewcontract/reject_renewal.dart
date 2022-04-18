import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:sample/src/app/pages/econtract/detail_contract_rejected.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RejectRenewal extends StatefulWidget {
  @override
  State<RejectRenewal> createState() => _RejectRenewalState();
}

class _RejectRenewalState extends State<RejectRenewal> {
  String search = '';
  String id = '';
  String role = '';
  String username = '';
  String divisi = '';
  String ttdPertama;

  Future<void> _refreshData() async {
    setState(() {
      divisi == "AR" ? getRejectedData(true) : getRejectedData(false);
    });
  }

  @override
  initState() {
    super.initState();
    getRole();
  }

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      divisi = preferences.getString("divisi");

      getTtd(int.parse(id));
      print("Search Contract : $role");
    });
  }

  getTtd(int input) async {
    var url = 'https://timurrayalab.com/salesforce/server/api/users?id=$input';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      ttdPertama = data['data'][0]['ttd'];
      print(ttdPertama);
    }
  }

  Future<List<Contract>> getRejectedData(bool isAr) async {
    List<Contract> list;
    var url = !isAr
        ? 'http://timurrayalab.com/salesforce/server/api/contract/rejectedContractOldCustSM'
        : 'http://timurrayalab.com/salesforce/server/api/contract/rejectedContractOldCustAM';
    var response = await http.get(url);

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      var rest = data['data'];
      print(rest);
      list = rest.map<Contract>((json) => Contract.fromJson(json)).toList();
      print("List Size: ${list.length}");
    }

    return list;
  }

  Future<List<Contract>> getRejectBySearch(String input, bool isAr) async {
    List<Contract> list;
    var url =
        'http://timurrayalab.com/salesforce/server/api/contract/findOldCustContract';
    var response = await http.post(
      url,
      body: !isAr
          ? {
              'search': input,
              'approval_sm': '2',
            }
          : {
              'search': input,
              'approval_am': '2',
            },
    );

    print('Response status: ${response.statusCode}');

    var data = json.decode(response.body);
    final bool sts = data['status'];

    if (sts) {
      var rest = data['data'];
      print(rest);
      list = rest.map<Contract>((json) => Contract.fromJson(json)).toList();
      print("List Size: ${list.length}");
    }

    return list;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.r,
              vertical: 10.r,
            ),
            color: Colors.white,
            height: 80.h,
            child: TextField(
              textInputAction: TextInputAction.search,
              autocorrect: true,
              decoration: InputDecoration(
                hintText: 'Pencarian data ...',
                prefixIcon: Icon(Icons.search),
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white70,
                contentPadding: EdgeInsets.symmetric(vertical: 3.r),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
                  borderSide: BorderSide(color: Colors.grey, width: 2.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0.r)),
                  borderSide: BorderSide(color: Colors.blue, width: 2.r),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  search = value;
                });
              },
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 100.h,
              child: FutureBuilder(
                  future: search.isNotEmpty
                      ? getRejectBySearch(search, divisi == "AR" ? true : false)
                      : divisi == "AR"
                          ? getRejectedData(true)
                          : getRejectedData(false),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(child: CircularProgressIndicator());
                      default:
                        return snapshot.data != null
                            ? listViewWidget(
                                snapshot.data, snapshot.data.length)
                            : Column(
                                children: [
                                  Center(
                                    child: Image.asset(
                                      'assets/images/not_found.png',
                                      width: 300.r,
                                      height: 300.r,
                                    ),
                                  ),
                                  Text(
                                    'Data tidak ditemukan',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red[600],
                                      fontFamily: 'Montserrat',
                                    ),
                                  )
                                ],
                              );
                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget listViewWidget(List<Contract> item, int len) {
    return RefreshIndicator(
      child: Container(
        child: ListView.builder(
            itemCount: len,
            padding: EdgeInsets.symmetric(
              horizontal: 5.r,
              vertical: 15.r,
            ),
            shrinkWrap: true,
            itemBuilder: (context, position) {
              return InkWell(
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 10.r,
                  ),
                  padding: EdgeInsets.all(15.r),
                  height: 80.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.r),
                    ),
                    border: Border.all(
                      color: Colors.black26,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/e_contract_new.png',
                        filterQuality: FilterQuality.medium,
                        width: 35.r,
                        height: 35.r,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          item[position].customerShipName != null
                              ? item[position].customerShipName
                              : '-',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            convertDateWithMonth(item[position].dateAdded),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Segoe ui',
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'REJECTED',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                              color: Colors.red.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  item[position].idCustomer != null
                      ? Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailContractRejected(
                              item: item[position],
                              div: divisi,
                              ttd: ttdPertama,
                              username: username,
                            ),
                          ),
                        )
                      : handleStatus(
                          context, 'Id customer tidak ditemukan', false);
                },
              );
            }),
      ),
      onRefresh: _refreshData,
    );
  }
}
