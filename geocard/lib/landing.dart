import 'package:flutter/material.dart';
import 'package:geocard/widgets/background.dart';

class Landing extends StatefulWidget {
  Landing();

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
    );
  }

  _body(context) {
    return Container(
      child: Center(
        child: Stack(
          children: <Widget>[
            Background(),
            Text("Geocard"),
          ],
        ),
      ),
    );
  }
}
