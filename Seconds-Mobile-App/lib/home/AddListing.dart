import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:replate/Firebase/FirstoreDatabaseFuncs.dart';

class AddListing extends StatefulWidget {
  final String uid; 
  const AddListing({super.key, required this.uid});

  @override
  State<AddListing> createState() => _AddListingState();
}

class _AddListingState extends State<AddListing> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _quantityController = TextEditingController();
  final _expirationController = TextEditingController();
  final _locationController = TextEditingController();
  final _qualityController = TextEditingController();
  final _notesController = TextEditingController();
  final _priceController = TextEditingController();

  File? _imageFile;
  bool _isAnalyzing = false;

  // Replace with your Gemini API key
  final String _geminiApiKey = dotenv.env['GEMINI_API_KEY']!;

  Future<void> _pickImage() async {
    // Show modern bottom sheet to choose between camera or gallery
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to add your image',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 85);
    
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      
      _analyzeImageWithGemini();
    }
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 36,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _analyzeImageWithGemini() async {
  if (_imageFile == null) return;

  setState(() => _isAnalyzing = true);

  _showAnalyzingDialog();

  try {
    final bytes = await _imageFile!.readAsBytes();
    final base64Image = base64Encode(bytes);

    String mimeType = 'image/jpeg';
    final path = _imageFile!.path.toLowerCase();
    if (path.endsWith('.png')) {
      mimeType = 'image/png';
    } else if (path.endsWith('.webp')) {
      mimeType = 'image/webp';
    }

    final response = await http.post(
      Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$_geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    'Analyze this food image and provide the following information in JSON format:\n'
                    '{\n'
                    '  "title": "name of the food item",\n'
                    '  "quantity": "estimated quantity (e.g., 10 lbs, 5 kg, 20 pieces)",\n'
                    '  "expiration": "suggested expiration date from today (e.g., 7 days, 2 weeks)",\n'
                    '  "notes": "brief description including freshness, appearance, and any notable features",\n'
                    '  "funFact": "an interesting or fun fact about this food. Start with the text "Fun Fact!,""\n'
                    '  "qualityScore: "arbitrary score out of 10 determining edibility of the food."\n'
                    '}\n'
                    'Respond ONLY with valid JSON, no other text or markdown formatting. For quantity, expiration date, and qualityScore, ONLY GIVE THE NUMER AND UNIT. NO OTHER TEXT'
              },
              {
                'inline_data': {
                  'mime_type': mimeType,
                  'data': base64Image
                }
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.4,
          'topK': 32,
          'topP': 1,
          'maxOutputTokens': 2048,
        }
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['candidates'] == null || data['candidates'].isEmpty) {
        throw Exception('No candidates in response');
      }

      final text = data['candidates'][0]['content']['parts'][0]['text'];
      print('Gemini response text: $text');
      
      String jsonText = text.trim();
      
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      
      jsonText = jsonText.trim();
      print('Cleaned JSON: $jsonText');
      
      final foodData = jsonDecode(jsonText);


      if (mounted) Navigator.of(context).pop();


      await _showFunFactDialog(foodData['funFact'] ?? 'This looks delicious!');


      setState(() {
        _titleController.text = foodData['title'] ?? '';
        _quantityController.text = foodData['quantity'] ?? '';
        _expirationController.text = foodData['expiration'] ?? '';
        _notesController.text = foodData['notes'] ?? '';
        _qualityController.text = foodData["qualityScore"] ?? ""; 
      });
    } else {
      print('Error response: ${response.body}');
      if (mounted) Navigator.of(context).pop();
      _showErrorDialog('Error ${response.statusCode}: ${response.body}');
    }
  } catch (e, stackTrace) {
    print('Error analyzing image: $e');
    print('Stack trace: $stackTrace');
    if (mounted) Navigator.of(context).pop();
    _showErrorDialog('Error: $e');
  } finally {
    if (mounted) {
      setState(() => _isAnalyzing = false);
    }
  }
}

void _showErrorDialog([String? errorMessage]) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (context) => Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Oops!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'We couldn\'t analyze the image.\nPlease fill in the details manually.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showAnalyzingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(seconds: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: Transform.rotate(
                      angle: value * 6.28 * 2,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  setState(() {});
                },
              ),
              const SizedBox(height: 28),
              const Text(
                'Analyzing your food',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'AI is working its magic ✨',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFunFactDialog(String funFact) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.3),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -50,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF2E7D32).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2E7D32).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Text(
                              '💡',
                              style: TextStyle(fontSize: 44),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                      ).createShader(bounds),
                      child: const Text(
                        'Finished!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8F4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        funFact,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Awesome! 🎉',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitListing() async {
    if (_formKey.currentState!.validate()) {
      await addListing(FieldValue.serverTimestamp(), _titleController.value.text, _quantityController.value.text, _expirationController.value.text, _locationController.value.text, _notesController.value.text, widget.uid, _qualityController.value.text, _priceController.value.text, _imageFile);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          "Add New Listing",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 🖼 Minimal Image Upload
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                        width: 1.2,
                      ),
                    ),
                    child: _imageFile == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 42, color: accent),
                                const SizedBox(height: 8),
                                Text(
                                  "Tap to add an image",
                                  style: TextStyle(
                                      color: accent,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 180,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                // 🧾 Text fields (flat, no outlines)
                _buildField(_titleController, "Title", "e.g., Fresh Apples"),
                const SizedBox(height: 18),
                _buildField(_priceController, "Price", "e.g., \$9.99"),
                const SizedBox(height: 18),
                _buildField(_quantityController, "Quantity", "e.g., 25 lbs"),
                const SizedBox(height: 18),
                _buildField(_expirationController, "Expiration Date",
                    "e.g., Oct 25, 2025"),
                const SizedBox(height: 18),
                _buildField(_locationController, "Pickup Location",
                    "e.g., 123 Green Market St"),
                const SizedBox(height: 18),
                _buildField(_qualityController, "Quality Score",
                    "e.g., 8 (out of 10)", readOnly: true),
                const SizedBox(height: 18),
                _buildField(_notesController, "Additional Notes (optional)",
                    "Any details or conditions",
                    maxLines: 3),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: _submitListing,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Create Listing",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
  TextEditingController controller,
  String label,
  String hint, {
  int maxLines = 1,
  bool readOnly = false,
}) {
  return TextFormField(
    controller: controller,
    maxLines: maxLines,
    readOnly: readOnly,
    validator: (v) => v!.isEmpty && !label.contains("(optional)")
        ? "Please enter $label".toLowerCase()
        : null,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
      hintStyle: const TextStyle(color: Colors.black26),
      labelStyle: const TextStyle(color: Colors.black87),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
      ),
    ),
  );
}

  @override
  void dispose() {
    _titleController.dispose();
    _quantityController.dispose();
    _expirationController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _qualityController.dispose();
    _priceController.dispose(); 
    super.dispose();
  }
}