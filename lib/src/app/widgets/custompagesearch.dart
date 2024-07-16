import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/app/utils/colors.dart';
import 'package:sample/src/app/utils/custom.dart';
import 'package:sample/src/domain/entities/posmaterial_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class CustomPageSearch extends StatefulWidget {
  final Function(dynamic input, {int limitVal, int offsetVal, int pageVal})
      handleSearch;
  TextEditingController txtSearch = new TextEditingController();
  int page = 1;
  int? totalItem = 0;
  int? totalPage = 0;
  int? limit = 5;
  bool isHorizontal = false;
  bool showControl = true;
  Color setColor = MyColors.darkColor;
  CustomPageSearch({
    Key? key,
    required this.isHorizontal,
    required this.showControl,
    this.totalItem,
    this.totalPage,
    this.limit,
    required this.page,
    required this.setColor,
    required this.txtSearch,
    required this.handleSearch,
  }) : super(key: key);

  @override
  State<CustomPageSearch> createState() => _CustomPageSearchState();
}

class _CustomPageSearchState extends State<CustomPageSearch> {
  List<PosMaterialHeader> listHeader = List.empty(growable: true);
  int startAt = 0;
  int endAt = 0;

  @override
  void initState() {
    super.initState();
    print('Total Data : ${widget.totalItem}');
    getPaginateSession();
  }

  getPaginateSession() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    widget.page = pref.getInt('paginatePage') ?? 0;
    startAt = pref.getInt('paginateStartAt') ?? 0;

    printPagination();
  }

  printPagination() {
    print("""
          page = ${widget.page}
          pageCount = ${widget.limit}
          startAt = $startAt
          endAt = $endAt;
          totalPages = ${widget.totalPage}
          """);
  }

  void loadPreviousPage() {
    if (widget.page > 1) {
      setState(() {
        startAt = startAt - widget.limit!;
        endAt = widget.page == widget.totalPage
            ? endAt - listHeader.length
            : endAt - widget.limit!;
        widget.page = widget.page - 1;

        paginatePref(widget.page, startAt);

        widget.handleSearch(
          widget.txtSearch.text,
          limitVal: widget.limit!,
          offsetVal: startAt,
          pageVal: widget.page,
        );

        printPagination();
      });
    }
  }

  void loadNextPage() {
    if (widget.page < widget.totalPage!) {
      setState(() {
        startAt = startAt + widget.limit!;
        endAt = listHeader.length > endAt + widget.limit!
            ? endAt + widget.limit!
            : listHeader.length;
        widget.page = widget.page + 1;

        paginatePref(widget.page, startAt);
        widget.handleSearch(
          widget.txtSearch.text,
          limitVal: widget.limit!,
          offsetVal: startAt,
          pageVal: widget.page,
        );

        printPagination();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.only(
              left: widget.isHorizontal ? 25.r : 20.r,
              top: widget.isHorizontal ? 15.r : 10.r,
              right: widget.isHorizontal ? 15.r : 12.r,
            ),
            color: widget.setColor,
            height: widget.isHorizontal ? 75.h : 70.h,
            child: TextField(
              textInputAction: TextInputAction.search,
              autocorrect: true,
              controller: widget.txtSearch,
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan nama optik',
                prefixIcon: Icon(Icons.search),
                hintStyle: TextStyle(
                  color: Colors.grey,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 3.r,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.r),
                  ),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 2.r,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.r),
                  ),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 2.r,
                  ),
                ),
              ),
              onSubmitted: (value) {
                setState(() {
                  widget.txtSearch.text = value;
                  widget.page = 1;
                  startAt = 0;
                  paginatePref(widget.page, startAt);

                  widget.handleSearch(
                    widget.txtSearch.text,
                    limitVal: widget.limit!,
                    offsetVal: startAt,
                    pageVal: widget.page,
                  );
                });
              },
            ),
          ),
        ),
        Visibility(
          visible: widget.showControl,
          child: Container(
            color: widget.setColor,
            height: widget.isHorizontal ? 75.h : 70.h,
            padding: EdgeInsets.only(
              right: widget.isHorizontal ? 22.r : 12.r,
              bottom: widget.isHorizontal ? 10.r : 5.r,
            ),
            child: Row(
              children: <Widget>[
                FloatingActionButton(
                  heroTag: Text("prev"),
                  backgroundColor:
                      widget.page > 1 ? Colors.green : Colors.green.shade200,
                  mini: true,
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: widget.isHorizontal ? 30.r : 20.r,
                  ),
                  elevation: 0,
                  onPressed: widget.page > 1 ? loadPreviousPage : null,
                ),
                FloatingActionButton(
                  heroTag: Text("next"),
                  backgroundColor: widget.page < widget.totalPage!
                      ? Colors.green
                      : Colors.green.shade200,
                  mini: true,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: widget.isHorizontal ? 30.r : 20.r,
                  ),
                  elevation: 0,
                  onPressed:
                      widget.page < widget.totalPage! ? loadNextPage : null,
                ),
              ],
            ),
          ),
          replacement: SizedBox(
            height: 5.h,
          ),
        ),
      ],
    );
  }
}
