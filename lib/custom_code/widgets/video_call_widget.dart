// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:twilio_programmable_video/twilio_programmable_video.dart';

class VideoCallWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final String roomName;
  final String accessToken;

  const VideoCallWidget({
    Key? key,
    this.width,
    this.height,
    required this.roomName,
    required this.accessToken,
  }) : super(key: key);

  @override
  _VideoCallWidgetState createState() => _VideoCallWidgetState();
}

class _VideoCallWidgetState extends State<VideoCallWidget> {
  //Region? region = Region.gll;
  Region? region = Region.us1;

  Room? _room;
  RemoteParticipant? remoteParticipant;
  LocalVideoTrack? localVideoTrack;
  final Completer<Room> _completer = Completer<Room>();

  @override
  void initState() {
    super.initState();
    connectToRoom(); //接続する
  }

  void _onConnected(Room room) {
    print('Connected to ${room.name}');
    setState(() {
      _room = room;
      if (room.remoteParticipants.isNotEmpty) {
        remoteParticipant = room.remoteParticipants.first;
      }
    });
    _completer.complete(room);
  }

  void _onConnectFailure(RoomConnectFailureEvent event) {
    print(
        'Failed to connect to room ${event.room.name} with exception: ${event.exception.toString()}');
    _completer?.completeError(event.exception.toString());
  }

  Future<Future<Room>> connectToRoom() async {
    var cameraSources = await CameraSource.getSources();
    var cameraCapturer = CameraCapturer(
      cameraSources.firstWhere((source) => source.isFrontFacing),
    );
    localVideoTrack = LocalVideoTrack(true, cameraCapturer);

    var connectOptions = ConnectOptions(
      widget.accessToken,
      roomName: widget.roomName,
      region: region,
      preferredAudioCodecs: [OpusCodec()],
      preferredVideoCodecs: [H264Codec()],
      audioTracks: [
        LocalAudioTrack(true, 'audio1'),
      ],
      videoTracks: [LocalVideoTrack(true, cameraCapturer)],
    );

    // Room に接続
    _room = await TwilioProgrammableVideo.connect(connectOptions);

    _room?.onConnected.listen(_onConnected);
    _room?.onConnectFailure.listen(_onConnectFailure);
    return _completer.future;
  }

  @override
  void dispose() {
    _room?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? MediaQuery.of(context).size.width;
    final height = widget.height ?? MediaQuery.of(context).size.height;
    Widget? localVideoTrackWidget;
    if (localVideoTrack != null) {
      localVideoTrackWidget = localVideoTrack!.widget();
    }
    RemoteVideoTrack? remoteTrack;
    if (remoteParticipant != null &&
        remoteParticipant!.remoteVideoTracks.isNotEmpty) {
      remoteTrack = remoteParticipant!.remoteVideoTracks.first.remoteVideoTrack;
    }
    Widget? remoteVideoTrackWidget;
    if (remoteTrack != null) {
      remoteVideoTrackWidget = remoteTrack.widget();
    }

    return Container(
      width: width,
      height: height,
      child: _room != null
          ? Stack(
              children: [
                // Display remote video
                if (remoteVideoTrackWidget != null)
                  Positioned.fill(child: remoteVideoTrackWidget),

                // Display local video in a smaller widget
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 100,
                    height: 150,
                    child: localVideoTrackWidget,
                  ),
                ),
              ],
            )
          : Center(child: Text('Connecting...')),
    );
  }
}
