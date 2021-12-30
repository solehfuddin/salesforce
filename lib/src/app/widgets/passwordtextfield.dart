import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/colors.dart';

class PasswordTextField extends StatefulWidget {
  final double topRight;
  final double bottomRight;
  final String hintText;
  final TextEditingController textEditingController;
  bool validate = false;

  PasswordTextField(this.topRight, this.bottomRight, this.hintText, this.textEditingController, this.validate);

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  // final double topRight;
  // final double bottomRight;
  // final String hintText;
  bool _isHidePass = true;

  // _PasswordTextFieldState(this.topRight, this.bottomRight, this.hintText, this._isHidePass);
  
  void _tooglePassVisibility() {
    setState(() {
      _isHidePass = !_isHidePass;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 40, bottom: 0),
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        child: Material(
          elevation: 10,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(widget.bottomRight),
              topRight: Radius.circular(widget.topRight),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 33, right: 20, top: 10, bottom: 10),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: "Password",
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: MyColors.desciptionColor,
                  fontSize: 14,
                  fontFamily: 'Segoe ui',
                ),
                errorText: widget.validate ? 'Value must be filled' : null,
                suffixIcon: GestureDetector(
                  onTap: () {
                    _tooglePassVisibility();
                  },
                  child: Icon(
                    _isHidePass ? Icons.visibility_off : Icons.visibility,
                    color: _isHidePass ? Colors.grey : Colors.blue,
                  ),
                ),
              ),
              obscureText: _isHidePass,
              controller: widget.textEditingController,
            ),
          ),
        ),
      ),
    );
  }
} 

