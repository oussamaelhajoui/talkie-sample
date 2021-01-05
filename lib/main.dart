import 'dart:io';
import 'package:connectySample/src/Notifiers/cubeModel.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:connectycube_sdk/connectycube_sdk.dart';

import 'src/utils/configs.dart' as config;
import 'src/voice_screen.dart';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';

void main() {
  // runApp(App());
  runApp(
    ChangeNotifierProvider<CubeModel>(
      create: (context) => CubeModel(),
      child: App(),
    ),
  );
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  CubeUser _user;
  CubeSession _cubeSession;

  Future<CubeUser> futureUser;
  bool signedUp;

  @override
  Widget build(BuildContext context) {
    // getting the user
    // and signing the user up
    // or logging the user in
    // _getId().then((value) {
    //   this.getUser(value["id"], value["name"], value["model"]);
    // });

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FutureBuilder(
        future: futureUser,
        builder: (BuildContext context, AsyncSnapshot<CubeUser> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return VoiceScreen(
              user: snapshot.data,
              session: _cubeSession,
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    init(
      config.APP_ID,
      config.AUTH_KEY,
      config.AUTH_SECRET,
    );

    // Sign up user or

    createSession().then((cubeSession) {
      setState(() => _cubeSession = cubeSession);
      _getId().then((value) {
        setState(() {
          futureUser = this.getUser(value["id"], value["name"], value["model"]);
        });
      });
    }).catchError((error) {});
  }

  Future<Map<String, String>> _getId() async {
    Map<String, String> returnObject = {
      "id": null,
      "name": null,
      "model": null
    };
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      print("DEVM: IOS");
      print('name:' + iosDeviceInfo.name);

      returnObject["id"] = iosDeviceInfo.identifierForVendor; // unique ID iOS
      returnObject["name"] = iosDeviceInfo.name;
      returnObject["model"] = iosDeviceInfo.utsname.machine;

      return returnObject;
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      print("DEVM: ANDROID");
      print('name:' + androidDeviceInfo.version.codename);

      returnObject["id"] = androidDeviceInfo.androidId; // unique ID Android
      returnObject["name"] = androidDeviceInfo.version.codename;
      returnObject["model"] = androidDeviceInfo.model;

      return returnObject;
    }
  }

  Future<CubeUser> getUser(
      String username, String phoneName, String phoneModel) async {
    // print('X0: signing');
    CubeUser rVal;
    CubeUser existingUser;
    String login = username;

    existingUser = await getUserByLogin(login).catchError((error) => null);
    // print('FX0: ' + existingUser.toString());
    if (existingUser != null) {
      CubeUser user = CubeUser(login: username, password: 'password');
      rVal = await signIn(user);
      // print('X0: direct singing in ' + rVal.toString());
    } else {
      CubeUser newUser = CubeUser(
          login: username,
          password: 'password',
          email: username + '@talkie-walkie.nl',
          fullName: phoneName,
          customData: "{device_type: $phoneModel}");
      var signUpVal = await signUp(newUser);
      // print('X0: signup val is comming up ' + signUpVal.toString());
      CubeUser user = CubeUser(login: username, password: 'password');
      rVal = await signIn(user);
      // print('X0: rval is comming up ' + rVal.toString());
    }
    return rVal;
  }
}
