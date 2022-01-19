import 'package:flutter/material.dart';
import 'package:sample/src/domain/entities/itemdisc.dart';

class FormItemDisc extends StatefulWidget {
  FormItemDisc({Key key, this.itemDisc, this.index}) : super(key: key);

  final index;
  ItemDisc itemDisc;
  final state = _FormItemDiscState();

  @override
  _FormItemDiscState createState() {
    return state;
  }

  TextEditingController _discvalController = TextEditingController();
}

class _FormItemDiscState extends State<FormItemDisc> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
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
                'All Lensa Reguler',
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
              child: Text(
                'Regular',
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
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                controller: widget._discvalController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
