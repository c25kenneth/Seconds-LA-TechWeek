import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:replate/Firebase/AuthFunctions.dart';
import 'package:replate/home/supplier/SupplierHome.dart';
import 'package:replate/onboarding/RoleSelectionPage.dart';
import 'package:replate/widgets/SignInWithApple.dart';
import 'package:replate/widgets/SignInWithGoogle.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  GoogleAuthService _googleAuthService = GoogleAuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
              

                  Text(
                    "Sign In",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
              
                  const SizedBox(height: 16),
              

                  Text(
                    "Welcome back 👋",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 8),
              
                  Text(
                    "Sign in to continue your impact journey.",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
              
                  const SizedBox(height: 40),
              

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // 📩 Email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: GoogleFonts.inter(),
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
              

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: GoogleFonts.inter(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
              
              

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {

                      },
                      child: Text(
                        "Forgot password?",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              
                  SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Implement sign-in logic
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SupplierHome(),), (Route<dynamic> r) => false); 
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Sign In",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              
                  const SizedBox(height: 12),
              
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account?",
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.grey[700],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RoleSelectionPage()));
                        },
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.inter(
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
              
                  const SizedBox(height: 10),
              
                  Row(
                      children: <Widget>[
                          Expanded(
                              child: Divider(thickness: 1.5, color: Colors.grey,)
                          ),       
                          SizedBox(width: 16,),
                          Text("OR"),        
                          SizedBox(width: 16,),
                          Expanded(
                              child: Divider(thickness: 1.5, color: Colors.grey,)
                          ),
                      ]
                    ),
                  GoogleBtn1(onPressed: () async {
                    dynamic signInResult = await _googleAuthService.signInWithGoogleFirebase("", "");

                    if (signInResult.runtimeType != String) {
                      if (signInResult["role"] == "Supplier") {
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SupplierHome()), (Route<dynamic> r) => false);
                      } else if (signInResult["role"] == "Buyer") {
                      }
                    } else {
                      print(signInResult);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RoleSelectionPage()));
                    }
                  }),
                  AppleBtn1(onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
