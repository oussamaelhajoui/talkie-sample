import 'dart:core';

class DeviceInfo {
  String _id;
  String _name;

  String get name => _name;

  set name(String name) {
    _name = name;
  }

  String get id => _id;

  set id(String id) {
    _id = id;
  }
}
