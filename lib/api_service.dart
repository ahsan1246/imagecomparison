import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final Logger logger = Logger();
showToast(msg) => Fluttertoast.showToast(msg: msg);

const imageUploadUrl = 'https://similarity.techhivedemo.xyz/api/image/upload';
const imageCompareUrl = 'https://similarity.techhivedemo.xyz/api/image/percentage';

class ApiService {
  static Future<http.Response?> postMethod(
      {required String url, Map? body, bool bypassStatusCode = false}) async {
    return await http.post(
      Uri.parse(url),
      body: body != null ? json.encode(body) : null,
      headers: <String, String>{
        "Accept": "application/json",
      },
    ).then((_res) {
      logger.i(
          'URL => $url\nResponse StatusCode => ${_res.statusCode}\nResponse Body => ${_res.body}');
      if (_res.statusCode != 200 && _res.statusCode != 201 && !bypassStatusCode) {
        exceptionAlert(_res.body /*, isNeedResponse: isNeedResponse*/);
        // if (isNeedResponse) return _res;
        return null;
      }
      return _res;
    }).onError((error, stackTrace) {
      debugPrint('Error in api call => $error\nUrl => $url');
      logger.e('stackTrace => $stackTrace');

      Fluttertoast.showToast(msg: '$error');
      return null;
    });
  }

  static Future<String?> postMultiPartQuery(String url,
      {Map<String, String>? fields, Map<String, String>? files}) async {
    try {
      var headers = {
        "Accept": "application/json",
      };

      var request = http.MultipartRequest('POST', Uri.parse(url));
      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (files != null) {
        files.forEach((key, value) async {
          request.files.add(await http.MultipartFile.fromPath(key, value));
        });
      }
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      String _resBody = await response.stream.bytesToString();

      logger.i(
        'URL => $url\n'
        'Request Fields => ${request.fields}\n'
        'Request Files => ${request.files}\n'
        'Response StatusCode => ${response.statusCode}\n'
        'Response Body => $_resBody',
      );
      if (response.statusCode == 200) {
        logger.d('-------------------------------------------------------------------------------');
        return _resBody;
      } else {
        logger.e('-------------------------------------------------------------------------------');
        exceptionAlert(_resBody);
        return null;
      }
    } catch (error) {
      logger.e('Error: ApiService -> postMultiPartQuery -> url = $url => $error');
      Fluttertoast.showToast(msg: '$error');
      return null;
    }
  }

  static void exceptionAlert(String? _resBody /*, {bool isNeedResponse = false}*/) {
    String alertDesc;
    try {
      alertDesc = json.decode('$_resBody')['message'] +
          (json.decode('$_resBody')['errors'] != null
              ? '\n${json.decode('$_resBody')['errors']}'
              : null);
    } catch (e) {
      try {
        alertDesc =
            json.decode('$_resBody')['message'] ?? json.decode('$_resBody')['errors'].toString();
      } catch (_e) {
        try {
          alertDesc = json.decode('$_resBody').toString();
        } catch (_err) {
          alertDesc = _resBody.toString();
        }
      }
    }

    // if (isNeedResponse) {
    //   AppAlert.warning(desc: alertDesc);
    // } else {
    Fluttertoast.showToast(msg: alertDesc);
    // }
  }
}
