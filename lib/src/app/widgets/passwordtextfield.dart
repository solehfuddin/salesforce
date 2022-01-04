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
  bool _isHidePass = true;
  
  void _tooglePassVisibility() {
    setState(() {
      _isHidePass = !_isHidePass;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width - 70,
        child: Material(
          elevation: 10,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(widget.bottomRight),
              bottomLeft: Radius.circular(widget.bottomRight),
              topRight: Radius.circular(widget.topRight),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 33, right: 20, top: 7, bottom: 7),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                // labelText: "PASSWORD",
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: MyColors.desciptionColor,
                  fontSize: 14,
                  // fontFamily: 'Segoe ui',
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

