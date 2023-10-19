import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'voice_room_model.dart';
export 'voice_room_model.dart';

class VoiceRoomWidget extends StatefulWidget {
  const VoiceRoomWidget({Key? key}) : super(key: key);

  @override
  _VoiceRoomWidgetState createState() => _VoiceRoomWidgetState();
}

class _VoiceRoomWidgetState extends State<VoiceRoomWidget> {
  late VoiceRoomModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VoiceRoomModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 50.0, 0.0, 0.0),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: 200.0,
                  child: custom_widgets.TwilioVoiceCallWidget(
                    width: MediaQuery.sizeOf(context).width * 1.0,
                    height: 200.0,
                    roomName: FFAppState().roomName,
                    accessToken: FFAppState().accessToken,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Color(0x837484FD),
                ),
                child: Align(
                  alignment: AlignmentDirectional(0.00, 0.00),
                  child: Text(
                    'Room ${FFAppState().roomName}',
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                          fontFamily: 'Outfit',
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontSize: 22.0,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
