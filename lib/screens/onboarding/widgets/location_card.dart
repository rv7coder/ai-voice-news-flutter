import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final String city;
  final String state;
  final String country;
  final VoidCallback onRefresh;
  final VoidCallback onChange;
  const LocationCard({
    super.key,
    required this.city,
    required this.state,
    required this.country,
    required this.onRefresh,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.location_on,
              size: 45,
              color: Colors.red,
            ),
            const SizedBox(height: 10),
            const Text(
              "Current Location",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              city,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "$state, $country",
              style: const TextStyle(
                fontSize: 17,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.my_location),
              label: const Text("Refresh Location"),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onChange,
              icon: const Icon(Icons.edit_location),
              label: const Text("Change Location"),
            ),
          ],
        ),
      ),
    );
  }
}