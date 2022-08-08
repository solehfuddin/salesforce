import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:sample/src/app/pages/econtract/econtract_view.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/customer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailWaitingAdmin extends StatefulWidget {
  List<Customer> customer;
  int position;
  String reasonSM;
  String reasonAM;
  Contract contract;

  DetailWaitingAdmin({
    this.customer,
    this.position,
    this.reasonSM,
    this.reasonAM,
    this.contract,
  });

  @override
  State<DetailWaitingAdmin> createState() => _DetailWaitingAdminState();
}

class _DetailWaitingAdminState extends State<DetailWaitingAdmin> {
  String id, role, username, name, divisi;

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      id = preferences.getString("id");
      role = preferences.getString("role");
      username = preferences.getString("username");
      name = preferences.getString("name");
    });
  }

  @override
  void initState() {
    super.initState();
    getRole();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childDetail(isHorizontal: true);
      }

      return childDetail(isHorizontal: false);
    });
  }

  Widget childDetail({bool isHorizontal}) {
    return Container(
      padding: EdgeInsets.all(isHorizontal ? 25.r : 15.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  widget.customer[widget.position].namaUsaha,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isHorizontal ? 27.sp : 15.sp,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: isHorizontal ? 7.r : 5.r,
                  horizontal: isHorizontal ? 15.r : 10.r,
                ),
                decoration: BoxDecoration(
                  color: widget.customer[widget.position].status
                              .contains('Pending') ||
                          widget.customer[widget.position].status
                              .contains('PENDING')
                      ? Colors.grey[600]
                      : widget.customer[widget.position].status
                                  .contains('Accepted') ||
                              widget.customer[widget.position].status
                                  .contains('ACCEPTED')
                          ? Colors.blue[600]
                          : Colors.red[600],
                  borderRadius:
                      BorderRadius.circular(isHorizontal ? 15.r : 10.r),
                ),
                child: Text(
                  widget.customer[widget.position].status,
                  style: TextStyle(
                    fontSize: isHorizontal ? 22.sp : 12.sp,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            widget.customer[widget.position].status.contains('Pending') ||
                    widget.customer[widget.position].status.contains('PENDING')
                ? 'Pengajuan e-kontrak sedang diproses'
                : widget.customer[widget.position].status
                            .contains('Accepted') ||
                        widget.customer[widget.position].status
                            .contains('ACCEPTED')
                    ? 'Pengajuan e-kontrak diterima'
                    : 'Pengajuan e-kontrak ditolak',
            style: TextStyle(
              fontSize: isHorizontal ? 20.sp : 14.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color:
                  widget.customer[widget.position].status.contains('Pending') ||
                          widget.customer[widget.position].status
                              .contains('PENDING')
                      ? Colors.grey[600]
                      : widget.customer[widget.position].status
                                  .contains('Accepted') ||
                              widget.customer[widget.position].status
                                  .contains('ACCEPTED')
                          ? Colors.green[600]
                          : Colors.red[700],
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            'Diajukan tgl : ${convertDateWithMonth(widget.customer[widget.position].dateAdded)}',
            style: TextStyle(
              fontSize: isHorizontal ? 20.sp : 12.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(
            height: 3.h,
          ),
          Divider(
            color: Colors.black54,
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            'Detail Status',
            style: TextStyle(
              fontSize: isHorizontal ? 30.sp : 18.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 10.h,
          ),
          Row(
            children: [
              SizedBox(
                width: isHorizontal ? 10.w : 15.w,
              ),
              SizedBox(
                width: isHorizontal ? 30.w : 45.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isHorizontal ? 10.r : 5.r,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius:
                        BorderRadius.circular(isHorizontal ? 10.r : 5.r),
                  ),
                  child: Center(
                    child: Text(
                      'SM',
                      style: TextStyle(
                        fontSize: isHorizontal ? 25.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 15.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales Manager',
                      style: TextStyle(
                        fontSize: isHorizontal ? 25.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      // widget.customer[widget.position].ttdSalesManager == "0"
                      widget.contract.approvalSm == "0"
                          ? 'Menunggu Persetujuan Sales Manager'
                          : widget.contract.approvalSm == "1"
                              ? 'Disetujui oleh Sales Manager ${convertDateWithMonthHour(
                                  widget.contract.dateApprovalSm,
                                  isPukul: true,
                                )}'
                              : 'Ditolak oleh Sales Manager ${convertDateWithMonthHour(
                                  widget.contract.dateApprovalSm,
                                  isPukul: true,
                                )}',
                      style: TextStyle(
                        fontSize: isHorizontal ? 22.sp : 14.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.justify,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                    widget.contract.approvalSm.contains('2')
                        ? SizedBox(
                            height: isHorizontal ? 8.h : 5.h,
                          )
                        : SizedBox(
                            width: 3.w,
                          ),
                    widget.contract.approvalSm.contains('2')
                        ? Text(
                            'Keterangan : ',
                            style: TextStyle(
                              fontSize: isHorizontal ? 25.sp : 15.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : SizedBox(
                            width: 3.w,
                          ),
                    widget.contract.approvalSm.contains('2')
                        ? Text(
                            widget.reasonSM,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              fontSize: isHorizontal ? 24.sp : 14.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : SizedBox(
                            width: 3.w,
                          ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: isHorizontal ? 20.h : 10.h,
          ),
          Row(
            children: [
              SizedBox(
                width: isHorizontal ? 10.w : 15.w,
              ),
              SizedBox(
                width: isHorizontal ? 30.w : 45.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isHorizontal ? 10.r : 5.r,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius:
                        BorderRadius.circular(isHorizontal ? 10.r : 5.r),
                  ),
                  child: Center(
                    child: Text(
                      'AM',
                      style: TextStyle(
                        fontSize: isHorizontal ? 25.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 15.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AR Manager',
                      style: TextStyle(
                        fontSize: isHorizontal ? 25.sp : 15.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      // widget.customer[widget.position].ttdArManager == "0"
                      widget.contract.approvalAm == "0"
                          ? 'Menunggu Persetujuan AR Manager'
                          // : widget.customer[widget.position].ttdArManager == "1"
                          : widget.contract.approvalAm == "1"
                              ? 'Disetujui oleh AR Manager ${convertDateWithMonthHour(
                                  widget.contract.dateApprovalAm,
                                  isPukul: true,
                                )}'
                              : 'Ditolak oleh AR Manager ${convertDateWithMonthHour(
                                  widget.contract.dateApprovalAm,
                                  isPukul: true,
                                )}',
                      style: TextStyle(
                        fontSize: isHorizontal ? 22.sp : 14.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.justify,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                    widget.contract.approvalAm.contains('2')
                        ? SizedBox(
                            height: isHorizontal ? 8.h : 5.h,
                          )
                        : SizedBox(
                            width: 3.w,
                          ),
                    widget.contract.approvalAm.contains('2')
                        ? Text(
                            'Keterangan : ',
                            style: TextStyle(
                              fontSize: isHorizontal ? 25.sp : 15.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : SizedBox(
                            width: 3.w,
                          ),
                    widget.contract.approvalAm.contains('2')
                        ? Text(
                            widget.reasonAM,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              fontSize: isHorizontal ? 24.sp : 14.sp,
                              fontFamily: 'Segoe ui',
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : SizedBox(
                            width: 3.w,
                          ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              widget.customer[widget.position].status == "REJECTED" 
              // && role != "ADMIN"
                  ? ArgonButton(
                      height: isHorizontal ? 70.h : 40.h,
                      width: isHorizontal ? 90.w : 120.w,
                      borderRadius: isHorizontal ? 60.r : 30.r,
                      color: widget.customer[widget.position].isRevisi == "0"
                          ? Colors.orange[700]
                          : Colors.orange[300],
                      child: Text(
                        "Revisi Data",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: isHorizontal ? 24.sp : 14.sp,
                            fontWeight: FontWeight.w700),
                      ),
                      loader: Container(
                        padding: EdgeInsets.all(8.r),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      onTap: (startLoading, stopLoading, btnState) {
                        if (btnState == ButtonState.Idle) {
                          if (widget.customer[widget.position].isRevisi ==
                              "0") {
                            startLoading();
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => EcontractScreen(
                                  widget.customer,
                                  widget.position,
                                  isRevisi: true,
                                ),
                              ),
                            );
                            stopLoading();
                          }
                        }
                      },
                    )
                  : ArgonButton(
                      height: isHorizontal ? 70.h : 40.h,
                      width: isHorizontal ? 90.w : 120.w,
                      borderRadius: isHorizontal ? 60.r : 30.r,
                      color: Colors.blue[700],
                      child: Text(
                        "Unduh Data",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: isHorizontal ? 24.sp : 14.sp,
                            fontWeight: FontWeight.w700),
                      ),
                      loader: Container(
                        padding: EdgeInsets.all(8.r),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      onTap: (startLoading, stopLoading, btnState) {
                        if (btnState == ButtonState.Idle) {
                          startLoading();
                          waitingLoad();
                          donwloadCustomer(
                              int.parse(widget.customer[widget.position].id),
                              stopLoading());
                        }
                      },
                    ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  primary: Colors.red[800],
                  padding: EdgeInsets.symmetric(
                      horizontal: isHorizontal ? 40.r : 20.r, vertical: 10.r),
                ),
                child: Text(
                  'Tutup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isHorizontal ? 24.sp : 14.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Segoe ui',
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    );
  }
}
