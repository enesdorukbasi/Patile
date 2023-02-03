import 'package:flutter/material.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/views/auth_pages/authentication_control.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<AuthenticationService>(
      create: (_) => AuthenticationService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Patile',
        theme: ThemeData(
          backgroundColor: Colors.orange[100],
          primaryColor: Colors.orange,
          primaryColorLight: Colors.orange[300],
          primaryColorDark: Colors.orange[900],
        ),
        home: const AuthenticationControlPage(),
      ),
    );
  }
}
