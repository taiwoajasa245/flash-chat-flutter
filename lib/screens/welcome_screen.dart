import 'package:flash_chat_flutter/component/rounded_button.dart';
import 'package:flash_chat_flutter/screens/login_screen.dart';
import 'package:flash_chat_flutter/screens/registration_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    animation = ColorTween(begin: Colors.blueGrey, end: Colors.black12)
        .animate(controller);
    controller.forward();

    // controller.reverse(from: 1.0); // start from 1.0 down to 0.0

    // to make the animation loop we say
    // animation.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     controller.reverse(from: 1.0);
    //   } else if (status == AnimationStatus.dismissed) {
    //     controller.forward();
    //   }
    // });

    controller.addListener(() {
      setState(() {});
      // print(animation.value);
    });
  }

  // make sure you use this when looping an animation
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 60,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Flash Chat',
                      textStyle: const TextStyle(
                        fontSize: 45.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      speed: const Duration(milliseconds: 300),
                    ),
                  ],
                  repeatForever: true,
                ),
              ],
            ),
            const SizedBox(
              height: 48.0,
            ),

            // login button
            RoundedButton(
              color: Colors.lightBlueAccent,
              text: 'Log In',
              onClick: () {
                //Go to login screen.
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),

            // Register Button
            RoundedButton(
              text: 'Register',
              color: Colors.blueAccent,
              onClick: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
