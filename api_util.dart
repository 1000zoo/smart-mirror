import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'constant.dart';
import 'util.dart';
import 'dart:async';
import 'person.dart';
import 'dart:convert';
import 'person.dart';

//해당 API 주소 반환
Uri getUrl(String path) {
  return Uri.parse('$SERVER_ADDRESS/$path');
}

// //response 메소드 decode
// List<dynamic> getStatus(String responseCode) {
//   bool success = responseCode.split('/')[0] == '1';
//   String code = responseCode.split('/')[1];
//   return [success, code];
// }

dynamic getMessage(http.Response request) {
  var msg = jsonDecode(utf8.decode(request.bodyBytes))['msg'];
  return msg;
}

//이미지 업로드
Future<void> uploadImage(File image) async {
  final url = getUrl('upload-image');

  try {
    var request = http.MultipartRequest('POST', url);

    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      var response = await request.send().timeout(const Duration(seconds: 2));
      // debugPrint(await response.stream.bytesToString());
      getToast("이미지가 업로드 되었습니다.");
    } on TimeoutException catch (_) {
      getToast("서버 연결 실패");
      // debugPrint("서버 연결 실패");
    } catch (e) {
      getToast("네트워크에 연결되지 않음");
      // debugPrint(e.toString());
      // debugPrint("네트워크에 연결되지 않음");
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}

//환자 등록
Future<bool> addPatients(Person person) async {
  String barcode = person.barcode;
  final url = getUrl('patients-info/$barcode');
  final send = json.encode(person.toJson());
  var request = await http.post(url, body: send);

  return request.statusCode == 200;
}

//등록된 바코드인지 확인
Future<bool> isContains(String barcode) async {
  final url = getUrl('patients-info/iscontains/$barcode');

  try {
    var request = await http.get(url);
    return request.statusCode == 200;
  } catch (e) {
    getToast(e.toString());
    return false;
  }
}

//환자 이름 불러오기
Future<String> getPatientsName(barcode) async {
  final url = getUrl('patients-info/$barcode');
  var request = await http.get(url);

  return getMessage(request).toString();
}

//환자 정보 불러오기
Future<List<Person>> getPatientsList() async {
  List<Person> list = [];

  // try {
    final url = getUrl('patients-info');
    var request = await http.get(url);
    Map<String, dynamic> msg = jsonDecode(utf8.decode(request.bodyBytes));

    for (var p in msg.keys) {
      Person temp = Person.fromJson(msg[p]);
      list.add(temp);
    }
    return list;
  // } catch (e) {
  //   getToast("네트워크 유실");
  //   print(e.toString());
  //   return list;
  // }
}

//환자 정보 삭제
Future<bool> deletePatients(String barcode) async {
  final url = getUrl('patients-info/$barcode');
  var request = await http.delete(url);
  // var status = getStatus(request.body);
  // if (status[0]) {
  //   return true;
  // } else {
  //   getToast("이미 삭제된 환자입니다.");
  //   return false;
  // }
  return false;
}

