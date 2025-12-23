// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'order_tracking_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({Key? key}) : super(key: key);
//   static final GlobalKey<_ProfileScreenState> profileKey =
//       GlobalKey<_ProfileScreenState>();
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
//   static GlobalKey<_ProfileScreenState> profileKey = GlobalKey();

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
//       // Load profile (create if missing)
//       var p = await Supabase.instance.client
//           .from('profiles')
//           .select()
//           .eq('id', user!.id);
//       if (p.isEmpty) {
//         await Supabase.instance.client.from('profiles').insert({
//           'id': user!.id,
//           'full_name':
//               user!.userMetadata?['full_name'] ??
//               user!.email?.split('@').first ??
//               'User',
//           'email': user!.email,
//           'phone': '',
//           'avatar_url': user!.userMetadata?['avatar_url'] ?? '',
//         });
//         p = await Supabase.instance.client
//             .from('profiles')
//             .select()
//             .eq('id', user!.id);
//       }
//       profile = p.first;

//       // Load addresses
//       final a = await Supabase.instance.client
//           .from('addresses')
//           .select()
//           .eq('user_id', user!.id)
//           .order('is_default', ascending: false);

//       // Load orders
//       final o = await Supabase.instance.client
//           .from('orders')
//           .select('*, order_items(*)')
//           .eq('user_id', user!.id)
//           .order('created_at', ascending: false);

//       setState(() {
//         addresses = List.from(a);
//         orders = List.from(o);
//         isLoading = false;
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
//       }
//       setState(() => isLoading = false);
//     }
//   }

//   // Edit Profile Dialog
//   void _editProfile() {
//     final nameCtrl = TextEditingController(text: profile?['full_name']);
//     final phoneCtrl = TextEditingController(text: profile?['phone']);

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Edit Profile"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameCtrl,
//               decoration: const InputDecoration(labelText: "Full Name"),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: phoneCtrl,
//               decoration: const InputDecoration(labelText: "Phone"),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await Supabase.instance.client
//                   .from('profiles')
//                   .update({
//                     'full_name': nameCtrl.text.trim(),
//                     'phone': phoneCtrl.text.trim(),
//                   })
//                   .eq('id', user!.id);
//               loadData();
//               Navigator.pop(context);
//             },
//             child: const Text("Save"),
//           ),
//         ],
//       ),
//     );
//   }

//   // Address Dialog (Add/Edit)
//   void _manageAddress({Map<String, dynamic>? address}) {
//     final isEdit = address != null;
//     final streetCtrl = TextEditingController(text: address?['street'] ?? '');
//     final cityCtrl = TextEditingController(text: address?['city'] ?? '');
//     final stateCtrl = TextEditingController(text: address?['state'] ?? '');
//     final zipCtrl = TextEditingController(text: address?['zip_code'] ?? '');
//     bool isDefault = address?['is_default'] ?? false;

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(isEdit ? "Edit Address" : "Add Address"),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: streetCtrl,
//                 decoration: const InputDecoration(labelText: "Street"),
//               ),
//               TextField(
//                 controller: cityCtrl,
//                 decoration: const InputDecoration(labelText: "City"),
//               ),
//               TextField(
//                 controller: stateCtrl,
//                 decoration: const InputDecoration(labelText: "State"),
//               ),
//               TextField(
//                 controller: zipCtrl,
//                 decoration: const InputDecoration(labelText: "ZIP"),
//               ),
//               CheckboxListTile(
//                 title: const Text("Default"),
//                 value: isDefault,
//                 onChanged: (v) => setState(() => isDefault = v ?? false),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final data = {
//                 'user_id': user!.id,
//                 'street': streetCtrl.text.trim(),
//                 'city': cityCtrl.text.trim(),
//                 'state': stateCtrl.text.trim(),
//                 'zip_code': zipCtrl.text.trim(),
//                 'is_default': isDefault,
//               };
//               if (isEdit) {
//                 await Supabase.instance.client
//                     .from('addresses')
//                     .update(data)
//                     .eq('id', address['id']);
//               } else {
//                 await Supabase.instance.client.from('addresses').insert(data);
//               }
//               Navigator.pop(context);
//               loadData();
//             },
//             child: Text(isEdit ? "Update" : "Save"),
//           ),
//         ],
//       ),
//     );
//   }

