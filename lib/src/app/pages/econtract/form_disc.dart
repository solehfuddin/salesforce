import 'package:flutter/material.dart';
import 'package:sample/src/domain/entities/proddiv.dart';

class FormItemDisc extends StatefulWidget {
  FormItemDisc({Key key, this.proddiv, this.index}) : super(key: key);

  final index;
  Proddiv proddiv;
  final state = _FormItemDiscState();

  @override
  _FormItemDiscState createState() {
    return state;
  }

  TextEditingController _discvalController = TextEditingController();
  bool isValidated() => state.validate();
}

class _FormItemDiscState extends State<FormItemDisc> {
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
                widget.proddiv.alias,
                // 'ALL LENSA REGULER',
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
                onChanged: (value) => widget.proddiv.diskon = value,
                onSaved: (value) => widget.proddiv.diskon = value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool validate() {
    //Validate Form Fields
    // bool validate = formKey.currentState.validate();
    // if (validate) formKey.currentState.save();
    // return validate;

    formKey.currentState.save();
    return true;
  }
}
