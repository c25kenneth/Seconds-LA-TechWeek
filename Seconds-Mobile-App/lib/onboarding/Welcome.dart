import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:replate/onboarding/RoleSelectionPage.dart';
import 'package:replate/onboarding/SignIn.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenDimensions = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 60),
            
                Text(
                  "Seconds",
                  style: GoogleFonts.quicksand(
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
            
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/images/ReplateLogo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            
                Text(
                  "Give good food a second chance",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
            
                const SizedBox(height: 16),
            
                Text(
                  "Rehoming food, rethinking waste",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
            
                const SizedBox(height: 20),
            
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => RoleSelectionPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      "Get Started →",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
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
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignInPage()));
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
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
