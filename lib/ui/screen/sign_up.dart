import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../components/rounded_button.dart';
import '../../../components/rounded_input.dart';
import '../../../components/rounded_password.dart';
import 'home_chat.dart';
import '../../../app.dart';

class SignupForm extends StatefulWidget {
  SignupForm({
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
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final auth = firebase.FirebaseAuth.instance;
  final functions = FirebaseFunctions.instance;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _profiePictureController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  bool _loading = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      try {
        //Authenticate with Firebase
        final creds =
            await firebase.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        final user = creds.user;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User is empty')),
          );
          return;
        }

        // Set Firebase display name and profile picture
        List<Future<void>> futures = [
          creds.user!.updateDisplayName(_nameController.text),
          if (_profiePictureController.text.isNotEmpty)
            creds.user!.updatePhotoURL(_profiePictureController.text)
        ];

        await Future.wait(futures);

        // Create Stream user and get token using Firebase Functions
        final callable = functions.httpsCallable('createStreamUserAndGetToken');
        final results = await callable();

        // Connect user to Stream and set user data
        final client = StreamChatCore.of(context).client;
        await client.connectUser(
          User(
            id: creds.user!.uid,
            name: _nameController.text,
            image: _profiePictureController.text,
          ),
          results.data,
        );
        //Navigate to home Screen
        await Navigator.of(context).pushReplacement(HomeScreen.route);
      } on firebase.FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Auth error'),
          ),
        );
      } catch (e, st) {
        logger.e('Sign up error', e, st);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occured')),
        );
      }
      setState(() {
        _loading = false;
      });
    }
  }

  String? _nameInputValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cannot be empty';
    }
    if (value.length <= 4) {
      return 'Name required upto 4 chracters';
    }
    return null;
  }

  String? _emailInputValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cannot be empty';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Email is not valid !';
    }
    return null;
  }

  String? _passwordInputValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cannot be empty';
    }
    if (value.length <= 6) {
      return 'Password needs to be longer than 6 chracters';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _profiePictureController.dispose();
    _nameController.dispose();
    super.dispose();

  }

  // signUp() async {
  //   try {
  //     firebase.UserCredential userCredential =
  //         await firebase.FirebaseAuth.instance.createUserWithEmailAndPassword(
  //             email: _emailController.text, password: _passwordController.text);
  //     var authCredential = userCredential.user;

  //     print(authCredential!.uid);

  //     if (authCredential.uid.isNotEmpty) {
  //     } else {
  //       Fluttertoast.showToast(msg: "Something is wrong ");
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'weak-password') {
  //       Fluttertoast.showToast(msg: "The password provided is to weak.");
  //     } else if (e.code == 'email-already-in-use') {
  //       Fluttertoast.showToast(
  //           msg: "The account already exists for that email.");
  //     }
  //     if (e.code == 'user-not-found') {
  //       Fluttertoast.showToast(msg: "'No User found for that email !");
  //     } else if (e.code == 'wrong-password') {
  //       Fluttertoast.showToast(msg: "Wrong Password provided for that user. ");
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.isLogin ? 0.0 : 1.0,
      duration: widget.animationDuration * 5,
      child: Visibility(
        visible: !widget.isLogin,
        child: Align(
          alignment: Alignment.center,
           child: SingleChildScrollView(
            child: SizedBox(
              width: widget.size.width,
              height: widget.defaultSigninSize,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome To Tenures',
                    style: TextStyle(
                        fontFamily: 'Roboto-Medium',
                        fontWeight: FontWeight.bold,
                        fontSize: 24),
                  ),
                  const SizedBox(height: 30),
                  SvgPicture.asset('assets/images/signup.svg',
                      height: 150, width: 150, fit: BoxFit.scaleDown),
                  const SizedBox(height: 20),
                  Rounded_input(
                    controller: _nameController,
                    validator: _nameInputValidator,
                    icon: Icons.face_rounded,
                    size: widget.size,
                    hint: 'name',
                  ),
                  Rounded_input(
                    controller: _emailController,
                    validator: _emailInputValidator,
                    icon: Icons.mail,
                    size: widget.size,
                    hint: 'Username',
                  ),
                  
                  Rounded_password(
                      controller: _passwordController,
                      validator: _passwordInputValidator,
                      size: widget.size,
                      icon: Icons.lock,
                      hint: 'Password'),
                  const SizedBox(height: 20),
                  
                  const RoundedButton(title: 'SignUp'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
