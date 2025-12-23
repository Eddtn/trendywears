// // lib/presentation/screens/order_details_screen.dart

// import 'package:flutter/material.dart';

// class OrderDetailsScreen extends StatelessWidget {
//   final Map<String, dynamic> order;
//   const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final items = order['order_items'] as List;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Order Details")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Order ID: ${order['id']}",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               "Status: ${order['status']}",
//               style: const TextStyle(color: Colors.deepPurple),
//             ),
//             Text("Date: ${order['created_at'].toString().substring(0, 10)}"),
//             const Divider(height: 30),
//             const Text(
//               "Items:",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             ...items.map(
//               (item) => ListTile(
//                 title: Text("Item x${item['quantity']}"),
//                 trailing: Text("₦${item['price']}"),
//               ),
//             ),
//             const Divider(),
//             Text(
//               "Total: ₦${order['total_amount']}",
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/presentation/screens/order_details_screen.dart

import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = order['order_items'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order ID: ${order['id']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Status: ${order['status']}",
              style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
            ),
            Text(
              "Date: ${order['created_at']?.toString().substring(0, 10) ?? 'Unknown'}",
            ),
            Text(
              "Total: ₦${order['total_amount']}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 40),
            const Text(
              "Items:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...items.map(
              (item) => Card(
                child: ListTile(
                  title: Text("Product x${item['quantity']}"),
                  trailing: Text("₦${item['price']}"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
