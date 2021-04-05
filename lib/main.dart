import 'package:dev_try/login.dart';
import 'package:dev_try/utils/auth.dart';
import 'package:dev_try/dashboard.dart';
import 'package:dev_try/utils/sample.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirestoreService _db = FirestoreService();

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => UserRepository.instance(),
          ),
          StreamProvider(
            create: (BuildContext context) => _db.getPosts(),
          ),
        ],
        child: Consumer(
          builder: (BuildContext context, UserRepository user, _) {
            switch (user.status) {
              case Status.Uninitialized:
                return Splash();
              case Status.Unauthenticated:
                return Dashboard(user: user.user);
              case Status.Authenticating:
                return LoginPage();
              case Status.Authenticated:
                return Dashboard(user: user.user);
            }
          },
        ));
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Text("Splash Screen"),
      ),
    );
  }
}
