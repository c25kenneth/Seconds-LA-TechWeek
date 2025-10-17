import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:replate/onboarding/SignIn.dart';
import 'package:replate/onboarding/SignUp.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  void _showOrganizationDialog(BuildContext context, String role) {
    final TextEditingController orgController = TextEditingController();
    
    showDialog(
  context: context,
  barrierColor: Colors.black.withOpacity(0.35),
  builder: (BuildContext dialogContext) {
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.96),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🌿 Header
            Icon(
              Icons.eco_outlined,
              color: const Color(0xFF2E7D32),
              size: 40,
            ),
            const SizedBox(height: 12),

            Text(
              "Organization Name",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B5E20),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Please enter your organization name below to continue.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.5,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 22),

            TextField(
              controller: orgController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[50],
                hintText: "e.g., Green Valley Farm",
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey[400],
                ),
                prefixIcon: const Icon(Icons.business_outlined, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF2E7D32),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: GoogleFonts.inter(fontSize: 15.5),
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (orgController.text.trim().isNotEmpty) {
                      Navigator.of(dialogContext).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpPage(
                            role: role,
                            organizationName: orgController.text.trim(),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Join Replate",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Choose your role to get started",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              
              const SizedBox(height: 48),
              
              buildRoleCard(
                icon: Icons.store,
                title: "Supplier",
                description: "List your surplus or imperfect food items to be picked up by buyers",
                color: const Color(0xFF2E7D32),
                onTap: () {
                  _showOrganizationDialog(context, 'Supplier');
                },
              ),
              
              const SizedBox(height: 20),
              
              buildRoleCard(
                icon: Icons.shopping_bag,
                title: "Buyer",
                description: "Browse available food listings and help reduce food waste",
                color: const Color(0xFF43A047),
                onTap: () {
                  _showOrganizationDialog(context, 'Buyer');
                },
              ),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SignInPage()));
                    },
                    child: Text(
                      "Sign In",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildRoleCard({
  required IconData icon,
  required String title,
  required String description,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.9),
                  color.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}