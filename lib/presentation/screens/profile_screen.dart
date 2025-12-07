// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({Key? key}) : super(key: key);
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen>
//     with TickerProviderStateMixin {
//   final user = Supabase.instance.client.auth.currentUser;
//   Map<String, dynamic>? profile;
//   List<Map<String, dynamic>> addresses = [];
//   List<Map<String, dynamic>> orders = [];
//   bool isLoading = true;
//   late TabController tabController;

//   @override
//   void initState() {
//     super.initState();
//     tabController = TabController(length: 3, vsync: this);
//     if (user != null) loadData();
//   }

//   @override
//   void dispose() {
//     tabController.dispose();
//     super.dispose();
//   }

//   Future<void> loadData() async {
//     if (user == null) return;

//     setState(() => isLoading = true);

//     try {
//       // Load profile — with safe fallback if not exists
//       final profileList = await Supabase.instance.client
//           .from('profiles')
//           .select()
//           .eq('id', user!.id);

//       Map<String, dynamic> profileData = {};
//       if (profileList.isNotEmpty) {
//         profileData = profileList.first;
//       } else {
//         // Auto-create profile if missing
//         await Supabase.instance.client.from('profiles').insert({
//           'id': user!.id,
//           'full_name':
//               user!.userMetadata?['full_name'] ??
//               user!.email?.split('@').first ??
//               'User',
//           'email': user!.email,
//           'avatar_url': user!.userMetadata?['avatar_url'] ?? '',
//         });
//         profileData = {
//           'full_name': user!.email?.split('@').first ?? 'User',
//           'email': user!.email,
//           'avatar_url': '',
//           'phone': null,
//         };
//       }

//       // Load addresses
//       final addressData = await Supabase.instance.client
//           .from('addresses')
//           .select()
//           .eq('user_id', user!.id);

//       // Load orders
//       final orderData = await Supabase.instance.client
//           .from('orders')
//           .select('*, order_items(*)')
//           .eq('user_id', user!.id)
//           .order('created_at', ascending: false);

//       setState(() {
//         profile = profileData;
//         addresses = List<Map<String, dynamic>>.from(addressData);
//         orders = List<Map<String, dynamic>>.from(orderData);
//         isLoading = false;
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error loading profile: $e"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Not logged in
//     if (user == null) {
//       return const Scaffold(body: Center(child: Text("Please log in")));
//     }

//     // Still loading
//     if (isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     // Safe access — profile is NEVER null now
//     final String name =
//         profile?['full_name'] ?? user!.email?.split('@').first ?? "User";
//     final String email = user!.email ?? "No email";
//     final String? avatarUrl = profile?['avatar_url'];
//     final String? phone = profile?['phone'];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Account"),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         bottom: TabBar(
//           controller: tabController,
//           tabs: const [
//             Tab(text: "Profile"),
//             Tab(text: "Addresses"),
//             Tab(text: "Orders"),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: tabController,
//         children: [
//           // PROFILE TAB
//           ListView(
//             padding: const EdgeInsets.all(20),
//             children: [
//               Center(
//                 child: Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 60,
//                       backgroundColor: Colors.grey[300],
//                       backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
//                           ? CachedNetworkImageProvider(avatarUrl)
//                           : const AssetImage("assets/default_avatar.png")
//                                 as ImageProvider,
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: IconButton(
//                         icon: const CircleAvatar(
//                           backgroundColor: Colors.deepPurple,
//                           child: Icon(
//                             Icons.camera_alt,
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                         ),
//                         onPressed: () async {
//                           final picker = ImagePicker();
//                           final file = await picker.pickImage(
//                             source: ImageSource.gallery,
//                           );
//                           if (file == null) return;

//                           final bytes = await file.readAsBytes();
//                           final path = 'avatars/${user!.id}.jpg';

//                           await Supabase.instance.client.storage
//                               .from('avatars')
//                               .uploadBinary(
//                                 path,
//                                 bytes,
//                                 fileOptions: const FileOptions(upsert: true),
//                               );

//                           final url = Supabase.instance.client.storage
//                               .from('avatars')
//                               .getPublicUrl(path);

//                           await Supabase.instance.client
//                               .from('profiles')
//                               .update({'avatar_url': url})
//                               .eq('id', user!.id);

