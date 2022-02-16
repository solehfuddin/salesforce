import 'package:flutter/material.dart';

class SampleView extends StatefulWidget {
  @override
  _SampleViewState createState() => _SampleViewState();
}

class _SampleViewState extends State<SampleView> {
  List<int> _data = [for (var i = 0; i < 200; i++) i];
  int _count = 50;

  Future<List<int>> _fetch(int count) {
    return Future.delayed(
      Duration(seconds: 2),
      () => _data.where((element) => element < count).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Loading next data"),
        ),
        body: _createBody(context),
      ),
    );
  }

  Widget _createBody(BuildContext context) {
    return FutureBuilder(
      future: _fetch(_count),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return Center(child: CircularProgressIndicator());
        }
        final controller = ScrollController();
        controller.addListener(() {
          if (controller.position.pixels ==
              controller.position.maxScrollExtent) {
            if (data.length == _count && _count < _data.length) {
              setState(() {
                _count += 50;
              });
            }
          }
        });
        return ListView.builder(
          controller: controller,
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(title: Text("Item number - ${data[index]}"));
          },
        );
      },
    );
  }
}
