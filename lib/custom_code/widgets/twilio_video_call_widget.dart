// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:twilio_programmable_video/twilio_programmable_video.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class TwilioVideoCallWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final String roomName;
  final String accessToken;

  const TwilioVideoCallWidget({
    Key? key,
    this.width,
    this.height,
    required this.roomName,
    required this.accessToken,
  }) : super(key: key);

  @override
  _TwilioVideoCallWidgetState createState() => _TwilioVideoCallWidgetState();
}

class _TwilioVideoCallWidgetState extends State<TwilioVideoCallWidget> {
  Room? _room;
  final Completer<Room> _completer = Completer<Room>();
  Region? region = Region.us1; // Region.us1
  LocalVideoTrack? _localVideoTrack;
//  List<VideoTrack> _remoteVideoTracks = [];
//  List<AudioTrack> _remoteAudioTracks = [];
  RemoteVideoTrack? remoteTrack;
  RemoteParticipant? remoteParticipant;
  Widget? _remoteVideoWidget;
  bool _isParticipantDisconnected = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      connectToRoom();
    } else {
      requestCameraAndMicrophonePermissions().then((_) {
        connectToRoom();
      });
    }
  }

  Future<void> requestCameraAndMicrophonePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    // パーミッションのステータスをチェック
    if (statuses[Permission.camera]?.isGranted == true &&
        statuses[Permission.microphone]?.isGranted == true) {
      print("Both camera and microphone permissions granted");
    } else {
      print("Permissions not granted");
    }
  }

  Future<Room> connectToRoom() async {
    print('Connecting to ${widget.roomName}...');
    //_completer = Completer<Room>();

    try {
      var cameraSources = await CameraSource.getSources();
      if (cameraSources.isNotEmpty) {
        print('Success to get camera sources');
        var cameraCapturer = CameraCapturer(
            cameraSources.firstWhere((source) => source.isFrontFacing));

        _localVideoTrack = LocalVideoTrack(true, cameraCapturer);

        // Ensure the local video track is properly initialized
        if (_localVideoTrack == null) {
          _completer?.completeError('Failed to initialize local video track');
          return _completer.future;
        }

        var connectOptions = ConnectOptions(
          widget.accessToken,
          roomName: widget.roomName,
          region: region,
          preferredAudioCodecs: [OpusCodec()],
          audioTracks: [LocalAudioTrack(true, 'audio')],
          videoTracks: [_localVideoTrack!],
        );

        _room = await TwilioProgrammableVideo.connect(connectOptions);
        _room!.onConnected.listen(_onConnected);
        _room!.onConnectFailure.listen(_onConnectFailure);
        //_room!.onParticipantConnected.listen(_onParticipantConnected);
        _room!.onParticipantConnected
            .listen((RoomParticipantConnectedEvent event) {
          _onParticipantConnected(event);
        });
        _room!.onParticipantDisconnected.listen(_onParticipantDisconnected);
        return _completer.future;
      } else {
        print('Failed to get camera sources');
        _completer.completeError('Failed to get camera sources');
        return _completer.future;
      }
    } catch (e) {
      print('Error while connecting to room: $e');
      _completer.completeError(e.toString());
      return _completer.future;
    }
  }

  void _onConnected(Room room) {
    print('Connected to ${room.name}');
    setState(() {
      _room = room;
      if (room.remoteParticipants.isNotEmpty) {
        _setRemoteParticipant(room.remoteParticipants.first);
      }
    });
    _completer.complete(room);
  }

  void _onConnectFailure(RoomConnectFailureEvent event) {
    print(
        'Failed to connect to room ${event.room.name} with exception: ${event.exception.toString()}');
    _completer.completeError(event.exception.toString());
  }

  void _onParticipantConnected(RoomParticipantConnectedEvent event) {
    print('Participant connected: ${event.remoteParticipant.identity}');

    // 新しく参加した参加者の映像がサブスクライブされたときに、その映像をウィジェットツリーに追加するリスナー
    event.remoteParticipant.onVideoTrackSubscribed
        .listen((RemoteVideoTrackSubscriptionEvent trackEvent) {
      setState(() {
        _remoteVideoWidget = trackEvent.remoteVideoTrack!.widget(mirror: false);
      });
    });
    // 現在のリモート参加者の情報を更新
    setState(() {
      remoteParticipant = event.remoteParticipant;

      if (remoteParticipant!.remoteVideoTracks.isNotEmpty) {
        remoteTrack =
            remoteParticipant!.remoteVideoTracks.first.remoteVideoTrack;
      }
    });
  }

  void _onParticipantDisconnected(RoomParticipantDisconnectedEvent event) {
    print('Participant disconnected: ${event.remoteParticipant.identity}');

    setState(() {
      _isParticipantDisconnected = true;
      _remoteVideoWidget = null;
    });
  }

  void _setRemoteParticipant(RemoteParticipant participant) {
    participant.onVideoTrackSubscribed
        .listen((RemoteVideoTrackSubscriptionEvent event) {
      setState(() {
        _remoteVideoWidget = event.remoteVideoTrack.widget();
      });
    });
  }

  @override
  void dispose() {
    if (_room != null) {
      _room!.disconnect();
    }
    _completer.completeError('Disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? localVideoTrackWidget;
    if (_room != null && _localVideoTrack != null) {
      localVideoTrackWidget = _localVideoTrack!.widget();
    }
    //RemoteVideoTrack? remoteTrack;
/*
    if (remoteParticipant != null &&
        remoteParticipant!.remoteVideoTracks.isNotEmpty) {
      remoteTrack = remoteParticipant!.remoteVideoTracks.first.remoteVideoTrack;
    }
    Widget? remoteVideoTrackWidget;
    if (remoteParticipant != null &&
        remoteParticipant!.remoteVideoTracks.isNotEmpty) {
      var currentRemoteTrack =
          remoteParticipant!.remoteVideoTracks.first.remoteVideoTrack;
      if (currentRemoteTrack != null) {
        remoteVideoTrackWidget = currentRemoteTrack.widget();
      }
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
                // Display all remote video tracks
                Positioned.fill(
                  child: _remoteVideoWidget ??
                      (_isParticipantDisconnected
                          ? Center(child: Text('接続が終了しました'))
                          : Center(child: Text('接続を待機中...'))),
                ),
                // Display the local video track on the bottom left
                Positioned(
                  left: 10,
                  bottom: 10,
                  width: 100,
                  height: 150,
                  child: localVideoTrackWidget ?? Container(),
                ),
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
