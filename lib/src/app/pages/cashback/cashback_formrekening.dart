import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:sample/src/app/pages/cashback/cashback_newrekening.dart';
// import 'package:sample/src/app/pages/cashback/cashback_oldrekening.dart';
import 'package:sample/src/app/utils/colors.dart';
// import 'package:sample/src/domain/entities/cashback_rekening.dart';

// ignore: must_be_immutable
class CashbackFormRekening extends StatefulWidget {
  final Function(String? varName, dynamic input) updateParent;
  TextEditingController controllerNama = new TextEditingController();
  TextEditingController controllerKtp = new TextEditingController();
  TextEditingController controllerNpwp = new TextEditingController();

  // CashbackRekening cashbackRekening = new CashbackRekening();
  // String billNumber, shipNumber;

  bool isHorizontal = false;
  bool isWalletAvail = false;
  bool validateName = false;
  bool validateKtp = false;
  // bool enableRekening = false;
  // bool isActiveRekening = false;

  CashbackFormRekening({
    Key? key,
    required this.updateParent,
    required this.isHorizontal,
    required this.isWalletAvail,
    required this.validateName,
    required this.validateKtp,
    // required this.enableRekening,
    // required this.isActiveRekening,
    // required this.billNumber,
    // required this.shipNumber,
    required this.controllerNama,
    required this.controllerKtp,
    required this.controllerNpwp,
    // required this.cashbackRekening,
  }) : super(key: key);

  @override
  State<CashbackFormRekening> createState() => _CashbackFormRekeningState();
}

