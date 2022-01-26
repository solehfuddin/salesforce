import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 200,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
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
          SizedBox(
            width: 100,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
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
          SizedBox(
            width: 100,
            height: 42,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              child: TextFormField(
                enabled: _isDisabled,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
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