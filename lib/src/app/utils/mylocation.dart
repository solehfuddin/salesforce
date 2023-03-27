import 'package:location/location.dart';

class MyLocation {
  Location _myLocation = Location();
  LocationData? _locationData;
  late PermissionStatus _isPermission;

  Future<bool> isServiceEnable() async {
    return await _myLocation.requestService();
  }

  Future<bool> isPermissionEnable() async {
    _isPermission = await _myLocation.requestPermission();

    if (_isPermission == PermissionStatus.granted ||
        _isPermission == PermissionStatus.grantedLimited) {
      return true;
    } else {
      return false;
    }
  }

  Future<LocationData?> getLocation() async {
    _myLocation.changeSettings(
      accuracy: LocationAccuracy.high,
    );
    _locationData = await _myLocation.getLocation();
    return _locationData;
  }
}
