import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:task/player/playing_controls.dart';
import 'package:task/player/position_seek_widget.dart';



void main() {
  AssetsAudioPlayer.setupNotificationsOpenAction((notification) {
    print(notification.audioId);
    return true;
  });

  runApp(

    NeumorphicTheme(
      theme: NeumorphicThemeData(

        intensity: 0.8,
        lightSource: LightSource.topLeft,
      ),

      child: HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final audios = <Audio>[

    Audio(
      'assets/audios/Its My Life.mp3',
      //playSpeed: 2.0,
      metas: Metas(
        id: 'itsmylife',
        title: 'It\'s My Life',

        image: MetasImage.network(
            'https://www.pikpng.com/pngl/m/46-461448_music-icon-png-download-music-icon-clipart.png'),
      ),
    ),
    Audio(
      'assets/audios/Coca Cola Tu.mp3',
      metas: Metas(
        id: 'cocacolatu',
        title: 'Coca Cola Tu',

        image: MetasImage.network('https://www.pikpng.com/pngl/m/46-461448_music-icon-png-download-music-icon-clipart.png'),
      ),
    ),

  ];

  AssetsAudioPlayer get _assetsAudioPlayer => AssetsAudioPlayer.withId('music');
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();

    _subscriptions.add(_assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print('playlistAudioFinished : $data');
    }));
    _subscriptions.add(_assetsAudioPlayer.audioSessionId.listen((sessionId) {
      print('audioSessionId : $sessionId');
    }));
    _subscriptions
        .add(AssetsAudioPlayer.addNotificationOpenAction((notification) {
      return false;
    }));
    openPlayer();
  }

  void openPlayer() async {
    await _assetsAudioPlayer.open(
      Playlist(audios: audios, startIndex: 0),
      showNotification: true,
      autoStart: false,
    );
  }

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    print('dispose');
    super.dispose();
  }

  Audio find(List<Audio> source, String fromPath) {
    return source.firstWhere((element) => element.path == fromPath);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(
        appBar: AppBar(title: Center(child: Text("ClickAndPress Looper")),),
        backgroundColor: NeumorphicTheme.baseColor(context),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Stack(
                    fit: StackFit.passthrough,
                    children: <Widget>[
                      _assetsAudioPlayer.builderCurrent(
                        builder: (BuildContext context, Playing playing) {
                          final myAudio =
                          find(audios, playing.audio.assetAudioPath);
                          return Column(
                            children: [
                          Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Neumorphic(
                          style: NeumorphicStyle(
                          depth: 8,
                          surfaceIntensity: 1,
                          shape: NeumorphicShape.concave,
                          boxShape: NeumorphicBoxShape.circle(),
                          ),
                          child: myAudio.metas.image?.path == null
                          ? const SizedBox()
                              : myAudio.metas.image?.type ==
                          ImageType.network
                          ? Image.network(
                          myAudio.metas.image!.path,
                          height: 150,
                          width: 150,
                          fit: BoxFit.contain,
                          )
                              : Image.asset(
                          myAudio.metas.image!.path,
                          height: 150,
                          width: 150,
                          fit: BoxFit.contain,
                          ),
                          ),
                          ),
                              Text("${myAudio.metas.title}")
                            ],
                          );
                        },
                      ),


                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _assetsAudioPlayer.builderCurrent(
                      builder: (context, Playing? playing) {
                        return Column(
                          children: <Widget>[
                            _assetsAudioPlayer.builderLoopMode(
                              builder: (context, loopMode) {
                                return PlayerBuilder.isPlaying(
                                    player: _assetsAudioPlayer,
                                    builder: (context, isPlaying) {
                                      return PlayingControls(
                                        loopMode: loopMode,
                                        isPlaying: isPlaying,
                                        isPlaylist: true,

                                        toggleLoop: () {
                                          _assetsAudioPlayer.toggleLoop();
                                        },
                                        onPlay: () {
                                          _assetsAudioPlayer.playOrPause();
                                        },
                                        onNext: () {
                                          _assetsAudioPlayer.next(keepLoopMode: true
                                            );
                                        },
                                        onPrevious: () {
                                          _assetsAudioPlayer.previous(
                                          );
                                        },
                                      );
                                    });
                              },
                            ),
                            _assetsAudioPlayer.builderRealtimePlayingInfos(
                                builder: (context, RealtimePlayingInfos? infos) {
                                  if (infos == null) {
                                    return SizedBox();
                                  }

                                  return Column(
                                    children: [
                                      PositionSeekWidget(
                                        currentPosition: infos.currentPosition,
                                        duration: infos.duration,
                                        seekTo: (to) {
                                          _assetsAudioPlayer.seek(to);
                                        },
                                      ),

                                    ],
                                  );
                                }),
                          ],
                        );
                      }),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}