//                           setState(() => profile!['avatar_url'] = url);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 30),
//               Text(
//                 "Name: $name",
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text("Email: $email", style: const TextStyle(fontSize: 18)),
//               const SizedBox(height: 10),
//               Text(
//                 "Phone: ${phone ?? 'Not set'}",
//                 style: const TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 40),
//               ElevatedButton.icon(
//                 onPressed: () async {
//                   await Supabase.instance.client.auth.signOut();
//                   Navigator.pushNamedAndRemoveUntil(
//                     context,
//                     '/login',
//                     (r) => false,
//                   );
//                 },
//                 icon: const Icon(Icons.logout),
//                 label: const Text("Logout"),
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               ),
//             ],
//           ),

//           // ADDRESSES TAB
//           addresses.isEmpty
//               ? const Center(child: Text("No addresses saved"))
//               : ListView.builder(
//                   itemCount: addresses.length,
//                   itemBuilder: (_, i) {
//                     final a = addresses[i];
//                     return Card(
//                       child: ListTile(
//                         title: Text(a['street'] ?? 'No street'),
//                         subtitle: Text(
//                           "${a['city'] ?? ''}, ${a['state'] ?? ''}",
//                         ),
//                         trailing: a['is_default'] == true
//                             ? const Chip(
//                                 label: Text("Default"),
//                                 backgroundColor: Colors.deepPurple,
//                               )
//                             : null,
//                       ),
//                     );
//                   },
//                 ),

//           // ORDERS TAB
//           orders.isEmpty
//               ? const Center(child: Text("No orders yet"))
//               : ListView.builder(
//                   itemCount: orders.length,
//                   itemBuilder: (_, i) {
//                     final o = orders[i];
//                     return Card(
//                       child: ListTile(
//                         title: Text(
//                           "Order #${o['id'].toString().substring(0, 8).toUpperCase()}",
//                         ),
//                         subtitle: Text(
//                           "₦${o['total_amount'] ?? 0} • ${o['status'] ?? 'pending'}",
//                         ),
//                         trailing: const Icon(Icons.arrow_forward_ios),
//                       ),
//                     );
//                   },
//                 ),
//         ],
//       ),
//     );
//   }
// }

