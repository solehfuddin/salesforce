import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/colors.dart';

class LoginTextfield extends StatelessWidget {
  final double topRight;
  final double bottomRight;
  final String hintText;
  final String labelText;
  final TextEditingController textEditingController;
  bool validate = false;

  LoginTextfield(this.topRight, this.bottomRight, this.labelText, this.hintText, this.textEditingController, this.validate);

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
              bottomRight: Radius.circular(bottomRight),
              topRight: Radius.circular(topRight),
              topLeft: Radius.circular(topRight),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 33, right: 20, top: 7, bottom: 7),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                // labelText: labelText,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: MyColors.desciptionColor,
                  fontSize: 14,
                  // fontFamily: 'Segoe ui',
                  fontFamily: 'Montserrat',
                ),
                errorText: validate ? 'Value must be filled' : null,
              ),
              controller: textEditingController,
            ),
          ),
        ),
      ),
    );
  }
}
