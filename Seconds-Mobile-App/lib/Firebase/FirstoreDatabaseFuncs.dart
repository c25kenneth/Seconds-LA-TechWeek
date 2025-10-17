import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

FirebaseFirestore _db = FirebaseFirestore.instance; 
FirebaseAuth _auth = FirebaseAuth.instance; 
FirebaseStorage _storage = FirebaseStorage.instance;

dynamic addListing(FieldValue timestamp, String title, String quantity, String expirationDate, String pickupLocation, String additionalNotes, String uid, String qualityScore, String price, File? imageFile,) async {
  try {
    String? imageUrl;
    if (imageFile != null) {
      String fileName = 'listings/${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      UploadTask uploadTask = _storage.ref(fileName).putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      imageUrl = await snapshot.ref.getDownloadURL();
    }
    DocumentReference<Map<String, dynamic>> res = await _db.collection("listings").add({
      "listingAdded": timestamp,
      "title": title, 
      "quantity": quantity, 
      "expirationDate": expirationDate, 
      "pickupLocation": pickupLocation, 
      "additionalNotes": additionalNotes, 
      "supplierUID": uid,
      "currentStatus": "Available",
      "qualityScore": qualityScore,
      "price": price,
      "imageUrl": imageUrl,
    }); 

    return res; 
  } catch (e) {
    print(e.toString());

    return "Error adding listing";  
  }
}