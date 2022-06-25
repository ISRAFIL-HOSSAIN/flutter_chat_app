import 'package:chat_app/ui/screen/home_chat.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../../../components/rounded_button.dart';
import '../../../components/rounded_input.dart';
import '../../../components/rounded_password.dart';

class SignInForm extends StatefulWidget {
  // static Route get route => MaterialPageRoute(
  //       builder: (context) =>  SignInForm(),
  //   );

  const SignInForm({
    Key? key,
    required this.isLogin,
    required this.animationDuration,
    required this.size,
    required this.defaultSigninSize,
  }) : super(key: key);

  final bool isLogin;
  final Duration animationDuration;
  final Size size;
  final double defaultSigninSize;

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final auth = firebase.FirebaseAuth.instance;

  final functions = FirebaseFunctions.instance;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _profilePictureController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();
  final _emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  bool _loading = false;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      try {
        //Authenticate with Firebase
        final creds = await firebase.FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);
        final user = creds.user;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User is empty')),
          );
          return;
        }

        // Get Stream user token from Firebase Function
        final callable = functions.httpsCallable('getStreamUserToken');
        final results = await callable();

        //Connect Stream user
        final client = StreamChatCore.of(context).client;
        await client.connectUser(
          User(id: creds.user!.uid),
          results.data,
        );
        //Navigate to home screen
        await Navigator.of(context).pushReplacement(HomeScreen.route);
      } on firebase.FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? 'Auth error'),
        ));  
        
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: !widget.isLogin ? 0.0 : 1.0,
      duration: widget.animationDuration * 4,
      child: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            width: widget.size.width,
            height: widget.defaultSigninSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back To Tenures',
                  style: TextStyle(
                      fontFamily: 'Risque-Regular',
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
                SizedBox(height: 30),
                SvgPicture.asset('assets/images/signin.svg',
                    width: 230, fit: BoxFit.scaleDown),
                SizedBox(height: 20),
                Rounded_input(
                  controller: _emailController,
                  icon: Icons.mail,
                  size: widget.size,
                  hint: 'Username',
                  validator: (String? value) {},
                ),
                Rounded_password(
                    controller: _passwordController,
                    // validator: ,
                    size: widget.size,
                    icon: Icons.lock,
                    hint: 'Password', validator: (String? value) {  },),
                SizedBox(height: 20),
                RoundedButton(title: 'Login'),
                SizedBox(height: 30),
                Center(
                  child: Text(
                    'Or Continue With',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontFamily: 'Roboto-Medium',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _socialMediaIntegrationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialMediaIntegrationButtons() {
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.only(right: 20, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              print('Google Pressed');
            },
            child: Image.asset(
              'assets/images/google.png',
              width: 100,
            ),
          ),
          GestureDetector(
            onTap: () {
              print('Facebook pressed');
            },
            child: Image.asset(
              'assets/images/facebook.png',
              width: 100,
            ),
          ),
        ],
      ),
    );
  }
}