//   // Delete Address
//   void _deleteAddress(String id) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Delete Address?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text("No"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text("Yes"),
//           ),
//         ],
//       ),
//     );
//     if (confirm == true) {
//       await Supabase.instance.client.from('addresses').delete().eq('id', id);
//       loadData();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (user == null)
//       return const Scaffold(body: Center(child: Text("Please log in")));
//     if (isLoading)
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     return Scaffold(
//       key: profileKey,
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
//           // PROFILE TAB — DETAILED
//           ListView(
//             padding: const EdgeInsets.all(20),
//             children: [
//               Center(
//                 child: Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 60,
//                       backgroundImage:
//                           profile?['avatar_url']?.isNotEmpty == true
//                           ? CachedNetworkImageProvider(profile!['avatar_url'])
//                           : const AssetImage("assets/default_avatar.png")
//                                 as ImageProvider,
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: IconButton(
//                         icon: const CircleAvatar(
//                           backgroundColor: Colors.deepPurple,
//                           child: Icon(Icons.camera_alt, color: Colors.white),
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
//               const SizedBox(height: 20),
//               Text(
//                 profile?['full_name'] ?? "User",
//                 style: const TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               Text(
//                 user!.email ?? "",
//                 style: const TextStyle(fontSize: 18),
//                 textAlign: TextAlign.center,
//               ),
//               Text(
//                 profile?['phone'] ?? "No phone",
//                 style: const TextStyle(fontSize: 16, color: Colors.grey),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 30),
//               ElevatedButton.icon(
//                 onPressed: _editProfile,
//                 icon: const Icon(Icons.edit),
//                 label: const Text("Edit Profile"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                 ),
//               ),
//               const SizedBox(height: 20),
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

//           // ADDRESSES TAB — FULL CRUD
//           Column(
//             children: [
//               Expanded(
//                 child: addresses.isEmpty
//                     ? const Center(child: Text("No addresses saved"))
//                     : ListView.builder(
//                         itemCount: addresses.length,
//                         itemBuilder: (_, i) {
//                           final a = addresses[i];
//                           return Card(
//                             child: ListTile(
//                               title: Text(a['street']),
//                               subtitle: Text(
//                                 "${a['city']}, ${a['state']} ${a['zip_code']}",
//                               ),
//                               trailing: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   if (a['is_default'])
//                                     const Chip(
//                                       label: Text("Default"),
//                                       backgroundColor: Colors.green,
//                                     ),
//                                   IconButton(
//                                     icon: const Icon(Icons.edit),
//                                     onPressed: () => _manageAddress(address: a),
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(
//                                       Icons.delete,
//                                       color: Colors.red,
//                                     ),
//                                     onPressed: () => _deleteAddress(a['id']),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: ElevatedButton.icon(
//                   onPressed: _manageAddress,
//                   icon: const Icon(Icons.add_location),
//                   label: const Text("Add New Address"),
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 50),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           // ORDERS TAB — TAP TO TRACK
//           orders.isEmpty
//               ? const Center(child: Text("No orders yet"))
//               : ListView.builder(
//                   itemCount: orders.length,
//                   itemBuilder: (_, i) {
//                     final o = orders[i];
//                     return Card(
//                       margin: const EdgeInsets.all(10),
//                       child: ListTile(
//                         onTap: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => OrderTrackingScreen(order: o),
//                           ),
//                         ),
//                         leading: const Icon(
//                           Icons.shopping_bag,
//                           color: Colors.deepPurple,
//                         ),
//                         title: Text(
//                           "Order #${o['id'].toString().substring(0, 8).toUpperCase()}",
//                         ),
//                         subtitle: Text(
//                           "₦${o['total_amount']} • ${o['status']}",
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
import 'order_tracking_screen.dart';

class ProfileScreen extends StatefulWidget {
  // const ProfileScreen({Key? key}) : super(key: key);
  final int initialSection; // 0 = Profile, 1 = Addresses, 2 = Orders

  const ProfileScreen({Key? key, this.initialSection = 0}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = Supabase.instance.client.auth.currentUser;
  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> addresses = [];
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  // @override
  // void initState() {
  //   super.initState();
  //   if (user != null) loadData();
  // }

  late ScrollController _scrollController;

  @override
  void initState() {
    if (user != null) loadData();
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSection(widget.initialSection);
    });
  }

  void _scrollToSection(int section) {
    final double offset = section * 300.0; // adjust based on section height
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  Future<void> loadData() async {
    if (user == null) return;
    setState(() => isLoading = true);

    try {
      // Load profile
      var p = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user!.id);
      if (p.isEmpty) {
        await Supabase.instance.client.from('profiles').insert({
          'id': user!.id,
          'full_name': user!.email?.split('@').first ?? 'User',
          'email': user!.email,
          'phone': '',
          'avatar_url': '',
        });
        p = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user!.id);
      }
      profile = p.first;

      // Load addresses
      final a = await Supabase.instance.client
          .from('addresses')
          .select()
          .eq('user_id', user!.id)
          .order('is_default', ascending: false);

      // Load orders
      final o = await Supabase.instance.client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', user!.id)
          .order('created_at', ascending: false);

      setState(() {
        addresses = List.from(a);
        orders = List.from(o);
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => isLoading = false);
    }
  }

  // Edit Profile
  void _editProfile() {
    final nameCtrl = TextEditingController(text: profile?['full_name']);
    final phoneCtrl = TextEditingController(text: profile?['phone']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await Supabase.instance.client
                  .from('profiles')
                  .update({
                    'full_name': nameCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                  })
                  .eq('id', user!.id);
              loadData();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // Address Dialog
  void _manageAddress({Map<String, dynamic>? address}) {
    final isEdit = address != null;
    final streetCtrl = TextEditingController(text: address?['street'] ?? '');
    final cityCtrl = TextEditingController(text: address?['city'] ?? '');
    final stateCtrl = TextEditingController(text: address?['state'] ?? '');
    final zipCtrl = TextEditingController(text: address?['zip_code'] ?? '');
    bool isDefault = address?['is_default'] ?? false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Address" : "Add Address"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: streetCtrl,
                decoration: const InputDecoration(labelText: "Street"),
              ),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(labelText: "City"),
              ),
              TextField(
                controller: stateCtrl,
                decoration: const InputDecoration(labelText: "State"),
              ),
              TextField(
                controller: zipCtrl,
                decoration: const InputDecoration(labelText: "ZIP"),
              ),
              CheckboxListTile(
                title: const Text("Default"),
                value: isDefault,
                onChanged: (v) => setState(() => isDefault = v ?? false),
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
                    .eq('id', address['id']);
              } else {
                await Supabase.instance.client.from('addresses').insert(data);
              }
              Navigator.pop(context);
              loadData();
            },
            child: Text(isEdit ? "Update" : "Save"),
          ),
        ],
      ),
    );
  }

  void _deleteAddress(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await Supabase.instance.client.from('addresses').delete().eq('id', id);
      loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null)
      return const Scaffold(body: Center(child: Text("Login required")));
    if (isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // USER INFO SECTION
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: profile?['avatar_url']?.isNotEmpty == true
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
            const SizedBox(height: 20),
            Text(
              profile?['full_name'] ?? "User",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              user!.email ?? "",
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            Text(
              profile?['phone'] ?? "No phone",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit),
              label: const Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 40),

            // ADDRESSES SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Delivery Addresses",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _manageAddress,
                ),
              ],
            ),
            const Divider(),
            addresses.isEmpty
                ? const Text("No addresses saved")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addresses.length,
                    itemBuilder: (_, i) {
                      final a = addresses[i];
                      return Card(
                        child: ListTile(
                          title: Text(a['street']),
                          subtitle: Text(
                            "${a['city']}, ${a['state']} ${a['zip_code']}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (a['is_default'])
                                const Chip(label: Text("Default")),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _manageAddress(address: a),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteAddress(a['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 40),

            // ORDERS SECTION
            const Text(
              "Order History",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            orders.isEmpty
                ? const Text("No orders yet")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    itemBuilder: (_, i) {
                      final o = orders[i];
                      return Card(
                        child: ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderTrackingScreen(order: o),
                            ),
                          ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
