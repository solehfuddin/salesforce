import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/domain/entities/proddiv.dart';

// ignore: must_be_immutable
class FormItemDisc extends StatefulWidget {
  FormItemDisc({
    Key? key,
    this.proddiv,
    this.index,
  }) : super(key: key);

  final index;
  Proddiv? proddiv;
  var state = _FormItemDiscState();

  @override
  _FormItemDiscState createState() {
    // return state;
    return this.state = new _FormItemDiscState();
  }

  TextEditingController _discvalController = TextEditingController();
  bool isValidated() => state.validate();
}

class _FormItemDiscState extends State<FormItemDisc> {
  final formKey = GlobalKey<FormState>();
  bool _isChecked = false;
  bool _isDisabled = false;

  @override
  void initState() {
    super.initState();

    if (widget.proddiv!.diskon != '') {
      widget._discvalController.text = widget.proddiv!.diskon;
      _isChecked = true;
      _isDisabled = true;
      widget.proddiv!.ischecked = _isChecked;
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
                widget.proddiv!.alias,
                // 'ALL LENSA REGULER',
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
                    widget.proddiv!.ischecked = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 20.r : 10.r,
                vertical: 5.r,
              ),
              height: isHorizontal ? 55.r : 50.r,
              child: TextFormField(
                enabled: _isDisabled,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r"[0-9.]"),
                  ),
                  TextInputFormatter.withFunction(
                    (oldValue, newValue) {
                      final text = newValue.text;
                      return text.isEmpty
                          ? newValue
                          : double.tryParse(text) == null
                              ? oldValue
                              : newValue;
                    },
                  ),
                ],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                maxLength: 4,
                decoration: InputDecoration(
                  hintText: '0',
                  counterText: "",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isHorizontal ? 10.r : 10.r,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  hintStyle: TextStyle(
                    fontFamily: 'Segoe Ui',
                    fontSize: isHorizontal ? 18.sp : 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                textAlign: TextAlign.center,
                controller: widget._discvalController,
                // onChanged: (value) => widget.proddiv!.diskon = value,
                onChanged: (value) {
                  print('Value : $value');
                  if (value.length > 0) {
                    if (double.parse(value) >= 80) {
                      widget._discvalController.value = TextEditingValue(
                        text: "80",
                      );
                    }
                  }

                  widget.proddiv!.diskon = value;
                },
                onSaved: (value) => widget.proddiv!.diskon = value!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool validate() {
    // widget.state.s
    formKey.currentState!.save();
    // this.formKey
    return true;
  }
}
