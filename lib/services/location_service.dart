import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Map<String, String>?> getCurrentLocation() async {
    print("Checking location service...");

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      print("Location service disabled");
      return null;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    print("Permission: $permission");

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print("New Permission: $permission");
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("Permission denied");
      return null;
    }

    Position position =
        await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    print("Latitude: ${position.latitude}");
    print("Longitude: ${position.longitude}");

    List<Placemark> placemarks =
        await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks.first;

    print(place.country);
    print(place.administrativeArea);
    print(place.locality);

    return {
      "country": place.country ?? "",
      "state": place.administrativeArea ?? "",
      "city": place.locality ??
          place.subAdministrativeArea ??
          "",
    };
  }
}