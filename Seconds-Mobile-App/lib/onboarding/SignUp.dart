import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:replate/Firebase/AuthFunctions.dart';
import 'package:replate/home/consumer/BuyerHome.dart';
import 'package:replate/home/supplier/SupplierHome.dart';
import 'package:replate/onboarding/SignIn.dart';
import 'package:replate/widgets/SignInWithApple.dart';
import 'package:replate/widgets/SignInWithGoogle.dart';

class SignUpPage extends StatefulWidget {
  final String role; 
  final String organizationName; 
  const SignUpPage({super.key, required this.role, required this.organizationName});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  GoogleAuthService _googleAuthService = GoogleAuthService(); 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  

                  Text(
                    "Sign up",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 4,),
                  Text(
                    "as a ${widget.role}".toLowerCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create an account to start your impact journey.",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 24),


                  Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        const SizedBox(height: 20),


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

                  const SizedBox(height: 25),


                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Handle sign up logic here
                          dynamic signUpResult = await _googleAuthService.signInWithGoogleFirebase(widget.role, widget.organizationName);

                          if (signUpResult.runtimeType != String && widget.role == "supplier") {
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SupplierHome()), (Route<dynamic> r) => false);
                          } else if (signUpResult.runtimeType != String && widget.role == "consumer") {
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => BuyerHome()), (Route<dynamic> r) => false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Create Account",
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

                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: Divider(thickness: 1.5, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Text("OR", style: GoogleFonts.inter()),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Divider(thickness: 1.5, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  GoogleBtn1(onPressed: () async {
                    dynamic signUpResult = await _googleAuthService.signInWithGoogleFirebase(widget.role, widget.organizationName);

                          if (signUpResult.runtimeType != String && widget.role == "supplier") {
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SupplierHome()), (Route<dynamic> r) => false);
                          } else if (signUpResult.runtimeType != String && widget.role == "consumer") {
                            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => BuyerHome()), (Route<dynamic> r) => false);
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
