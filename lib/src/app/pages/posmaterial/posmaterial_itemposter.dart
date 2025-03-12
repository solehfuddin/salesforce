import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/entities/posmaterial_content.dart';
import '../../../domain/entities/posmaterial_lineposter.dart';
import '../../../domain/entities/posmaterial_poster.dart';
import '../../../domain/service/service_posmaterial.dart';
import '../../utils/thousandformatter.dart';

// ignore: camel_case_types, must_be_immutable
class Posmaterial_Itemposter extends StatefulWidget {
  final Function(String? varName, dynamic input) notifyParent;
  List<PosMaterialLinePoster>? listPosterLine = List.empty(growable: true);
  bool isHorizontal;

  Posmaterial_Itemposter({
    Key? key,
    this.isHorizontal = false,
    this.listPosterLine,
    required this.notifyParent,
  }) : super(key: key);

  @override
  State<Posmaterial_Itemposter> createState() => _Posmaterial_ItemposterState();
}

// ignore: camel_case_types
class _Posmaterial_ItemposterState extends State<Posmaterial_Itemposter> {
  ServicePosMaterial service = new ServicePosMaterial();
  List<PosMaterialPoster>? _posterList = List.empty(growable: true);
  List<PosMaterialContent>? _contentList = List.empty(growable: true);
  List<String>? posterList = List.empty(growable: true);
  List<String>? contentList = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _convertPoster();
    _convertContent();

