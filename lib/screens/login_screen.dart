import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loction/components/colors.dart';
import '../widgets/tabbutton_widget.dart';
import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  static String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String password;
  late String email;
  final _auth = FirebaseAuth.instance;
  bool _obscureText = true;
  bool _validate = false;
  final _text1 = TextEditingController();
  final _text2 = TextEditingController();

  @override
  void dispose() {
    _text1.dispose();
    _text2.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text("Login with email"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: emailInput(),
              ),
              SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: passInput(),
              ),
              SizedBox(
                height: 24.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: Hero(
                  tag: "button2",
                  child: TabButton(
                    btnColor: FixColors.primaryTeal,
                    btnTxtColor: Colors.white,
                    btnText: "Log In",
                    btnFunction: () async {
                      _text1.text.isEmpty
                          ? _validate = false
                          : _validate = true;
                      _text2.text.isEmpty
                          ? _validate = false
                          : _validate = true;
                      setState(() {
                        // showSpinner = true;
                      });

                      try {
                        final loggedInUser =
                            await _auth.signInWithEmailAndPassword(
                                email: email, password: password);
                        if (loggedInUser != null) {
                          Navigator.pushNamed(context, ChatScreen.id);
                          setState(() {
                            // showSpinner = false;
                          });
                        }
                      } catch (e) {
                        print(e);
                      }
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

  Widget emailInput() {
    return Theme(
      child: TextField(
        onChanged: (value) {
          email = value;
        },
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: "Email ID",
          errorText: _validate ? 'Please enter your email' : null,
          prefixIcon: Icon(Icons.mail_outline),
          labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          errorStyle: TextStyle(fontSize: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              )),
        ),
        textInputAction: TextInputAction.next,
      ),
      data: Theme.of(context).copyWith(
        accentColor: FixColors.primaryTeal,
      ),
    );
  }

  Widget passInput() {
    return Theme(
      data: Theme.of(context).copyWith(
        accentColor: FixColors.primaryTeal,
      ),
      child: TextField(
        onChanged: (value) {
          password = value;
        },
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.vpn_key,
          ),
          labelText: "Password",
          errorText: _validate ? 'Password Can\'t Be Empty' : null,
          labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              )),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          errorStyle: TextStyle(fontSize: 14),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              color: FixColors.primaryGrey,
            ),
            onPressed: _toggle,
          ),
        ),
        textInputAction: TextInputAction.done,
        obscureText: _obscureText,
      ),
    );
  }
}
