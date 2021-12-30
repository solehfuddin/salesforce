import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavigation = 0;

  void _onNavigationSelected(int index) {
    setState(() {
      _selectedNavigation = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final listPage = <Widget>[Text('Home'), Text('Agenda'), Text('Report')];

    final _navbarItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
      BottomNavigationBarItem(
          icon: Icon(Icons.view_agenda), title: Text('Agenda')),
      BottomNavigationBarItem(icon: Icon(Icons.report), title: Text('Report'))
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Sample New'),
        ),
        body: Center(
          child: listPage[_selectedNavigation],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: _navbarItems,
          currentIndex: _selectedNavigation,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          onTap: _onNavigationSelected,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
