// import 'package:chat_app/frontend/ui/sign_up.dart';
import 'package:chat_app/ui/screen/sign_up.dart';
import 'package:chat_app/ui/screen/signin_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_app/constant/constant.dart';


class SigninScreen extends StatefulWidget {
   static Route get route => MaterialPageRoute(
        builder: (context) => const SigninScreen(),
      );
  const SigninScreen({Key? key}) : super(key: key);

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  late Animation<double> containerSize;
  late AnimationController animationController;
  Duration animationDuration = Duration(milliseconds: 270);

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);

    animationController =
        AnimationController(vsync: this, duration: animationDuration);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double viewInset = MediaQuery.of(context).viewInsets.bottom;
    double defaultSigninSize = size.height - (size.height * 0.13);
    double defaultSignupSize = size.height - (size.height * 0.09);

    containerSize =
        Tween<double>(begin: size.height * 0.1, end: defaultSignupSize).animate(
            CurvedAnimation(parent: animationController, curve: Curves.linear));

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            //decoration
            Positioned(
                //right side
                top: 150,
                right: -50,
                child: Container(
                    width: 62,
                    height: 500,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: kPrimaryColor,
                    ))),
            //left side
            Positioned(
                top: 40,
                left: -50,
                child: Container(
                    width: 62,
                    height: 500,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: kPrimaryColor))),

            // Cancel Button
            AnimatedOpacity(
              opacity: isLogin ? 0.0 : 1.0,
              duration: animationDuration,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: size.width,
                  height: size.height * 0.12,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: isLogin
                        ? null
                        : () {
                            animationController.reverse();
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ),

            // Login Form
            SignInForm(
                isLogin: isLogin,
                animationDuration: animationDuration,
                size: size,
                defaultSigninSize: defaultSigninSize),

            // Register Container

            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                if (viewInset == 0 && isLogin) {
                  return buildRegisterContainer();
                } else if (!isLogin) {
                  return buildRegisterContainer();
                }

                //Returning empty container to hide the widget
                return Container();
              },
            ),

            // Signup

            SignupForm(
                isLogin: isLogin,
                animationDuration: animationDuration,
                size: size,
                defaultSigninSize: defaultSigninSize)
          ],
        ),
      ),
    );
  }

  Widget buildRegisterContainer() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: containerSize.value,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(100),
              topRight: Radius.circular(100),
            ),
            color: kBackgroundColor),
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: !isLogin
              ? null
              : () {
                  animationController.forward();
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
          child: isLogin
              ? const Text(
                  "Don't have an account ? Signup",
                  style: TextStyle(
                    fontFamily: 'Roboto-Regular',
                    fontWeight: FontWeight.w600,
                    color: kPrimaryColor,
                    fontSize: 14,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
