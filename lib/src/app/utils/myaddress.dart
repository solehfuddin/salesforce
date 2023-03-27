import 'package:geocoding/geocoding.dart';

class MyAddress {
  Future<List<Placemark>> getAddress(double? latt, double? long) async {
    return await placemarkFromCoordinates(latt!, long!);
  }
}