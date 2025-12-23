import 'package:TrendyWears/data/repository/product_repo.dart';
import 'package:TrendyWears/presentation/screens/cart_screen.dart';
import 'package:TrendyWears/presentation/screens/order_list_screen.dart';
import 'package:TrendyWears/presentation/screens/products_screendetail.dart';
import 'package:TrendyWears/presentation/screens/profile_screen.dart';
import 'package:TrendyWears/presentation/view_model/cart_viewmodel.dart';
import 'package:TrendyWears/widgets/category/filter_chips.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/products.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentFilter = '';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final cartVM = Provider.of<CartViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("TrendyWears"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Cart Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cartVM.cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartVM.cartItems.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: () {
                      final url = Supabase
                          .instance
                          .client
                          .auth
                          .currentUser
                          ?.userMetadata?['avatar_url'];
                      if (url != null && url.toString().isNotEmpty) {
                        return NetworkImage(url.toString());
                      }
                      return const AssetImage("assets/default_avatar.png")
                          as ImageProvider;
                    }(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Supabase
                                  .instance
                                  .client
                                  .auth
                                  .currentUser
                                  ?.userMetadata?['full_name'] ??
                              Supabase.instance.client.auth.currentUser?.email
                                  ?.split('@')
                                  .first ??
                              "Guest",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Supabase.instance.client.auth.currentUser?.email ??
                              "Not logged in",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("My Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(initialSection: 0),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text("Delivery Addresses"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(initialSection: 1),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text("My Orders"),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersListScreen()),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       // BEAUTIFUL DYNAMIC HEADER – ZERO ERRORS
      //       DrawerHeader(
      //         decoration: const BoxDecoration(color: Colors.deepPurple),
      //         child: Row(
      //           children: [
      //             // Avatar
      //             CircleAvatar(
      //               radius: 40,
      //               backgroundColor: Colors.white,
      //               backgroundImage: () {
      //                 final url = Supabase
      //                     .instance
      //                     .client
      //                     .auth
      //                     .currentUser
      //                     ?.userMetadata?['avatar_url'];
      //                 if (url != null && url.toString().isNotEmpty) {
      //                   return NetworkImage(url.toString());
      //                 }
      //                 return const AssetImage("assets/default_avatar.png")
      //                     as ImageProvider;
      //               }(),
      //             ),
      //             const SizedBox(width: 16),
      //             // Name & Email
      //             Expanded(
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 children: [
      //                   Text(
      //                     Supabase
      //                             .instance
      //                             .client
      //                             .auth
      //                             .currentUser
      //                             ?.userMetadata?['full_name'] ??
      //                         Supabase.instance.client.auth.currentUser?.email
      //                             ?.split('@')
      //                             .first ??
      //                         "Guest",
      //                     style: const TextStyle(
      //                       color: Colors.white,
      //                       fontSize: 18,
      //                       fontWeight: FontWeight.bold,
      //                     ),
      //                     maxLines: 1,
      //                     overflow: TextOverflow.ellipsis,
      //                   ),
      //                   const SizedBox(height: 4),
      //                   Text(
      //                     Supabase.instance.client.auth.currentUser?.email ??
      //                         "Not logged in",
      //                     style: const TextStyle(
      //                       color: Colors.white70,
      //                       fontSize: 14,
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),

      //       // MENU ITEMS
      //       ListTile(
      //         leading: const Icon(Icons.person),
      //         title: const Text("My Profile"),
      //         onTap: () {
      //           Navigator.pop(context);
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (_) => const ProfileScreen()),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.shopping_bag),
      //         title: const Text("My Orders"),
      //         onTap: () {
      //           Navigator.pop(context);
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (_) => OrderDetailsScreen(order: {}),
      //             ),
      //           );
      //         },
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.location_on),
      //         title: const Text("Delivery Addresses"),
      //         onTap: () {
      //           Navigator.pop(context);
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (_) => const ProfileScreen()),
      //           );
      //         },
      //       ),
      //       const Divider(),
      //       ListTile(
      //         leading: const Icon(Icons.logout, color: Colors.red),
      //         title: const Text("Logout", style: TextStyle(color: Colors.red)),
      //         onTap: () async {
      //           await Supabase.instance.client.auth.signOut();
      //           // Navigator.pushNamedAndRemoveUntil(builder: (_) => login);
      //           Navigator.pushReplacement(
      //             context,
      //             MaterialPageRoute(builder: (_) => const LoginScreen()),
      //           );
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (value) =>
                  setState(() => searchQuery = value.toLowerCase().trim()),
              decoration: InputDecoration(
                hintText: "Search clothes, shoes, bags...",
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Category Chips
          CategoryFilterChips(
            onCategorySelected: (cat) => setState(() => currentFilter = cat),
          ),

          // Product Grid
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: ProductRepository().getProductsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                var products = snapshot.data!;

                // Search filter
                if (searchQuery.isNotEmpty) {
                  products = products
                      .where(
                        (p) =>
                            p.name.toLowerCase().contains(searchQuery) ||
                            p.description.toLowerCase().contains(searchQuery),
                      )
                      .toList();
                }

                // Category filter
                if (currentFilter.isNotEmpty) {
                  products = products
                      .where((p) => p.category == currentFilter)
                      .toList();
                }

                if (products.isEmpty) {
                  return const Center(child: Text("No products found"));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600
                        ? 4
                        : 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      ),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                                  placeholder: (_, __) =>
                                      Container(color: Colors.grey[200]),
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                  const SizedBox(height: 8),
                                  // ADD TO CART BUTTON
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await cartVM.addToCart(
                                          product: product,
                                          quantity: 1,
                                          size: product.sizes.isNotEmpty
                                              ? product.sizes[0]
                                              : "M",
                                          color: product.colors.isNotEmpty
                                              ? product.colors[0]
                                              : "Default",
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              "Added to cart!",
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.add_shopping_cart,
                                        size: 18,
                                      ),
                                      label: const Text("Add to Cart"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
