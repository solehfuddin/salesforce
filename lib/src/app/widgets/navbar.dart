import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:sample/src/app/utils/colors.dart';

class BottomNavbar extends StatefulWidget {
  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _selectedNavigation = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();

  final _itemNavigation = <Widget>[
    Icon(
      Icons.home,
      size: 30,
      color: Colors.white,
    ),
    Icon(
      Icons.view_agenda,
      size: 30,
      color: Colors.white,
    ),
    Icon(
      Icons.report,
      size: 30,
      color: Colors.white,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            children: <Widget>[
              Text(_selectedNavigation.toString(), textScaleFactor: 10.0),
              RaisedButton(
                child: Text('Go To Page of index 1'),
                onPressed: () {
                  //Page change using state does the same as clicking index 1 navigation button
                  final CurvedNavigationBarState navBarState =
                      _bottomNavigationKey.currentState;
                  navBarState.setPage(1);
                },
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        items: _itemNavigation,
        key: _bottomNavigationKey,
        color: MyColors.bgColor,
        height: 55,
        buttonBackgroundColor: MyColors.bgColor,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _selectedNavigation = index;
          });
        },
      ),
    );
  }
}
