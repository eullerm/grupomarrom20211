import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:grupomarrom20211/widgets/title.dart';

class OtpTimer extends StatefulWidget {
  @override
  _OtpTimerState createState() => _OtpTimerState();
}

class _OtpTimerState extends State<OtpTimer> {
  static const maxSeconds = 10;
  int seconds = maxSeconds;
  Timer? timer;

  startCountdown() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else
        stopCountdown(reset: false);
    });
  }

  void resetCountdown() => setState(() => seconds = maxSeconds);

  void stopCountdown({bool reset = true}) {
    if (reset) {
      resetCountdown();
    }
    timer?.cancel();
  }

  @override
  void initState() {
    startCountdown();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 80,
        height: 80,
        child: Stack(fit: StackFit.expand, children: [
          CircularProgressIndicator(
            value: seconds / maxSeconds,
            valueColor: AlwaysStoppedAnimation(Colors.grey[400]),
            strokeWidth: 12,
            backgroundColor: Colors.lightBlue[900],
          ),
          Align(
              alignment: Alignment(0, 0.5),
              child: TextTitle(
                title: '$seconds',
                textStyle: TextStyles.appTitle,
              ))
        ]));
  }
}
