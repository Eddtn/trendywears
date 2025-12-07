import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryFilterChips extends StatefulWidget {
  final Function(String category) onCategorySelected;

  const CategoryFilterChips({Key? key, required this.onCategorySelected})
    : super(key: key);

  @override
  State<CategoryFilterChips> createState() => _CategoryFilterChipsState();
}

class _CategoryFilterChipsState extends State<CategoryFilterChips> {
  final List<String> categories = [
    'All',
    'Tops',
    'Dresses',
    'Jeans',
    'Jackets',
    'Shoes',
    'Bags',
    'Activewear',
    'Sweaters',
    'Sets',
    'Graphic Tees',
    'Blazers',
    'Sleepwear',
    'Beachwear',
    'Sandals',
    'Jewelry',
    'Accessories',
    'Hoodies',
    'Pants',
  ];

  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(
                category,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.deepPurple,
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(
                  color: isSelected ? Colors.deepPurple : Colors.transparent,
                  width: 1.5,
                ),
              ),
              elevation: isSelected ? 4 : 1,
              pressElevation: 6,
              onSelected: (bool selected) {
                setState(() {
                  selectedCategory = category;
                });
                widget.onCategorySelected(category == 'All' ? '' : category);
              },
            ),
          );
        },
      ),
    );
  }
}
