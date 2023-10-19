// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
//以下はTwilioビデオ通話に必要な本体
import 'package:twilio_programmable_video/twilio_programmable_video.dart';
//以下はパーミッション取得のため
import 'package:permission_handler/permission_handler.dart';
//以下はWeb/モバイル判定のため（kIsWeb）
import 'package:flutter/foundation.dart';

// Twilioの音声通話のためのウィジェットを表すクラスを作成
class TwilioVoiceCallWidget extends StatefulWidget {
  // ウィジェットのプロパティを定義
  final double? width;
  final double? height;
  final String roomName;
  final String accessToken;

  //コンストラクタ
  const TwilioVoiceCallWidget({
    Key? key,
    this.width,
    this.height,
    required this.roomName,
    required this.accessToken,
  }) : super(key: key);

  // ウィジェットのステートを作成
  @override
  _TwilioVoiceCallWidgetState createState() => _TwilioVoiceCallWidgetState();
}

class _TwilioVoiceCallWidgetState extends State<TwilioVoiceCallWidget> {
  // 音声通話のセッションやトラック、参加者などを管理するためのプライベート変数を定義
  Room? _room;
  final Completer<Room> _completer = Completer<Room>();
  Region? region = Region.us1; // Region.us1
  //LocalVideoTrack? _localVideoTrack;
  //RemoteVideoTrack? remoteTrack;
  LocalAudioTrack? _localAudioTrack; //不使用
  RemoteAudioTrack? remoteTrack;
  RemoteParticipant? remoteParticipant;
  //Widget? _remoteVideoWidget;
  Widget? _remoteAudioWidget;
  bool _isParticipantDisconnected = false;

  // ウィジェット初期化の動作を定義
  @override
  void initState() {
    super.initState();
    // Web上で実行されている場合、すぐにルームに接続
    // Web以外は、マイクのアクセス許可を要求後、ルームに接続
    if (kIsWeb) {
      connectToRoom();
    } else {
      //requestCameraAndMicrophonePermissions().then((_) {
      requestMicrophonePermissions().then((_) {
        connectToRoom();
      });
    }
  }

