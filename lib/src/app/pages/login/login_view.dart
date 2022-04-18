import 'package:flutter/material.dart';
import 'package:sample/src/app/widgets/backgroundlogin.dart';
import 'package:sample/src/app/widgets/loginform.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          BackgroundLogin(),
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: LoginForm(),
          ),
        ],
      ),
    );
  }
}