    widget.listPosterLine?.forEach((element) {
      print("""
        Init Material Id : ${element.materialId}
        Init Material : ${element.material}
        Init Content Id : ${element.contentId}
        Init Content : ${element.content}
        """);
    });
  }

  void _convertPoster() {
    service.getPosMaterialPoster(context, mounted).then((value) {
      _posterList = value;
      if (value.isNotEmpty) {
        value.forEach((element) {
          setState(() {
            posterList?.add(element.posterMaterial ?? '');
          });
        });
      }
    });
  }

  void _convertContent() {
    service.getPosMaterialContent(context, mounted).then((value) {
      _contentList = value;
      if (value.isNotEmpty) {
        value.forEach((element) {
          setState(() {
            contentList?.add(element.posterContent ?? '');
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding:
            EdgeInsets.symmetric(vertical: widget.isHorizontal ? 15.r : 8.r),
        shrinkWrap: true,
        itemCount: widget.listPosterLine?.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(
              bottom: widget.isHorizontal ? 15.r : 10.r,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isHorizontal ? 15.w : 10.w,
              vertical: widget.isHorizontal ? 10.h : 5.h,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      print('Delete $index');
                      widget.notifyParent("deleteLine", index);
                    },
                    child: Icon(
                      Icons.dangerous_outlined,
                      color: Colors.red.shade500,
                      size: 22.r,
                    ),
                  ),
                ),
                SizedBox(
                  height: widget.isHorizontal ? 10.h : 5.h,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Material (Bahan)',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Lebar',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Tinggi',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: widget.isHorizontal ? 24.sp : 14.sp,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.isHorizontal ? 10.r : 5.r,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black54,
                          ),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: DropdownButton(
                          underline: SizedBox(),
                          isExpanded: true,
                          value: widget.listPosterLine?[index].material,
                          style: TextStyle(
                            color: Colors.black54,
                            fontFamily: 'Segoe ui',
                            fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          items: posterList?.map((item) {
                            return DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ));
                          }).toList(),
                          hint: Text(
                            'Pilih bahan',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                            ),
                          ),
                          onChanged: (String? _value) {
                            setState(() {
                              int? _index = _posterList?.indexWhere(
                                  (item) => item.posterMaterial == _value);

                              var selectorItem =
                                  widget.listPosterLine?.elementAt(index);
                              selectorItem?.material = _value;
                              selectorItem?.materialId =
                                  _posterList?[_index!].posterMaterialId;

                              widget.listPosterLine?.forEach((element) {
                                print("""
                                      Material Id : ${element.materialId}
                                      Material : ${element.material}
                                      Content Id : ${element.contentId}
                                      Content : ${element.content}
                                      """);
                              });

                              // widget.notifyParent('selectedMaterialId',
                              //     widget.selectedMaterialId);
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [ThousandsSeparatorInputFormatter()],
                        maxLength: 3,
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                            fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 2.h,
                          ),
                          errorText: widget
                                  .listPosterLine![index].validateProductWidth!
                              ? null
                              : 'Isi',
                        ),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              widget.listPosterLine![index]
                                  .validateProductWidth = true;

                              widget.listPosterLine![index].width = value;
                            } else {
                              widget.listPosterLine![index]
                                  .validateProductWidth = false;

                              widget.listPosterLine![index].width = "";
                            }

                            if (widget
                                    .listPosterLine![index].width!.isNotEmpty &&
                                widget.listPosterLine![index].height!
                                    .isNotEmpty &&
                                widget.listPosterLine![index].qty!.isNotEmpty) {
                              print('Update $index');
                              widget.notifyParent("updateLine", true);
                            }
                            else {
                              print('Update $index');
                              widget.notifyParent("updateLine", false);
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [ThousandsSeparatorInputFormatter()],
                        maxLength: 3,
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                            fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 2.h,
                          ),
                          errorText: widget
                                  .listPosterLine![index].validateProductHeight!
                              ? null
                              : 'Isi',
                        ),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              widget.listPosterLine![index]
                                  .validateProductHeight = true;

                              widget.listPosterLine![index].height = value;
                            } else {
                              widget.listPosterLine![index]
                                  .validateProductHeight = false;

                              widget.listPosterLine![index].height = "";
                            }

                            if (widget
                                    .listPosterLine![index].width!.isNotEmpty &&
                                widget.listPosterLine![index].height!
                                    .isNotEmpty &&
                                widget.listPosterLine![index].qty!.isNotEmpty) {
                              print('Update $index');
                              widget.notifyParent("updateLine", true);
                            }
                            else {
                              print('Update $index');
                              widget.notifyParent("updateLine", false);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: widget.isHorizontal ? 22.h : 12.h,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Konten',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: widget.isHorizontal ? 24.sp : 14.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Qty',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: widget.isHorizontal ? 24.sp : 14.sp,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.isHorizontal ? 10.r : 5.r,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black54,
                          ),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: DropdownButton(
                          underline: SizedBox(),
                          isExpanded: true,
                          value: widget.listPosterLine?[index].content,
                          style: TextStyle(
                            color: Colors.black54,
                            fontFamily: 'Segoe ui',
                            fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          items: contentList?.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }).toList(),
                          hint: Text(
                            'Pilih konten',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Segoe ui',
                            ),
                          ),
                          onChanged: (String? _value) {
                            setState(() {
                              int? _index = _contentList?.indexWhere(
                                  (item) => item.posterContent == _value);

                              var selectorItem =
                                  widget.listPosterLine?.elementAt(index);
                              selectorItem?.content = _value;
                              selectorItem?.contentId =
                                  _contentList?[_index!].posterContentId;

                              widget.listPosterLine?.forEach((element) {
                                print("""
                                      Material Id : ${element.materialId}
                                      Material : ${element.material}
                                      Content Id : ${element.contentId}
                                      Content : ${element.content}
                                      """);
                              });

                              // widget.notifyParent(
                              //     'selectedContentId', widget.selectedContentId);
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [ThousandsSeparatorInputFormatter()],
                        maxLength: 3,
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Segoe ui',
                            fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 2.h,
                          ),
                          errorText:
                              widget.listPosterLine![index].validateQtyItem!
                                  ? null
                                  : 'Isi',
                        ),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: widget.isHorizontal ? 25.sp : 15.sp,
                          fontFamily: 'Segoe ui',
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              widget.listPosterLine![index].validateQtyItem =
                                  true;

                              widget.listPosterLine![index].qty = value;
                            } else {
                              widget.listPosterLine![index].validateQtyItem =
                                  false;

                              widget.listPosterLine![index].qty = "";
                            }

                            if (widget
                                    .listPosterLine![index].width!.isNotEmpty &&
                                widget.listPosterLine![index].height!
                                    .isNotEmpty &&
                                widget.listPosterLine![index].qty!.isNotEmpty) {
                              print('Update $index');
                              widget.notifyParent("updateLine", true);
                            }
                            else {
                              print('Update $index');
                              widget.notifyParent("updateLine", false);
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: widget.isHorizontal ? 10.h : 5.h,
                ),
              ],
            ),
          );
        });
  }
}
