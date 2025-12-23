// lib/presentation/screens/order_tracking_screen.dart

import 'package:TrendyWears/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderTrackingScreen({Key? key, required this.order}) : super(key: key);

  Widget _step(String title, String subtitle, bool active, bool completed) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: completed
              ? Colors.green
              : (active ? Colors.deepPurple : Colors.grey[300]),
          child: completed
              ? const Icon(Icons.check, color: Colors.white)
              : Icon(Icons.circle, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(subtitle, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = (order['status'] ?? 'pending').toString().toLowerCase();
    final items = order['order_items'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Order"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #${order['id'].toString().substring(0, 8).toUpperCase()}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Total: ₦${order['total_amount'] ?? 0}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      if (order['tracking_number'] != null)
                        Text(
                          "Tracking: ${order['tracking_number']}",
                          style: const TextStyle(color: Colors.blue),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Tracking Status",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _step("Order Placed", "Your order has been received", true, true),
              const SizedBox(height: 30),
              _step(
                "Processing",
                "We are preparing your items",
                status != 'pending',
                status != 'pending',
              ),
              const SizedBox(height: 30),
              _step(
                "Shipped",
                "Your order is on the way",
                status == 'shipped' || status == 'delivered',
                status == 'shipped' || status == 'delivered',
              ),
              const SizedBox(height: 30),
              _step(
                "Delivered",
                "Order delivered successfully",
                status == 'delivered',
                status == 'delivered',
              ),
              const SizedBox(height: 40),
              const Text(
                "Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...items.map(
                (item) => ListTile(
                  title: Text("Product x${item['quantity']}"),
                  trailing: Text("₦${item['price']}"),
                ),
              ),
            ],
          ),
        ),
      ),
      // In OrderTrackingScreen
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            // Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false),]
            // After successful payment
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(), // Your order data
              ),
              (route) => false, // Removes all previous screens
            ),
        child: const Icon(Icons.home),
      ),
    );
  }
}
