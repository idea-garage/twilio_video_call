// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:twilio_programmable_video/twilio_programmable_video.dart';

class VideoOnlyWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final String roomName;
  final String accessToken;

  const VideoOnlyWidget({
    Key? key,
    this.width,
    this.height,
    required this.roomName,
    required this.accessToken,
  }) : super(key: key);

  @override
  _VideoOnlyWidgetState createState() => _VideoOnlyWidgetState();
}

class _VideoOnlyWidgetState extends State<VideoOnlyWidget> {
  Room? _room;
  bool _isConnected = false;
  bool _hasError = false;
  String? _errorMessage;
  Region? region = Region.us1; // Region.us1

  @override
  void initState() {
    super.initState();
    connectToRoom();
  }

  void _onConnected(Room room) {
    setState(() {
      _isConnected = true;
      _room = room;
    });
    print('Connected to ${room.name}');
  }

  void _onConnectFailure(RoomConnectFailureEvent event) {
    setState(() {
      _hasError = true;
      _errorMessage =
          'Failed to connect to room ${event.room.name} with exception: ${event.exception}';
    });
    print(_errorMessage!);
    print('Error message: ${event.exception!.message}');
  }

  Future<void> connectToRoom() async {
    await TwilioProgrammableVideo.requestPermissionForCameraAndMicrophone();

    var cameraSources = await CameraSource.getSources();
    var cameraCapturer = CameraCapturer(
      cameraSources.firstWhere((source) => source.isFrontFacing),
    );

    var connectOptions = ConnectOptions(
      widget.accessToken,
      roomName: widget.roomName,
      region: region,
      preferredVideoCodecs: [H264Codec()],
      videoTracks: [LocalVideoTrack(true, cameraCapturer)],
    );

    _room = await TwilioProgrammableVideo.connect(connectOptions);

    _room?.onConnected.listen(_onConnected);
    _room?.onConnectFailure.listen(_onConnectFailure);
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

    return Container(
      width: width,
      height: height,
      child: _isConnected
          ? Center(child: Text('Connected to ${_room!.name}'))
          : _hasError
              ? Center(child: Text('Error: $_errorMessage'))
              : Center(child: Text('Connecting...')),
    );
  }
}
