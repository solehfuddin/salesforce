import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/domain/entities/jenisact.dart';

// ignore: must_be_immutable
class FormItemActivity extends StatefulWidget {
  FormItemActivity({ Key? key, this.jenisact, this.index}) : super(key: key);

  final index;
  Jenisact? jenisact;
  var state = _FormItemActivityState();

  @override
  _FormItemActivityState createState() {
    return this.state = new _FormItemActivityState();
  }

  TextEditingController _discvalController = TextEditingController();
  bool isValidated() => state.validate();
}

class _FormItemActivityState extends State<FormItemActivity> {
   final formKey = GlobalKey<FormState>();
  bool _isChecked = false;
  // bool _isDisabled = false;

  @override
  void initState() {
    super.initState();

    if (widget.jenisact!.description != '') {
      widget._discvalController.text = widget.jenisact!.description;
      _isChecked = true;
      // _isDisabled = true;
      widget.jenisact!.ischecked = _isChecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childFormDisc(isHorizontal: true);
      }

      return childFormDisc(isHorizontal: false);
    });
  }

  Widget childFormDisc({bool isHorizontal = false}) {
    return Form(
      key: formKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              color: Colors.grey.shade200,
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 20.r : 15.r,
                vertical: isHorizontal ? 15.r : 10.r,
              ),
              margin: EdgeInsets.only(
                top: 10.r,
              ),
              child: Text(
                widget.jenisact!.description,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Segoe ui',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool validate() {
    formKey.currentState!.save();
    return true;
  }
}