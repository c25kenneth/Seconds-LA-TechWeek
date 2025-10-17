import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:replate/Firebase/AuthFunctions.dart';
import 'package:replate/home/AddListing.dart';
import 'package:replate/home/ListingInfoPage.dart';
import 'package:replate/onboarding/Welcome.dart';
import 'package:replate/widgets/CallToActionCard.dart';
import 'package:replate/widgets/LoadingScreen.dart';
import 'package:replate/widgets/TopBarFb4.dart';

class SupplierHome extends StatefulWidget {
  const SupplierHome({super.key});

  @override
  State<SupplierHome> createState() => _SupplierHomeState();
}

class _SupplierHomeState extends State<SupplierHome> {
  Color _statusColor(String status) {
    switch (status) {
      case "Available":
        return const Color(0xFF4CAF50);
      case "Reserved":
        return const Color(0xFFFFB300);
      case "Donated":
        return Colors.grey;
      default:
        return Colors.black54;
    }
  }

  FirebaseFirestore _db = FirebaseFirestore.instance; 
  FirebaseAuth _auth = FirebaseAuth.instance; 
  GoogleAuthService _googleAuthService = GoogleAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddListing(uid: _auth.currentUser!.uid,)));
        },
        child: const Icon(Icons.add, color: Colors.white,),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: _db.collection('users').doc(_auth.currentUser!.uid).snapshots(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.hasData) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TopBarFb4(
                        title: "Organization:",
                        upperTitle: asyncSnapshot.data!["organizationName"],
                        onTapMenu: () async {
                          await signOutUser();
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Welcome()), (Route<dynamic> r) => false);
                        },
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> AddListing(uid: _auth.currentUser!.uid,)));
                        },
                        child: CallToActionCard(
                          actionString: "➕ Add a New \nListing",
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Your Active Listings",
                        style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 16),

                      StreamBuilder<QuerySnapshot>(
                        stream: _db
                            .collection('listings')
                            .where('supplierUID', isEqualTo: _auth.currentUser!.uid)
                            .snapshots(),
                        builder: (context, listingSnapshot) {
                          if (listingSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          
                          if (!listingSnapshot.hasData || listingSnapshot.data!.docs.isEmpty) {
                            return const Text(
                              "You have no active listings yet.",
                              style: TextStyle(color: Colors.grey),
                            );
                          }

                          return Column(
                            children: listingSnapshot.data!.docs.map((doc) {
                              Map<String, dynamic> listing = doc.data() as Map<String, dynamic>;
                              
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => FoodListingDetailPage(
                                      supplierId: listing["supplierUID"],
                                      availability: listing["currentStatus"],
                                      edibilityScore: listing["qualityScore"] ?? "N/A",
                                      title: listing["title"] ?? "No Title",
                                      price: listing["price"] ?? "N/A",
                                      imageURL: listing["imageUrl"] ?? "",
                                      tags: [],
                                      quantity: listing["quantity"] ?? "N/A",
                                      expirationDate: listing["expirationDate"] ?? "N/A",
                                      pickupLocation: listing["pickupLocation"] ?? "N/A",
                                      notes: listing["additionalNotes"] ?? "",
                                    ),
                                  ));
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3E8E7E).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: (listing["imageUrl"] != "") ? Image.network(listing['imageUrl']):const Icon(Icons.inventory_2_outlined,
                                            color: Color(0xFF3E8E7E), size: 28),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              listing["title"] ?? "No Title",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "Quantity: ${listing["quantity"] ?? "N/A"}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _statusColor(listing["currentStatus"] ?? "Available")
                                                    .withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                listing["currentStatus"] ?? "Available",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: _statusColor(listing["currentStatus"] ?? "Available"),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.more_vert),
                                        onPressed: () {
                                          // More actions: edit / delete / mark donated
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return LoadingScreen();
            }
          }
        ),
      ),
      backgroundColor: const Color(0xFFF8F8F8),
    );
  }
}