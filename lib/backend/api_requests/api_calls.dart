import 'dart:convert';
import 'dart:typed_data';

import '../../flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class TwilioGetTokenCall {
  static Future<ApiCallResponse> call({
    String? roomName = '',
  }) {
    return ApiManager.instance.makeApiCall(
      callName: 'TwilioGetToken',
      apiUrl: 'https://video-1723.twil.io/video-token',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'roomName': roomName,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
    );
  }

  static dynamic token(dynamic response) => getJsonField(
        response,
        r'''$.token''',
      );
}

class TwilioGetTokenCopyCall {
  static Future<ApiCallResponse> call({
    String? roomName = '',
  }) {
    return ApiManager.instance.makeApiCall(
      callName: 'TwilioGetToken Copy',
      apiUrl: 'https://video-1465.twil.io/video-token',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'roomName': roomName,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
    );
  }

  static dynamic token(dynamic response) => getJsonField(
        response,
        r'''$.token''',
      );
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list);
  } catch (_) {
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar);
  } catch (_) {
    return isList ? '[]' : '{}';
  }
}
