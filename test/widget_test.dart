// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'dart:js_util';

// import 'dart:js_util';
//
import 'package:connectySample/src/models/initPackage.dart';
import 'package:connectySample/src/utils/call_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';

import 'package:connectySample/main.dart';

// import '../lib/src/models/initPackage.dart';
// import '../lib/src/utils/call_manager.dart';

void main() {
  testWidgets('Shows CircularProgress indicator', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(App());

    // Verify that our counter starts at 0.
    expect(find.byWidget(CircularProgressIndicator()), findsNothing);
  });
  test('Testing initPackage models', () async {
    // Build our package model
    final CubeUser _user = new CubeUser();
    final ConferenceClient _client = ConferenceClient.instance;
    final ConferenceSession _session = null;
    final CallManager _manager = null;
    final initPackage = InitPackage.auto(_user, _client, _session, _manager);

    // Verify that our counter starts at 0.
    expect(initPackage.user.login, null);
  });
  test('Testing initPackage model with login name', () async {
    // Build our package model
    final CubeUser _user = new CubeUser(login: 'johan');
    final ConferenceClient _client = ConferenceClient.instance;
    final ConferenceSession _session = null;
    final CallManager _manager = null;
    final initPackage = InitPackage.auto(_user, _client, _session, _manager);

    // Verify that our counter starts at 0.
    expect(initPackage.user.login, 'johan');
  });
}
