// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:twilio_programmable_video/twilio_programmable_video.dart';

class TwilioTest extends StatefulWidget {
  final double? width;
  final double? height;
  final String roomName;
  final String accessToken;

  const TwilioTest({
    Key? key,
    this.width,
    this.height,
    required this.roomName,
    required this.accessToken,
  }) : super(key: key);

  @override
  _TwilioTestState createState() => _TwilioTestState();
}

class _TwilioTestState extends State<TwilioTest> {
  Room? _room;
  Completer<Room>? _completer;
  Region? region = Region.us1; // Region.us1
  LocalVideoTrack? _localVideoTrack;
  List<VideoTrack> _remoteVideoTracks = [];
  List<AudioTrack> _remoteAudioTracks = [];
  RemoteVideoTrack? remoteTrack;
  RemoteParticipant? remoteParticipant;

  @override
  void initState() {
    super.initState();
    connectToRoom();
  }

  Future<void> connectToRoom() async {
    print('Connecting to ${widget.roomName}...');
    _completer = Completer<Room>();

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
          return;
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
      } else {
        print('Failed to get camera sources');
        _completer?.completeError('Failed to get camera sources');
      }
    } catch (e) {
      print('Error while connecting to room: $e');
      _completer?.completeError(e.toString());
    }
  }

  void _onConnected(Room room) {
    print('Connected to ${room.name}');
    setState(() {
      _room = room;
      if (room.remoteParticipants.isNotEmpty) {
        remoteParticipant = room.remoteParticipants.first;
      }
    });
    _completer!.complete(room);
  }

  void _onConnectFailure(RoomConnectFailureEvent event) {
    print(
        'Failed to connect to room ${event.room.name} with exception: ${event.exception.toString()}');
    _completer?.completeError(event.exception.toString());
  }

  void _onParticipantConnected(RoomParticipantConnectedEvent event) {
    print('Participant connected: ${event.remoteParticipant.identity}');
    setState(() {
      if (remoteParticipant == null) {
        remoteParticipant = event.remoteParticipant;
      }
    });
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
    Widget? localVideoTrackWidget;
    if (_room != null && _localVideoTrack != null) {
      localVideoTrackWidget = _localVideoTrack!.widget();
    }
    //RemoteVideoTrack? remoteTrack;
    if (remoteParticipant != null &&
        remoteParticipant!.remoteVideoTracks.isNotEmpty) {
      remoteTrack = remoteParticipant!.remoteVideoTracks.first.remoteVideoTrack;
    }
    Widget? remoteVideoTrackWidget;
    if (remoteTrack != null) {
      remoteVideoTrackWidget = remoteTrack?.widget();
    }

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
            return Stack(
              children: [
                // Display the first remote video track
                Positioned.fill(
                  child: remoteVideoTrackWidget ?? Container(),
                ),
                // Display the local video track (self view) on the bottom right
                Positioned(
                  right: 10,
                  bottom: 10,
                  width: 100, // you can adjust the size
                  height: 150, // you can adjust the size
                  child: localVideoTrackWidget ?? Container(),
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
