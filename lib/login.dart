import 'package:dev_try/utils/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  final _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRepository>(context);
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      key: _key,
      body: Center(
        child: user.status == Status.Authenticating
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0, right: 0.0),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 40.0,
                          spreadRadius: 0.0,
                          offset: Offset(
                            0.0,
                            -20.0,
                          ),
                        )
                      ],
                    ),
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: new IconButton(
                              icon: Image.asset('assets/images/gg.png'),
                              iconSize: 40,
                              onPressed: () async {
                                print("Google clicked");
                                if (!await user.signInWithGoogle())
                                  _key.currentState.showSnackBar(SnackBar(
                                    content: Text("Something is wrong"),
                                  ));
                                // Get.to(Third());
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
