// Widget Timer, usado na tela da partida

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:grupomarrom20211/widgets/title.dart';

import 'button.dart';

class OtpTimer extends StatefulWidget {
  final Function whenTimeIsOver;
  final Function whenTimeIsPaused;
  OtpTimer({required this.whenTimeIsOver, required this.whenTimeIsPaused, Key? key}) : super(key: key);
  @override
  _OtpTimerState createState() => _OtpTimerState();
}

class _OtpTimerState extends State<OtpTimer> {
  static const maxSeconds = 10; // Quantidade de segundos usada no contador
  int seconds = maxSeconds;
  Timer? timer;

  startCountdown() {
    timer = Timer.periodic(Duration(seconds: 1), (_) async {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        this.widget.whenTimeIsOver();
      }
    });
  }

  void resetCountdown() => setState(() => seconds = maxSeconds);

  void stopCountdown({bool reset = true}) {
    if (reset) {
      resetCountdown();
    }
    timer?.cancel();
  }

  void pauseCountDown() => timer?.cancel();

  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () => startCountdown());
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return seconds.toString();
  }

  @override
  void didUpdateWidget(covariant OtpTimer oldWidget) {
    stopCountdown(reset: true);
    Future.delayed(Duration(seconds: 2), () {
      //resetCountdown();
      if (!timer!.isActive) {
        startCountdown();
      }
    });

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _timer(),
          SizedBox(height: 10),
          _button(),
        ],
      ),
    );
  }

  Widget _timer() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: seconds / maxSeconds,
            valueColor: AlwaysStoppedAnimation(AppColorScheme.cardColor),
            strokeWidth: 12,
            backgroundColor: Colors.lightBlue[900],
          ),
          Align(
            alignment: Alignment(0, 0.5),
            child: TextTitle(
              title: '$seconds',
              textStyle: TextStyles.appTitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _button() {
    return MatchButton(
      title: "Enviar",
      function: () {
        this.widget.whenTimeIsPaused();
        pauseCountDown();
        //timerKey.currentState!.didUpdateWidget(timer);
      },
    );
  }
}
