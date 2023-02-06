import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/custom.dart';

class DialogLogout extends StatefulWidget {
  @override
  State<DialogLogout> createState() => _DialogLogoutState();
}

class _DialogLogoutState extends State<DialogLogout> {
  @override
  Widget build(BuildContext context) {
    return childLogout();
  }

  Widget childLogout({bool isHor = false}) {
    return AlertDialog(
      title: Text("Informasi"),
      content: Container(
        child: Text("Apakah anda yakin menutup aplikasi ini?"),
      ),
      actions: [
        TextButton(
          child: Text(
            'Iya',
            style: TextStyle(
              color: Colors.green.shade500,
            ),
          ),
          onPressed: () => signOut(),
        ),
        TextButton(
          child: Text(
            'Tidak',
            style: TextStyle(
              color: Colors.green.shade500,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
