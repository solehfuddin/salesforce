import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:sample/src/app/pages/econtract/detail_contract_rejected.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/contract.dart';
import 'package:sample/src/domain/entities/customer.dart';

class DetailRejected extends StatefulWidget {
  List<Customer> customer;
  int position;
  String div, ttd, idCust, username, reasonSM, reasonAM;
  Contract contract;

  DetailRejected({
    this.customer,
    this.position,
    this.div,
    this.ttd,
    this.idCust,
    this.username,
    this.reasonAM,
    this.reasonSM,
    this.contract,
  });

  @override
  State<DetailRejected> createState() => _DetailRejectedState();
}

class _DetailRejectedState extends State<DetailRejected> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childDetailRejected(isHorizontal: true);
      }

      return childDetailRejected(isHorizontal: false);
    });
  }

  Widget childDetailRejected({bool isHorizontal}) {
    return Container(
      padding: EdgeInsets.all(isHorizontal ? 25.r : 15.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.customer[widget.position].namaUsaha,
                style: TextStyle(
                  fontSize: isHorizontal ? 27.sp : 20.sp,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: isHorizontal ? 7.r : 5.r,
                  horizontal: isHorizontal ? 15.r : 10.r,
                ),
                decoration: BoxDecoration(
                  color: widget.customer[widget.position].status == "Pending"
                      ? Colors.grey[600]
                      : widget.customer[widget.position].status == "Accepted"
                          ? Colors.blue[600]
                          : Colors.red[600],
                  borderRadius:
                      BorderRadius.circular(isHorizontal ? 15.r : 10.r),
                ),
                child: Text(
                  widget.customer[widget.position].status,
                  style: TextStyle(
                    fontSize: isHorizontal ? 22.sp : 13.sp,
                    fontFamily: 'Segoe ui',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.h,
          ),
          Text(
            widget.customer[widget.position].status == "Pending"
                ? 'Pengajuan e-kontrak sedang diproses'
                : widget.customer[widget.position].status == "Accepted"
                    ? 'Pengajuan e-kontrak diterima'
                    : 'Pengajuan e-kontrak ditolak',
            style: TextStyle(
              fontSize: isHorizontal ? 20.sp : 14.sp,
              fontFamily: 'Segoe ui',
              fontWeight: FontWeight.w600,
              color: widget.customer[widget.position].status == "Pending"
                  ? Colors.grey[600]
                  : widget.customer[widget.position].status == "Accepted"
                      ? Colors.green[600]
                      : Colors.red[700],
            ),
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
                      widget.customer[widget.position].ttdSalesManager == "0"
                          ? 'Menunggu Persetujuan Sales Manager'
                          : widget.customer[widget.position].ttdSalesManager ==
                                  "1"
                              ? 'Disetujui oleh Sales Manager ${convertDateWithMonth(widget.customer[widget.position].dateSM)}'
                              : 'Ditolak oleh Sales Manager ${convertDateWithMonth(widget.customer[widget.position].dateSM)}',
                      style: TextStyle(
                        fontSize: isHorizontal ? 22.sp : 14.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
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
            height: isHorizontal ? 20.h : 15.h,
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
                      widget.customer[widget.position].ttdArManager == "0"
                          ? 'Menunggu Persetujuan AR Manager'
                          : widget.customer[widget.position].ttdArManager == "1"
                              ? 'Disetujui oleh AR Manager ${convertDateWithMonth(widget.customer[widget.position].dateAM)}'
                              : 'Ditolak oleh AR Manager ${convertDateWithMonth(widget.customer[widget.position].dateAM)}',
                      style: TextStyle(
                        fontSize: isHorizontal ? 22.sp : 14.sp,
                        fontFamily: 'Segoe ui',
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
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
          Center(
            child: ArgonButton(
              height: isHorizontal ? 70.h : 40.h,
              width: isHorizontal ? 80.w : 110.w,
              borderRadius: isHorizontal ? 60.r : 30.0.r,
              color: Colors.blue[700],
              child: Text(
                "Lebih Lengkap",
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
                  widget.idCust != null
                      ? Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailContractRejected(
                              item: widget.contract,
                              div: widget.div,
                              ttd: widget.ttd,
                              username: widget.username,
                              isNewCust: true,
                            ),
                          ),
                        )
                      : handleStatus(
                          context,
                          'Id customer tidak ditemukan',
                          false,
                          isHorizontal: isHorizontal,
                        );
                  stopLoading();
                }
              },
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    );
  }
}
