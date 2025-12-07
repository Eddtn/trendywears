// lib/presentation/screens/product_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:onlineclothing_app/data/models/products.dart';
import 'package:onlineclothing_app/presentation/view_model/cart_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedSize = '';
  String selectedColor = '';
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Pre-select first size & color
    if (widget.product.sizes.isNotEmpty) selectedSize = widget.product.sizes[0];
    if (widget.product.colors.isNotEmpty)
      selectedColor = widget.product.colors[0];
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);

    // For demo, use same image multiple times or add more in DB later
    final List<String> imageList = [
      widget.product.imageUrl,
      widget.product.imageUrl,
      widget.product.imageUrl,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name, maxLines: 1),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 400,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    autoPlay: true,
                    onPageChanged: (index, reason) {
                      setState(() => currentImageIndex = index);
                    },
                  ),
                  items: imageList.map((url) {
                    return CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[100],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 80),
                      ),
                    );
                  }).toList(),
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imageList.asMap().entries.map((entry) {
                      return Container(
                        width: currentImageIndex == entry.key ? 12 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentImageIndex == entry.key
                              ? Colors.deepPurple
                              : Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₦${widget.product.price.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Size Selector
                  if (widget.product.sizes.isNotEmpty) ...[
                    Text(
                      "Select Size",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: widget.product.sizes.map((size) {
                        return ChoiceChip(
                          label: Text(size),
                          selected: selectedSize == size,
                          selectedColor: Colors.deepPurple,
                          labelStyle: TextStyle(
                            color: selectedSize == size
                                ? Colors.white
                                : Colors.black,
                          ),
                          onSelected: (_) {
                            setState(() => selectedSize = size);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Color Selector
                  if (widget.product.colors.isNotEmpty) ...[
                    Text(
                      "Select Color",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: widget.product.colors.map((color) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = color),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getColorFromString(color),
                              border: Border.all(
                                color: selectedColor == color
                                    ? Colors.deepPurple
                                    : Colors.grey,
                                width: selectedColor == color ? 3 : 1,
                              ),
                            ),
                            child: selectedColor == color
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text(
                    widget.product.description.isEmpty
                        ? "Premium quality clothing with perfect fit and amazing comfort."
                        : widget.product.description,
                    style: GoogleFonts.poppins(fontSize: 15, height: 1.5),
                  ),

                  const SizedBox(height: 30),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: widget.product.stock <= 0
                          ? null
                          : () async {
                              if (selectedSize.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select a size"),
                                  ),
                                );
                                return;
                              }

                              await cartViewModel.addToCart(
                                product: widget.product,
                                quantity: 1,
                                size: selectedSize,
                                color: selectedColor,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${widget.product.name} added to cart!",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.shopping_bag, color: Colors.white),
                      label: Text(
                        widget.product.stock > 0
                            ? "Add to Cart"
                            : "Out of Stock",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  if (widget.product.stock <= 0)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "This item is currently out of stock",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
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

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}
