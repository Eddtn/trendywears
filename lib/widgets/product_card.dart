// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:onlineclothing_app/data/models/products.dart';
// import 'package:onlineclothing_app/data/repository/product_repo.dart';
// import 'package:onlineclothing_app/presentation/screens/products_screendetail.dart';
// import 'package:onlineclothing_app/widgets/category/filter_chips.dart';

// class ProductCard extends StatelessWidget {
//   final Product product;
//   ProductCard({required this.product});

//   // @override
//   // Widget build(BuildContext context) {
//   //   return Card(
//   //     elevation: 5,
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         Expanded(
//   //           child: CachedNetworkImage(
//   //             imageUrl: product.imageUrl,
//   //             fit: BoxFit.cover,
//   //             width: double.infinity,
//   //             placeholder: (_, __) =>
//   //                 Center(child: CircularProgressIndicator()),
//   //           ),
//   //         ),
//   //         Padding(
//   //           padding: EdgeInsets.all(8),
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Text(
//   //                 product.name,
//   //                 maxLines: 2,
//   //                 overflow: TextOverflow.ellipsis,
//   //                 style: TextStyle(fontWeight: FontWeight.bold),
//   //               ),
//   //               SizedBox(height: 4),
//   //               Text(
//   //                 "₦${product.price}",
//   //                 style: TextStyle(
//   //                   color: Colors.deepPurple,
//   //                   fontSize: 16,
//   //                   fontWeight: FontWeight.bold,
//   //                 ),
//   //               ),
//   //               SizedBox(height: 8),
//   //               ElevatedButton(
//   //                 child: Text("View Details"),
//   //                 onPressed: () {
//   //                   Navigator.push(
//   //                     context,
//   //                     MaterialPageRoute(
//   //                       builder: (_) => ProductDetailScreen(product: product),
//   //                     ),
//   //                   );
//   //                 },
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // Inside your product list screen (e.g. HomeScreen)

//   String currentFilter = ''; // '' means show all

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("TrendyWear")),
//       body: Column(
//         children: [
//           // Filter Chips
//           CategoryFilterChips(
//             onCategorySelected: (category) {
//               setState(() {
//                 currentFilter = category;
//               });
//             },
//           ),

//           // Product Grid with live filtering
//           Expanded(
//             child: StreamBuilder<List<Product>>(
//               stream: ProductRepository()
//                   .getProductsStream(), // we'll add this next
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 var filteredProducts = snapshot.data!;

//                 if (currentFilter.isNotEmpty) {
//                   filteredProducts = filteredProducts
//                       .where((p) => p.category == currentFilter)
//                       .toList();
//                 }

//                 return GridView.builder(
//                   padding: const EdgeInsets.all(12),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: MediaQuery.of(context).size.width > 600
//                         ? 4
//                         : 2,
//                     childAspectRatio: 0.7,
//                     crossAxisSpacing: 12,
//                     mainAxisSpacing: 12,
//                   ),
//                   itemCount: filteredProducts.length,
//                   itemBuilder: (ctx, i) =>
//                       ProductCard(product: filteredProducts[i]),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/presentation/widgets/product_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:onlineclothing_app/data/models/products.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) => Container(color: Colors.grey[200]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "₦${product.price.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.category,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
