import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:worldfavor/auth_control.dart';
import 'package:worldfavor/splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login_page.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().then((value) => Get.put(AuthController()));
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        primarySwatch: Colors.brown,
      ),
      home: AnimatedSplashScreen(
          splash: Icons.home,
          duration: 3000,
          splashTransition: SplashTransition.rotationTransition,
          backgroundColor: Colors.grey
          , nextScreen: LoginPage()),
    );
  }
}

