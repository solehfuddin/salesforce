import 'package:flutter/material.dart';
import 'package:sample/src/domain/entities/frame.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class FormFrame extends StatefulWidget {
  FormFrame({ Key? key, this.frame, this.index, this.itemLength }) : super(key: key);

  final index;
  Frame? frame;
  int? itemLength = 2;
  var state = _FormFrameState();

  @override
  _FormFrameState createState() {
    // return state;
    return this.state = new _FormFrameState();
  }

  TextEditingController _discvalController = TextEditingController();
  bool isValidated() => state.validate();
}

class _FormFrameState extends State<FormFrame> {
  final formKey = GlobalKey<FormState>();
  bool _isChecked = false;
  bool _isDisabled = false;

  @override
  void initState() {
    super.initState();

    if (widget.frame!.qty != null) {
      widget._discvalController.text = widget.frame!.qty!;
      _isChecked = true;
      _isDisabled = true;
      widget.frame!.ischecked = _isChecked;
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
            flex: isHorizontal ? 4 : 3,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 10.r : 5.r,
                vertical: 2.r,
              ),
              child: Text(
                widget.frame!.frameName!,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 0.r,
                vertical: 2.r,
              ),
              child: Checkbox(
                value: this._isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    this._isChecked = value!;
                    this._isDisabled = value;
                    widget.frame!.ischecked = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 25.r : 7.r,
                vertical: 5.r,
              ),
              height: isHorizontal ? 80.r : 50.r,
              child: TextFormField(
                enabled: _isDisabled,
                keyboardType: TextInputType.number,
                maxLength: widget.itemLength,
                decoration: InputDecoration(
                  hintText: '0',
                  counterText: "",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isHorizontal ? 20.r : 10.r,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  hintStyle: TextStyle(
                    fontFamily: 'Segoe Ui',
                    fontSize: isHorizontal ? 28.sp : 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                textAlign: TextAlign.center,
                controller: widget._discvalController,
                onChanged: (value) => widget.frame!.qty = value,
                onSaved: (value) => widget.frame!.qty = value,
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