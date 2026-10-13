import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../services/location_service.dart';
import '../../services/user_service.dart';
import '../home/home_screen.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});
  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final LocationService locationService = LocationService();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  bool isLoading = false;
  bool manualMode = false;

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  @override
  void dispose() {
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    super.dispose();
  }

  Future<void> loadLocation() async {
    setState(() {
      isLoading = true;
    });
    final location = await locationService.getCurrentLocation();
    if (!mounted) return;
    if (location == null) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to detect your location. You can enter it manually.",
          ),
        ),
      );
      return;
    }
    countryController.text = location["country"] ?? "";
    stateController.text = location["state"] ?? "";
    cityController.text = location["city"] ?? "";
    setState(() {
      isLoading = false;
      manualMode = false;
    });
  }

  void enableManualMode() {
    setState(() {
      manualMode = true;
      isLoading = false;
    });
  }

  Future<void> saveUserPreference() async {
    final country = countryController.text.trim();
    final state = stateController.text.trim();
    final city = cityController.text.trim();
    if (country.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Country is required."),
        ),
      );
      return;
    }
    final provider = context.read<OnboardingProvider>();
    if (provider.userName == null || provider.userName!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your name before continuing."),
        ),
      );
      return;
    }
    if (provider.selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one category."),
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    provider.setLocation(
      country: country,
      state: state,
      city: city,
    );
    final userId = await UserService().saveUserPreference(
      userName: provider.userName!.trim(),
      fields: provider.selectedCategories,
      country: country,
      state: state,
      city: city,
    );
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
    if (userId != null) {
      provider.setUserId(userId);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Failed to save preferences."),
      ),
    );
  }

  InputDecoration inputDecoration(
    String label,
    String hint,
    bool required,
  ) {
    return InputDecoration(
      labelText: required ? "$label *" : label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Your Location"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              const LinearProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              "Where are you located?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Country is required. State and city are optional.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            if (!manualMode)
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey.shade100,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 50,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          cityController.text.isEmpty
                              ? "Use your current location or enter it manually."
                              : [
                                  cityController.text,
                                  stateController.text,
                                  countryController.text,
                                ].where((value) => value.isNotEmpty).join(", "),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: enableManualMode,
                      icon: const Icon(Icons.edit_location_alt),
                      label: const Text("Enter Location Manually"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: isLoading ? null : loadLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text("Detect My Location"),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Enter Location Manually",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(() {
                                  manualMode = false;
                                });
                              },
                        child: const Text("Use GPS"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: countryController,
                    textCapitalization: TextCapitalization.words,
                    decoration: inputDecoration(
                      "Country",
                      "e.g. India",
                      true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: stateController,
                    textCapitalization: TextCapitalization.words,
                    decoration: inputDecoration(
                      "State",
                      "e.g. Maharashtra",
                      false,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: cityController,
                    textCapitalization: TextCapitalization.words,
                    decoration: inputDecoration(
                      "City",
                      "e.g. Mumbai",
                      false,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "* Country is required",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveUserPreference,
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}