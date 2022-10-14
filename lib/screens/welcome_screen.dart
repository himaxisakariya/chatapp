import 'package:flutter/material.dart';
import 'package:loction/components/colors.dart';
import 'package:loction/screens/login_screen.dart';
import 'package:loction/screens/registration_screen.dart';
import '../widgets/tabbutton_widget.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animationcurve;

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
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: Text(
          "Chat App",
          style: TextStyle(fontSize: 35),
        ),
      ),
      backgroundColor: Colors.black,
      body: Container(
        constraints: BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 50, right: 70, top: 70),
                child: Text(
                  "Let's start..",
                  style:
                      TextStyle(color: Colors.white, fontSize: 45, height: 1.5),
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
                    btnColor: FixColors.primaryTeal,
                    btnTxtColor: Colors.white,
                    btnText: "Create new account",
                    btnFunction: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return RegistrationScreen();
                        },
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
                    btnColor: FixColors.lightBlue,
                    btnTxtColor: Colors.black,
                    btnText: "Login with email",
                    btnFunction: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return LoginScreen();
                        },
                      ));
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
