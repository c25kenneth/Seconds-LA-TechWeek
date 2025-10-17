import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class FoodListingDetailPage extends StatefulWidget {
  final String title;
  final String imageURL;
  final List<String> tags;
  final String edibilityScore; 
  final String quantity;
  final String expirationDate;
  final String pickupLocation;
  final String notes;
  final String availability; 
  final String supplierId; 
  final String price; 

  const FoodListingDetailPage({
    super.key,
    required this.title,
    required this.imageURL,
    required this.tags,
    required this.edibilityScore,
    required this.quantity,
    required this.expirationDate,
    required this.pickupLocation,
    required this.notes,
    required this.availability, 
    required this.supplierId,
    required this.price, 
  });

  @override
  State<FoodListingDetailPage> createState() => _FoodListingDetailPageState();
}

class _FoodListingDetailPageState extends State<FoodListingDetailPage> {

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final primary = Colors.green.shade600;
    final lightGreen = Colors.green.shade100;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight * 0.4,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(Ionicons.arrow_back_outline, color: primary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: (widget.imageURL.isEmpty)
                    ? Image.asset(
                        "assets/images/kale-1681646_1920-1024x767.avif",
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        widget.imageURL,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/kale-1681646_1920-1024x767.avif',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    children: widget.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: lightGreen.withOpacity(0.4),
                            labelStyle: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoItem(
                        icon: Ionicons.fast_food_outline,
                        label: "Edibility",
                        value: widget.edibilityScore,
                        iconColor: primary,
                      ),
                      _InfoItem(
                        icon: Ionicons.pricetag_outline,
                        label: "Price",
                        value: "\$" + widget.price,
                        iconColor: primary,
                      ),
                      _InfoItem(
                        icon: Ionicons.cube_outline,
                        label: "Quantity",
                        value: widget.quantity,
                        iconColor: primary,
                      ),
                      _InfoItem(
                        icon: Ionicons.time_outline,
                        label: "Expires",
                        value: widget.expirationDate,
                        iconColor: primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Pickup Location",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Ionicons.location_outline,
                          size: 22, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.pickupLocation,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (widget.notes.isNotEmpty) ...[
                    Text(
                      "Additional Notes",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.notes,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],

                  (widget.supplierId != FirebaseAuth.instance.currentUser!.uid) ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (widget.availability != "Available")
                          ? null
                          : () {
                              // setState(() {
                              //   isReserved = true;
                              // });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Listing reserved successfully 🥦'),
                                ),
                              );
                            },
                      icon: const Icon(Ionicons.cart_outline, size: 22),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: Text(
                          (widget.availability != "Available") ? "Reserved ✅" : "Reserve this Listing",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (widget.availability != "Available") ? Colors.grey : primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ) : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                              // setState(() {
                              //   isReserved = true;
                              // });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Listing reserved successfully 🥦'),
                                ),
                              );
                            },
                      icon: const Icon(Ionicons.trash_bin_outline, size: 22),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: Text(
                          "Remove this Listing",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: iconColor),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
