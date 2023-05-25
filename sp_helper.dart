import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../person.dart';

class SPHelper {
  static late SharedPreferences prefs;

  Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future writeInfo(String barcode, Person person) async {
    prefs.setString(
      barcode, json.encode(person.toJson())
    );
  }

  List<Person> getPeopleList() {
    List<Person> list = [];
    Set<String> keys = prefs.getKeys();
    for (var key in keys) {
      Person p = Person.fromJson(json.decode(prefs.getString(key) ?? ''));
      list.add(p);
    }
    return list;
  }

  Person getPersonInfo(String barcode) {
    return Person.fromJson(json.decode(prefs.getString(barcode) ?? ' '));
  }

  String getPersonName(String barcode) {
    return Person.fromJson(json.decode(prefs.getString(barcode) ?? ' ')).name;
  }

  void removePerson(String barcode) {
    prefs.remove(barcode);
  }

  bool contains(String barcode) {
    return prefs.getKeys().contains(barcode);
  }
}