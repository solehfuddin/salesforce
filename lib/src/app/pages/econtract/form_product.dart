import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample/src/domain/entities/product.dart';

// ignore: must_be_immutable
class FormItemProduct extends StatefulWidget {
  FormItemProduct({
    Key? key,
    this.product,
    this.index,
    this.itemLength,
  }) : super(key: key);

  final index;
  Product? product;
  int? itemLength = 2;

  final state = _FormItemProductState();

  @override
  _FormItemProductState createState() {
    return state;
  }

  TextEditingController _discvalController = TextEditingController();
  bool isValidated() => state.validate();
}

class _FormItemProductState extends State<FormItemProduct> {
  final formKey = GlobalKey<FormState>();
  bool _isChecked = false;
  bool _isDisabled = false;

  @override
  void initState() {
    super.initState();

    if (widget.product!.diskon != '') {
      widget._discvalController.text = widget.product!.diskon;
      _isChecked = true;
      _isDisabled = true;
      widget.product!.ischecked = _isChecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600 ||
          MediaQuery.of(context).orientation == Orientation.landscape) {
        return childFormProduct(isHorizontal: true);
      }

      return childFormProduct(isHorizontal: false);
    });
  }

  Widget childFormProduct({bool isHorizontal = false}) {
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
                widget.product!.proddesc.toUpperCase(),
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
                    widget.product!.ischecked = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 15.r : 5.r,
                vertical: 5.r,
              ),
              height: isHorizontal ? 55.r : 50.r,
              child: TextFormField(
                enabled: _isDisabled,
                keyboardType: TextInputType.number,
                maxLength: widget.itemLength,
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
                onChanged: (value) => widget.product!.diskon = value,
                onSaved: (value) => widget.product!.diskon = value!,
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
