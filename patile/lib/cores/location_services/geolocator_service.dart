import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorService {
  var latitude = "";
  var longitude = "";
  var altitude = "";
  var speed = "";
  var address = "";

  Future<List> updatePosition() async {
    Position pos = await determinePosition();
    List pm = await placemarkFromCoordinates(pos.latitude, pos.longitude);

    latitude = pos.latitude.toString();
    longitude = pos.longitude.toString();
    altitude = pos.altitude.toString();
    speed = pos.speed.toString();
    address = pm[0].toString();

    return [latitude, longitude, altitude, speed, address];
  }

  Future<List<double>> getAddress() async {
    Position pos = await determinePosition();
    // List pm = await placemarkFromCoordinates(pos.latitude, pos.longitude);

    return [pos.latitude, pos.longitude];
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location service are disabled");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission are denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permission are permanently denied, we cannot request permission");
    }
    return await Geolocator.getCurrentPosition();
  }
}
