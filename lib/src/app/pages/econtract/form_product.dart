import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:sample/src/domain/entities/product.dart';

class FormItemProduct extends StatefulWidget {
  FormItemProduct({Key key, this.product, this.index}) : super(key: key);

  final index;
  Product product;
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

    if (widget.product.diskon != null) {
      widget._discvalController.text = widget.product.diskon;
      _isChecked = true;
      _isDisabled = true;
      widget.product.ischecked = _isChecked;
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

  Widget childFormProduct({bool isHorizontal}) {
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
                widget.product.proddesc,
                // 'Hybrid',
                style: TextStyle(
                  fontSize: 14,
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
                onChanged: (bool value) {
                  setState(() {
                    this._isChecked = value;
                    this._isDisabled = value;
                    widget.product.ischecked = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isHorizontal ? 30.r : 10.r,
                vertical: 5.r,
              ),
              height: isHorizontal ? 80.r : 50.r,
              child: TextFormField(
                enabled: _isDisabled,
                keyboardType: TextInputType.number,
                maxLength: 2,
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
                onChanged: (value) => widget.product.diskon = value,
                onSaved: (value) => widget.product.diskon = value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool validate() {
    formKey.currentState.save();
    return true;
  }
}
