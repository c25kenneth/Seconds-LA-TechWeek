import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:replate/firebase_options.dart';
import 'package:replate/onboarding/Welcome.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seconds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
      ),
      home: Welcome(),
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(boldText: false),
          child: child!,
    ),
    );
  }
}

