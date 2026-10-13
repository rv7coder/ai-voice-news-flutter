import 'package:flutter/material.dart';

class CategoryList extends StatefulWidget {
  final Function(String) onCategorySelected;
  const CategoryList({
    super.key,
    required this.onCategorySelected,
  });

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final List<String> categories = const [
    "⭐ Recommended",
    "Technology",
    "Business",
    "Sports",
    "Health",
    "Entertainment",
    "Travel",
    "Culture",
    "Arts",
    "Earth",
    "Live",
  ];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final bool selected = selectedIndex == index;
          return ChoiceChip(
            label: Text(categories[index]),
            selected: selected,
            showCheckmark: false,
            selectedColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.grey.shade200,
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            onSelected: (_) {
              setState(() {
                selectedIndex = index;
              });
              widget.onCategorySelected(categories[index]);
            },
          );
        },
      ),
    );
  }
}