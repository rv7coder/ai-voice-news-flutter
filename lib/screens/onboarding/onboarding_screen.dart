import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/onboarding_data.dart';
import '../../providers/onboarding_provider.dart';
import 'widgets/onboarding_page.dart';
import 'category_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final TextEditingController _nameController = TextEditingController();
  int currentPage = 0;

  bool get isLastPage => currentPage == onboardingPages.length - 1;

  void skipOnboarding() {
    if (isLastPage) {
      return;
    }
    _controller.animateToPage(
      onboardingPages.length - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _saveNameAndContinue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showNameRequiredMessage();
      return;
    }
    context.read<OnboardingProvider>().setUserName(name);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const CategorySelectionScreen(),
      ),
    );
  }

  void _showNameRequiredMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please enter your name...."),
      ),
    );
  }

  void nextPage() {
    if (!isLastPage) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      return;
    }
    _saveNameAndContinue();
  }

  void previousPage() {
    if (currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingPages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (_, index) {
                  return OnboardingPage(
                    page: onboardingPages[index],
                  );
                },
              ),
            ),
            if (isLastPage)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: "Your Name",
                    hintText: "Enter your name",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isLastPage)
                    TextButton(
                      onPressed: previousPage,
                      child: const Text("Back"),
                    )
                  else
                    TextButton(
                      onPressed: skipOnboarding,
                      child: const Text("Skip"),
                    ),
                  Row(
                    children: List.generate(
                      onboardingPages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        width: currentPage == index ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentPage == index
                              ? Colors.blue
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: nextPage,
                    child: Text(
                      isLastPage ? "Continue" : "Next",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}