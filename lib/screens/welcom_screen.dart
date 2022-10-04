import 'package:flutter/material.dart';
import 'package:loction/components/colors.dart';
import 'package:loction/screens/login_screen.dart';
import 'package:loction/screens/registration_screen.dart';
import 'package:loction/widgets/tabbutton_widget.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animationcurve;
  bool s = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      controller = AnimationController(
        duration: Duration(seconds: 5),
        vsync: this,
      );
      animationcurve =
          CurvedAnimation(parent: controller, curve: Curves.decelerate);
      controller.forward();

      controller.addListener(() {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: s,
          title: Text("Chat app"),
          backgroundColor: Colors.teal),
      backgroundColor: Colors.black26,
      body: Container(
        constraints: BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 170, 10, 10),
                child: Text(
                  "Let's Get Start",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 50.0,
                      fontWeight: FontWeight.w900),
                ),
              ),
              SizedBox(
                height: 22.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: Hero(
                  tag: "button",
                  child: TabButton(
                    btnColor: PalletteColors.primaryRed,
                    btnTxtColor: Colors.white,
                    btnText: "Create new account",
                    btnFunction: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegistrationScreen(),
                          ));
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: Hero(
                  tag: "button2",

                  child: TabButton(
                    btnColor: PalletteColors.lightBlue,
                    btnTxtColor: Colors.black,
                    btnText: "Login with email",
                    btnFunction: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          )
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