  // マイクのアクセス許可を要求する関数
  Future<void> requestMicrophonePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      //Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.microphone]?.isGranted == true) {
      print("Microphone permissions granted");
    } else {
      print("Permissions not granted");
    }
  }

  // Twilioのルームに接続する関数
  Future<Room> connectToRoom() async {
    print('Connecting to ${widget.roomName}...');

    try {
      // 自分の取得（なし）
      /*
      var cameraSources = await CameraSource.getSources();
      if (cameraSources.isNotEmpty) {
        print('Success to get camera sources');
        var cameraCapturer = CameraCapturer(
            cameraSources.firstWhere((source) => source.isFrontFacing));
        _localVideoTrack = LocalVideoTrack(true, cameraCapturer);

        if (_localVideoTrack == null) {
          _completer?.completeError('Failed to initialize local video track');
          return _completer.future;
        }
        */

      // ルームへの接続オプションを定義
      var connectOptions = ConnectOptions(
        widget.accessToken,
        roomName: widget.roomName,
        region: region,
        preferredAudioCodecs: [OpusCodec()],
        audioTracks: [LocalAudioTrack(true, 'audio')],
        //videoTracks: [_localVideoTrack!],
      );

      // ルームへ接続し、コールバック関数を登録する
      _room = await TwilioProgrammableVideo.connect(connectOptions);
      _room!.onConnected.listen(_onConnected);
      _room!.onConnectFailure.listen(_onConnectFailure);
      _room!.onParticipantConnected
          .listen((RoomParticipantConnectedEvent event) {
        _onParticipantConnected(event);
      });
      _room!.onParticipantDisconnected.listen(_onParticipantDisconnected);
      return _completer.future;
      /*
      } else {
        print('Failed to get camera sources');
        _completer.completeError('Failed to get camera sources');
        return _completer.future;
      }*/
    } catch (e) {
      print('Error while connecting to room: $e');
      _completer.completeError(e.toString());
      return _completer.future;
    }
  }

  // 接続成功時のコールバック関数
  void _onConnected(Room room) {
    print('Connected to ${room.name}');
    setState(() {
      _room = room;
      /* ビデオはなし
      if (room.remoteParticipants.isNotEmpty) {
        _setRemoteParticipant(room.remoteParticipants.first);
      }
      */
    });
    _completer.complete(room);
  }

  // 接続失敗時のコールバック関数
  void _onConnectFailure(RoomConnectFailureEvent event) {
    print(
        'Failed to connect to room ${event.room.name} with exception: ${event.exception.toString()}');
    _completer.completeError(event.exception.toString());
  }

  // 相手が接続したときのコールバック関数
  void _onParticipantConnected(RoomParticipantConnectedEvent event) {
    print('Participant connected: ${event.remoteParticipant.identity}');

    // 相手の映像が登録されたときに、その映像をウィジェットツリーに追加するリスナー
    //なし
    /*
    event.remoteParticipant.onVideoTrackSubscribed
        .listen((RemoteVideoTrackSubscriptionEvent trackEvent) {
      setState(() {
        _remoteVideoWidget = trackEvent.remoteVideoTrack!.widget(mirror: false);
      });
    });
    setState(() {
      remoteParticipant = event.remoteParticipant;
      if (remoteParticipant!.remoteVideoTracks.isNotEmpty) {
        remoteTrack =
            remoteParticipant!.remoteVideoTracks.first.remoteVideoTrack;
      }
    });
    */
  }

  // 接続相手のビデオトラックを設定する関数
  //なし
  /*
  void _setRemoteParticipant(RemoteParticipant participant) {
    participant.onVideoTrackSubscribed
        .listen((RemoteVideoTrackSubscriptionEvent event) {
      setState(() {
        _remoteVideoWidget = event.remoteVideoTrack.widget();
      });
    });
  }
  */

  // 相手が接続を終了したときのコールバック関数
  void _onParticipantDisconnected(RoomParticipantDisconnectedEvent event) {
    print('Participant disconnected: ${event.remoteParticipant.identity}');

    setState(() {
      _isParticipantDisconnected = true;
      // _remoteVideoWidget = null;
    });
  }

  // ウィジェットが廃棄されるときにルームを切断
  @override
  void dispose() {
    if (_room != null) {
      _room!.disconnect();
    }
    _completer.completeError('Disposed');
    super.dispose();
  }

  // ウィジェットのUIを構築する関数
  @override
  Widget build(BuildContext context) {
    /*
    Widget? localVideoTrackWidget;
    if (_room != null && _localVideoTrack != null) {
      localVideoTrackWidget = _localVideoTrack!.widget();
    }
    */

    return Container(
      width: widget.width,
      height: widget.height,
      child: FutureBuilder<Room?>(
        future: _completer.future,
        builder: (BuildContext context, AsyncSnapshot<Room?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to connect to room'));
          } else if (snapshot.hasData) {
            return Stack(
              children: [
                // 相手の映像を表示（なし）
                /*
                Positioned.fill(
                  child: _remoteVideoWidget ??
                      (_isParticipantDisconnected
                          ? Center(child: Text('接続が終了しました'))
                          : Center(child: Text('接続を待機中...'))),
                ),
                // 自分の映像を表示（なし）
                Positioned(
                  left: 10,
                  bottom: 10,
                  width: 100,
                  height: 150,
                  child: localVideoTrackWidget ?? Container(),
                ),
                */
                // 終了ボタンを表示
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: FloatingActionButton(
                    child: Icon(Icons.call_end),
                    onPressed: () {
                      if (_room != null) {
                        _room!.disconnect();
                      }
                      Navigator.pop(context);
                    },
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            );
          } else {
            return Container(child: Text('No Status'));
          }
        },
      ),
    );
  }
}
