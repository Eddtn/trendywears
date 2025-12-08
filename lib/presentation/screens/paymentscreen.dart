// // lib/presentation/screens/demo_payment_screen.dart

// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class DemoPaymentScreen extends StatefulWidget {
//   final double totalAmount;
//   final List<Map<String, dynamic>> cartItems;

//   const DemoPaymentScreen({
//     Key? key,
//     required this.totalAmount,
//     required this.cartItems,
//   }) : super(key: key);

//   @override
//   State<DemoPaymentScreen> createState() => _DemoPaymentScreenState();
// }

// class _DemoPaymentScreenState extends State<DemoPaymentScreen> {
//   bool isProcessing = false;

//   Future<void> _completeDemoPayment() async {
//     final user = Supabase.instance.client.auth.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Please log in first")));
//       return;
//     }

//     setState(() => isProcessing = true);

//     // Fake payment delay
//     await Future.delayed(const Duration(seconds: 3));

//     try {
//       // Create order
//       final orderRes = await Supabase.instance.client
//           .from('orders')
//           .insert({
//             'user_id': user.id,
//             'total_amount': widget.totalAmount,
//             'status': 'paid',
//             'payment_ref': 'demo_${DateTime.now().millisecondsSinceEpoch}',
//             'payment_method': 'card',
//             'created_at': DateTime.now().toIso8601String(),
//           })
//           .select()
//           .single();

//       // Save order items
//       final items = widget.cartItems
//           .map(
//             (item) => {
//               'order_id': orderRes['id'],
//               'product_id': item['product_id'],
//               'quantity': item['quantity'],
//               'price': item['price'],
//             },
//           )
//           .toList();

//       await Supabase.instance.client.from('order_items').insert(items);

//       // Success!
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: const [
//                 Icon(Icons.check_circle, color: Colors.white),
//                 SizedBox(width: 10),
//                 Text("Payment Successful! Order Placed"),
//               ],
//             ),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 4),
//           ),
//         );

//         // Go back to home
//         Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
//       );
//       setState(() => isProcessing = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Payment"),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // Total Card
//             Card(
//               elevation: 6,
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   children: [
//                     const Text("Amount to Pay", style: TextStyle(fontSize: 18)),
//                     const SizedBox(height: 10),
//                     Text(
//                       "₦${widget.totalAmount.toStringAsFixed(2)}",
//                       style: const TextStyle(
//                         fontSize: 42,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.deepPurple,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),

//             // Fake Card Form (Looks Real!)
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Test Card Details",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     const Text(
//                       "Use any of these test cards:",
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 10),
//                     _buildTestCard(
//                       "408 408 408 408 4081",
//                       "Visa • Always Succeeds",
//                     ),
//                     _buildTestCard(
//                       "5078 5078 5078 5078 12",
//                       "Verve • Always Succeeds",
//                     ),
//                     _buildTestCard(
//                       "1234 5678 9012 3456",
//                       "Mastercard • Fails (for testing)",
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       "Expiry: Any future date • CVV: Any 3 digits",
//                       style: TextStyle(fontStyle: FontStyle.italic),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const Spacer(),

//             // Pay Button
//             SizedBox(
//               width: double.infinity,
//               height: 60,
//               child: ElevatedButton.icon(
//                 onPressed: isProcessing ? null : _completeDemoPayment,
//                 icon: isProcessing
//                     ? const SizedBox(
//                         width: 24,
//                         height: 24,
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 3,
//                         ),
//                       )
//                     : const Icon(Icons.payment, size: 28),
//                 label: Text(
//                   isProcessing
//                       ? "Processing Payment..."
//                       : "Pay ₦${widget.totalAmount.toStringAsFixed(2)}",
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   elevation: 8,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),
//             const Text(
//               "DEMO MODE • No real money charged • Perfect for testing",
//               style: TextStyle(
//                 color: Colors.green,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTestCard(String number, String desc) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Text(
//             number,
//             style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
//           ),
//           const Spacer(),
//           Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//         ],
//       ),
//     );
//   }
// }

// lib/presentation/screens/demo_payment_screen.dart

import 'package:flutter/material.dart';
import 'package:onlineclothing_app/presentation/screens/order_tracking_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DemoPaymentScreen extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;

  const DemoPaymentScreen({
    Key? key,
    required this.totalAmount,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<DemoPaymentScreen> createState() => _DemoPaymentScreenState();
}

class _DemoPaymentScreenState extends State<DemoPaymentScreen> {
  bool isProcessing = false;

  Future<void> _completeDemoPayment() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please log in first")));
      return;
    }

    setState(() => isProcessing = true);
    await Future.delayed(const Duration(seconds: 3));

    try {
      final orderRes = await Supabase.instance.client
          .from('orders')
          .insert({
            'user_id': user.id,
            'total_amount': widget.totalAmount,
            'status': 'paid',
            'payment_ref': 'demo_${DateTime.now().millisecondsSinceEpoch}',
            'payment_method': 'card',
          })
          .select()
          .single();

      final items = widget.cartItems
          .map(
            (item) => {
              'order_id': orderRes['id'],
              'product_id': item['product_id'],
              'quantity': item['quantity'],
              'price': item['price'],
            },
          )
          .toList();

      await Supabase.instance.client.from('order_items').insert(items);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Successful! Order Placed"),
            backgroundColor: Colors.green,
          ),
        );

        // GO STRAIGHT TO TRACKING PAGE — THIS IS THE PROFESSIONAL FLOW
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => OrderTrackingScreen(
              order: orderRes,
            ), // ← show tracking immediately
          ),
          (route) => false,
        );
      }

      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Row(
      //         children: [
      //           Icon(Icons.check_circle, color: Colors.white),
      //           SizedBox(width: 10),
      //           Text("Payment Successful! Order Placed"),
      //         ],
      //       ),
      //       backgroundColor: Colors.green,
      //     ),
      //   );
      //   Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      // }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
      setState(() => isProcessing = false);
    }
  }

  Widget _buildTestCard(String number, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            number,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
          ),
          const Spacer(),
          Text(desc, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        // ← THIS FIXES SCROLLING!
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Total Card
            Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text("Amount to Pay", style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 10),
                    Text(
                      "₦${widget.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Test Cards Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Test Card Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Use any of these cards:",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    _buildTestCard(
                      "408 408 408 408 4081",
                      "Visa • Always Works",
                    ),
                    _buildTestCard(
                      "5078 5078 5078 5078 12",
                      "Verve • Always Works",
                    ),
                    _buildTestCard(
                      "1234 5678 9012 3456",
                      "Mastercard • Fails (for testing)",
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Expiry: Any future date • CVV: Any 3 digits",
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Pay Button (Fixed at Bottom)
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : _completeDemoPayment,
                icon: isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(Icons.payment, size: 28),
                label: Text(
                  isProcessing
                      ? "Processing..."
                      : "Pay ₦${widget.totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 10,
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "DEMO MODE • No real money charged",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
