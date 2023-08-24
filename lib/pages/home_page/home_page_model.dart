import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePageModel extends FlutterFlowModel {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for RoomName widget.
  TextEditingController? roomNameController;
  String? Function(BuildContext, String?)? roomNameControllerValidator;
  // Stores action output result for [Backend Call - API (TwilioGetToken)] action in Button widget.
  ApiCallResponse? response1;
  // Stores action output result for [Backend Call - API (TwilioGetToken)] action in Button widget.
  ApiCallResponse? response3;
  // Stores action output result for [Backend Call - API (TwilioGetToken)] action in Button widget.
  ApiCallResponse? response2;
  // Stores action output result for [Backend Call - API (TwilioGetToken)] action in Button widget.
  ApiCallResponse? response4;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {}

  void dispose() {
    unfocusNode.dispose();
    roomNameController?.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