// lib/presentation/screens/profile_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final user = Supabase.instance.client.auth.currentUser;
  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> addresses = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> paymentMethods = [];
  bool isLoading = true;
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    if (user != null) loadAllData();
  }

  Future<void> loadAllData() async {
    setState(() => isLoading = true);

    try {
      var p = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user!.id);
      if (p.isEmpty) {
        await Supabase.instance.client.from('profiles').insert({
          'id': user!.id,
          'full_name': user!.email?.split('@').first ?? 'User',
          'email': user!.email,
        });
        p = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user!.id);
      }

      final a = await Supabase.instance.client
          .from('addresses')
          .select()
          .eq('user_id', user!.id)
          .order('is_default', ascending: false);

      final o = await Supabase.instance.client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', user!.id)
          .order('created_at', ascending: false);

      final pm = await Supabase.instance.client
          .from('payment_methods')
          .select()
          .eq('user_id', user!.id);

      setState(() {
        profile = p.first;
        addresses = List.from(a);
        orders = List.from(o);
        paymentMethods = List.from(pm);
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
      setState(() => isLoading = false);
    }
  }

  // DELETE ADDRESS — NOW INCLUDED!
  Future<void> deleteAddress(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Address?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.from('addresses').delete().eq('id', id);
      loadAllData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Address deleted")));
    }
  }

  // EDIT PROFILE WITH VALIDATION
  void editProfile() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: profile?['full_name']);
    final phoneCtrl = TextEditingController(text: profile?['phone']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                validator: (v) => v!.trim().isEmpty ? "Name required" : null,
                decoration: const InputDecoration(labelText: "Full Name"),
              ),
              TextFormField(
                controller: phoneCtrl,
                validator: (v) =>
                    v!.trim().length < 10 ? "Valid phone required" : null,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await Supabase.instance.client
                    .from('profiles')
                    .update({
                      'full_name': nameCtrl.text.trim(),
                      'phone': phoneCtrl.text.trim(),
                    })
                    .eq('id', user!.id);
                loadAllData();
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ADDRESS DIALOG WITH VALIDATION
  void manageAddress({Map<String, dynamic>? addr}) {
    final formKey = GlobalKey<FormState>();
    final isEdit = addr != null;
    final streetCtrl = TextEditingController(text: addr?['street'] ?? '');
    final cityCtrl = TextEditingController(text: addr?['city'] ?? '');
    final stateCtrl = TextEditingController(text: addr?['state'] ?? '');
    final zipCtrl = TextEditingController(text: addr?['zip_code'] ?? '');
    bool isDefault = addr?['is_default'] ?? false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Address" : "Add Address"),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: streetCtrl,
                  validator: (v) =>
                      v!.trim().isEmpty ? "Street required" : null,
                  decoration: const InputDecoration(
                    labelText: "Street Address",
                  ),
                ),
                TextFormField(
                  controller: cityCtrl,
                  validator: (v) => v!.trim().isEmpty ? "City required" : null,
                  decoration: const InputDecoration(labelText: "City"),
                ),
                TextFormField(
                  controller: stateCtrl,
                  validator: (v) => v!.trim().isEmpty ? "State required" : null,
                  decoration: const InputDecoration(labelText: "State"),
                ),
                TextFormField(
                  controller: zipCtrl,
                  validator: (v) => v!.length < 5 ? "Valid ZIP required" : null,
                  decoration: const InputDecoration(labelText: "ZIP Code"),
                ),
                CheckboxListTile(
                  title: const Text("Default Address"),
                  value: isDefault,
                  onChanged: (v) => setState(() => isDefault = v ?? false),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final data = {
                  'user_id': user!.id,
                  'street': streetCtrl.text.trim(),
                  'city': cityCtrl.text.trim(),
                  'state': stateCtrl.text.trim(),
                  'zip_code': zipCtrl.text.trim(),
                  'is_default': isDefault,
                };
                if (isEdit) {
                  await Supabase.instance.client
                      .from('addresses')
                      .update(data)
                      .eq('id', addr['id']);
                } else {
                  await Supabase.instance.client.from('addresses').insert(data);
                }
                Navigator.pop(context);
                loadAllData();
              }
            },
            child: Text(isEdit ? "Update" : "Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null)
      return const Scaffold(body: Center(child: Text("Please log in")));
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: "Profile"),
            Tab(text: "Addresses"),
            Tab(text: "Payment"),
            Tab(text: "Orders"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          // PROFILE TAB
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          profile?['avatar_url']?.isNotEmpty == true
                          ? CachedNetworkImageProvider(profile!['avatar_url'])
                          : const AssetImage("assets/default_avatar.png")
                                as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final file = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (file == null) return;

                          final bytes = await file.readAsBytes();
                          final path = 'avatars/${user!.id}.jpg';

                          await Supabase.instance.client.storage
                              .from('avatars')
                              .uploadBinary(
                                path,
                                bytes,
                                fileOptions: const FileOptions(upsert: true),
                              );

                          final url = Supabase.instance.client.storage
                              .from('avatars')
                              .getPublicUrl(path);

                          await Supabase.instance.client
                              .from('profiles')
                              .update({'avatar_url': url})
                              .eq('id', user!.id);

                          setState(() => profile!['avatar_url'] = url);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ListTile(
                title: const Text("Name"),
                subtitle: Text(profile?['full_name'] ?? ""),
                trailing: const Icon(Icons.edit),
                onTap: editProfile,
              ),
              ListTile(
                title: const Text("Email"),
                subtitle: Text(user!.email ?? ""),
              ),
              ListTile(
                title: const Text("Phone"),
                subtitle: Text(profile?['phone'] ?? "Not set"),
                trailing: const Icon(Icons.edit),
                onTap: editProfile,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (r) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),

          // ADDRESSES TAB
          Column(
            children: [
              Expanded(
                child: addresses.isEmpty
                    ? const Center(child: Text("No addresses"))
                    : ListView.builder(
                        itemCount: addresses.length,
                        itemBuilder: (_, i) {
                          final a = addresses[i];
                          return Card(
                            child: ListTile(
                              title: Text(a['street']),
                              subtitle: Text("${a['city']}, ${a['state']}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (a['is_default'])
                                    const Chip(label: Text("Default")),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => manageAddress(addr: a),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => deleteAddress(a['id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: manageAddress,
                  icon: const Icon(Icons.add_location),
                  label: const Text("Add Address"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            ],
          ),

          // PAYMENT TAB (demo)
          Center(child: Text("Payment methods coming soon")),

          // ORDERS TAB
          orders.isEmpty
              ? const Center(child: Text("No orders yet"))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (_, i) {
                    final o = orders[i];
                    return Card(
                      child: ListTile(
                        title: Text(
                          "Order #${o['id'].toString().substring(0, 8).toUpperCase()}",
                        ),
                        subtitle: Text(
                          "₦${o['total_amount']} • ${o['status']}",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
