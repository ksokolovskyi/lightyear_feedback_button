import 'package:flutter/material.dart';
import 'package:lightyear_feedback_button/button.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: FeedbackButton(
                  onPressed: () {},
                ),
              ),
            ),
            const Positioned(
              right: 15,
              bottom: -25,
              child: FlutterLogo(
                size: 110,
                style: FlutterLogoStyle.horizontal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