class _CashbackFormRekeningState extends State<CashbackFormRekening> {
  updateSelected(dynamic variableName, dynamic returnVal) {
    setState(() {
      switch (variableName) {
        case 'updateNewRekening':
          widget.updateParent('setActiveRekening', true);
          widget.updateParent('setWalletAvail', true);
          // widget.cashbackRekening = returnVal;
          widget.updateParent('setEnableRekening', false);
          widget.updateParent('updateNewRekening', returnVal);
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: widget.isHorizontal ? 10.r : 5.r,
        right: widget.isHorizontal ? 10.r : 5.r,
        top: widget.isHorizontal ? 20.r : 10.r,
        bottom: widget.isHorizontal ? 20.r : 5.r,
      ),
      child: Card(
        elevation: 2,
        borderOnForeground: true,
        color: MyColors.greenAccent,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10.r,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                vertical: widget.isHorizontal ? 20.r : 10.r,
              ),
              child: Center(
                child: Text(
                  'Informasi Pemilik',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isHorizontal ? 26.sp : 16.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(
                widget.isHorizontal ? 24.r : 12.r,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 5.h,
                  ),
                  Text(
                    'Nama Pemilik',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 18.h : 8.h,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Nama Pemilik',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Segoe ui',
                        fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 2.h,
                      ),
                      errorText:
                          widget.validateName ? null : 'Nama belum diisi',
                    ),
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                      fontFamily: 'Segoe ui',
                      fontWeight: FontWeight.w600,
                    ),
                    maxLength: 16,
                    controller: widget.controllerNama,
                    onChanged: (value) {
                      if (value.length > 3) {
                        widget.updateParent("validateOwnerName", true);

                        if (value.length > 3 && widget.validateKtp) {
                          widget.updateParent('setEnableRekening', true);
                        }
                      } else {
                        widget.updateParent("validateOwnerName", false);
                        widget.updateParent('setEnableRekening', false);
                      }
                    },
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 22.h : 12.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'KTP',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: widget.isHorizontal ? 20.sp : 12.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15.w,
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'NPWP',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: widget.isHorizontal ? 20.sp : 12.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: widget.isHorizontal ? 18.h : 8.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Ktp',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Segoe ui',
                              fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 2.h,
                            ),
                            errorText:
                                widget.validateKtp ? null : 'Ktp belum diisi',
                          ),
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                            fontFamily: 'Segoe ui',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLength: 16,
                          controller: widget.controllerKtp,
                          onChanged: (value) {
                            if (value.length > 15) {
                              widget.updateParent('validateOwnerKtp', true);

                              if (widget.validateName && value.length > 15) {
                                widget.updateParent('setEnableRekening', true);
                              }
                            } else {
                              widget.updateParent('validateOwnerKtp', false);
                              widget.updateParent('setEnableRekening', false);
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 15.w,
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Npwp',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Segoe ui',
                              fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 2.h,
                            ),
                          ),
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                            fontFamily: 'Segoe ui',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLength: 15,
                          controller: widget.controllerNpwp,
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(
                  //   height: widget.isHorizontal ? 22.h : 12.h,
                  // ),
                  // Text(
                  //   'Informasi Rekening',
                  //   style: TextStyle(
                  //     color: Colors.black87,
                  //     fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                  //     fontFamily: 'Montserrat',
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Expanded(
                  //       flex: 3,
                  //       child: ElevatedButton.icon(
                  //         onPressed: widget.isWalletAvail
                  //             ? () {
                  //                 showDialog(
                  //                   barrierDismissible: false,
                  //                   context: context,
                  //                   builder: (BuildContext context) {
                  //                     return StatefulBuilder(
                  //                         builder: (context, state) {
                  //                       return AlertDialog(
                  //                         scrollable: true,
                  //                         title: Center(
                  //                           child: Text('Pilih Rekening'),
                  //                         ),
                  //                         content: CashbackOldRekening(
                  //                           isHorizontal: widget.isHorizontal,
                  //                           updateParent: updateSelected,
                  //                           noAccount: widget.billNumber,
                  //                         ),
                  //                       );
                  //                     });
                  //                   },
                  //                 );
                  //               }
                  //             : null,
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: Colors.orange.shade400,
                  //         ),
                  //         icon: Icon(Icons.check_circle),
                  //         label: Text(
                  //           'Pilih Rekening',
                  //         ),
                  //       ),
                  //     ),
                  //     SizedBox(width: 15.w),
                  //     Expanded(
                  //       flex: 4,
                  //       child: ElevatedButton.icon(
                  //         // onPressed: widget.enableRekening
                  //         //     ? () {
                  //         //         showModalBottomSheet(
                  //         //           elevation: 2,
                  //         //           backgroundColor: Colors.white,
                  //         //           isDismissible: true,
                  //         //           enableDrag: false,
                  //         //           shape: RoundedRectangleBorder(
                  //         //             borderRadius: BorderRadius.only(
                  //         //               topLeft: Radius.circular(15),
                  //         //               topRight: Radius.circular(15),
                  //         //             ),
                  //         //           ),
                  //         //           context: context,
                  //         //           builder: (context) {
                  //         //             return CashbackNewRekening(
                  //         //               isHorizontal: widget.isHorizontal,
                  //         //               billNumber: widget.billNumber,
                  //         //               shipNumber: widget.shipNumber,
                  //         //               updateParent: updateSelected,
                  //         //             );
                  //         //           },
                  //         //         );
                  //         //       }
                  //         //     : null,
                  //         onPressed: () {
                  //           showModalBottomSheet(
                  //             elevation: 2,
                  //             backgroundColor: Colors.white,
                  //             isDismissible: true,
                  //             enableDrag: false,
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.only(
                  //                 topLeft: Radius.circular(15),
                  //                 topRight: Radius.circular(15),
                  //               ),
                  //             ),
                  //             context: context,
                  //             builder: (context) {
                  //               return CashbackNewRekening(
                  //                 isHorizontal: widget.isHorizontal,
                  //                 billNumber: widget.billNumber,
                  //                 shipNumber: widget.shipNumber,
                  //                 updateParent: updateSelected,
                  //               );
                  //             },
                  //           );
                  //         },
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: Colors.blue.shade400,
                  //         ),
                  //         icon: Icon(
                  //           Icons.add_circle_rounded,
                  //         ),
                  //         label: Text(
                  //           'Tambah rekening baru',
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // widget.isActiveRekening
                  //     ? Padding(
                  //         padding: EdgeInsets.symmetric(
                  //           horizontal: 3.r,
                  //           vertical: 5.r,
                  //         ),
                  //         child: Card(
                  //           elevation: 2,
                  //           child: Container(
                  //             height: widget.isHorizontal ? 115.h : 65.h,
                  //             padding: EdgeInsets.symmetric(
                  //               horizontal: widget.isHorizontal ? 25.r : 15.r,
                  //               vertical: widget.isHorizontal ? 20.r : 10.r,
                  //             ),
                  //             child: Row(
                  //               mainAxisAlignment:
                  //                   MainAxisAlignment.spaceBetween,
                  //               children: [
                  //                 Column(
                  //                   crossAxisAlignment:
                  //                       CrossAxisAlignment.start,
                  //                   children: [
                  //                     Expanded(
                  //                       flex: 1,
                  //                       child: Text(
                  //                         '${widget.cashbackRekening.getNamaRekening} (${widget.cashbackRekening.getBankName})',
                  //                         style: TextStyle(
                  //                           fontSize: widget.isHorizontal
                  //                               ? 24.sp
                  //                               : 14.sp,
                  //                           fontFamily: 'Montserrat',
                  //                           fontWeight: FontWeight.w500,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                     Expanded(
                  //                       flex: 1,
                  //                       child: Text(
                  //                         'Nomor Rekening : ${widget.cashbackRekening.getNomorRekening}',
                  //                         style: TextStyle(
                  //                           fontSize: widget.isHorizontal
                  //                               ? 24.sp
                  //                               : 14.sp,
                  //                           fontWeight: FontWeight.w600,
                  //                           fontFamily: 'Segoe ui',
                  //                           color: Colors.black87,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //                 Image.asset(
                  //                   'assets/images/success.png',
                  //                   width: widget.isHorizontal ? 45.r : 25.r,
                  //                   height: widget.isHorizontal ? 45.r : 25.r,
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //     : Card(
                  //         elevation: 3,
                  //         child: Container(
                  //           height: widget.isHorizontal ? 115.h : 65.h,
                  //           padding: EdgeInsets.symmetric(
                  //             horizontal: widget.isHorizontal ? 25.r : 15.r,
                  //             vertical: widget.isHorizontal ? 20.r : 10.r,
                  //           ),
                  //           child: Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               Column(
                  //                 crossAxisAlignment: CrossAxisAlignment.start,
                  //                 children: [
                  //                   Expanded(
                  //                     flex: 1,
                  //                     child: Text(
                  //                       'Tidak ada informasi rekening',
                  //                       style: TextStyle(
                  //                         fontSize: widget.isHorizontal
                  //                             ? 24.sp
                  //                             : 14.sp,
                  //                         fontFamily: 'Montserrat',
                  //                         fontWeight: FontWeight.w600,
                  //                         color: Colors.red.shade700,
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   Expanded(
                  //                     flex: 1,
                  //                     child: Text(
                  //                       'Pilih rekening atau buat rekening baru',
                  //                       style: TextStyle(
                  //                         fontSize: widget.isHorizontal
                  //                             ? 24.sp
                  //                             : 14.sp,
                  //                         fontWeight: FontWeight.w500,
                  //                         fontFamily: 'Segoe ui',
                  //                         color: Colors.black45,
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //               Image.asset(
                  //                 'assets/images/failure.png',
                  //                 width: widget.isHorizontal ? 45.r : 25.r,
                  //                 height: widget.isHorizontal ? 45.r : 25.r,
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  SizedBox(
                    height: 5.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
