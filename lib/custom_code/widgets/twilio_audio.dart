// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:twilio_programmable_video/twilio_programmable_video.dart';

class TwilioAudio extends StatefulWidget {
  const TwilioAudio({
    Key? key,
    this.width,
    this.height,
    required this.roomName,
    required this.accessToken,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String roomName;
  final String accessToken;

  @override
  _TwilioAudioState createState() => _TwilioAudioState();
}

class _TwilioAudioState extends State<TwilioAudio> {
  Room? _room;
  Completer<Room>? _completer;
  Region? region = Region.us1; // Region.us1

  @override
  void initState() {
    super.initState();
    connectToRoom();
  }

  Future<void> connectToRoom() async {
    try {
      _completer = Completer<Room>();

      var connectOptions = ConnectOptions(
        widget.accessToken,
        roomName: widget.roomName,
        region: region,
        audioTracks: [LocalAudioTrack(true, '')],
      );

      _room = await TwilioProgrammableVideo.connect(connectOptions);
      _room!.onConnected.listen(_onConnected);
      _room!.onConnectFailure.listen(_onConnectFailure);
    } catch (e) {
      _completer?.completeError(e.toString());
    }
  }

  void _onConnected(Room room) {
    _completer?.complete(room);
  }

  void _onConnectFailure(RoomConnectFailureEvent event) {
    _completer?.completeError(event.exception.toString());
  }

  @override
  void dispose() {
    if (_room != null) {
      _room!.disconnect();
    }
    _completer?.completeError('Disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: FutureBuilder<Room?>(
        future: _completer?.future,
        builder: (BuildContext context, AsyncSnapshot<Room?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to connect to room'));
          } else if (snapshot.hasData) {
            if (snapshot.data != null) {
              return Center(
                child: Text('Connected to room: ${snapshot.data!.name}'),
              );
            } else {
              return Container(child: Text('No Data'));
            }
          } else {
            return Container(child: Text('No Status'));
          }
        },
      ),
    );
  }
}
