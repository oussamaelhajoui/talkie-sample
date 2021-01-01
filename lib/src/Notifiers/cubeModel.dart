import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';

class CubeModel extends ChangeNotifier {
  CubeUser _user;
  CubeSession _session;

  CubeUser get user => _user;
  CubeSession get session => _session;

  void setUser(CubeUser user) {
    _user = user;
    notifyListeners();
  }

  void setSession(CubeSession session) {
    _session = session;
    notifyListeners();
  }
}
