import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:video_player/video_player.dart';

//Widget que exibe o background das telas.
class Background extends StatelessWidget {
  final String background;
  Background({
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(this.background),
          fit: BoxFit.cover,
        ),
      ),
      padding: EdgeInsets.only(top: 50.0),
    );
  }
}

class BackgroundVideo extends StatefulWidget {
  final String background;
  BackgroundVideo({
    required this.background,
    Key? key,
  }) : super(key: key);

  @override
  _BackgroundVideoState createState() => _BackgroundVideoState();
}

class _BackgroundVideoState extends State<BackgroundVideo> {
  late VideoPlayerController _controller;

  bool isPlay = false;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(this.widget.background)
      ..addListener(() {})
      ..initialize().then((_) {
        setState(() {
          _controller.play();
          _controller.setLooping(true);
          _controller.setVolume(0.0);
          isPlay = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Stack(
            children: [
              LayoutBuilder(builder: (context, constraints) {
                return SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox(
                      width: constraints.maxWidth * _controller.value.aspectRatio,
                      height: constraints.maxHeight,
                      child: Transform.rotate(
                        angle: pi / 2,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ),
                );
              }),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: FittedBox(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                isPlay ? _controller.pause() : _controller.play();
                                isPlay = !isPlay;
                              });
                            },
                            icon: Icon(
                              isPlay ? Icons.pause : Icons.play_arrow,
                              color: AppColorScheme.iconColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )
        : Container();
  }
}
