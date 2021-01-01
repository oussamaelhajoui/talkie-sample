import 'dart:io';
import 'package:connectySample/src/Notifiers/cubeModel.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:connectycube_sdk/connectycube_sdk.dart';

import 'src/utils/configs.dart' as config;
import 'src/voice_screen.dart';

import 'package:device_info/device_info.dart';

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

  Future<CubeUser> fetchUser() async {
    final response = await gamesCollection.get();

    if (response.size > 0) {
      List<Game> gamesList = List();
      response.docs.forEach((element) {
        Game game = Game.fromJson(element.data(), element.id);
        gamesList.add(game);
      });
      return gamesList;
    } else {
      throw Exception('Empty response');
    }
  }

  @override
  Widget build(BuildContext context) {
    // getting the user
    // and signing the user up
    // or logging the user in
    _getId().then((value) {
      this.getUser(value["id"], value["name"], value["model"]);
    });

    print(_cubeSession);
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: VoiceScreen(
        user: _user,
        session: _cubeSession,
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
      print(cubeSession);
      setState(() => _cubeSession = cubeSession);
      _getId().then((value) {
        futureUser = this.getUser(value["id"], value["name"], value["model"]);
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
    CubeUser rVal;
    CubeUser existingUser;
    String login = username;

    existingUser = await getUserByLogin(login);
    if (existingUser != null) {
      CubeUser user = CubeUser(login: username, password: 'password');
      rVal = await signIn(user);
    } else {
      CubeUser newUser = CubeUser(
          login: username,
          password: 'password',
          email: username + '@talkie-walkie.nl',
          fullName: phoneName,
          customData: "{device_type: $phoneModel}");
      var signUpVal = await signUp(newUser);
      CubeUser user = CubeUser(login: username, password: 'password');
      rVal = await signIn(user);
    }
    return rVal;

    // getUserByLogin(login).then((cubeUser) {
    //   // log user in
    //   print('found user');
    //   print(cubeUser);
    //   CubeUser user = CubeUser(login: username, password: 'password');
    //   if (_cubeSession.user == null) {
    //     signIn(user).then((cubeUser) {
    //       setState(() {
    //         _user = cubeUser;
    //       });
    //     }).catchError((error) {
    //       // sign in failed
    //       // TODO: throw error
    //     });
    //   }
    // }).catchError((error) {
    //   print('no user found');

    //   // sign new user up
    //   CubeUser user = CubeUser(
    //       login: username,
    //       password: 'password',
    //       email: username + '@talkie-walkie.nl',
    //       fullName: phoneName,
    //       customData: "{device_type: $phoneModel}");

    //     signUp(user).then((cubeUser) {
    //     print('signed up successfully.');
    //     setState(() {
    //       signedUp = true;
    //     });
    //     print(cubeUser);
    //   }).catchError((error) {
    //     print('signed up failed.');

    //     setState(() {
    //       signedUp = false;
    //     });
    //     print(error);
    //   });
    // });
  }
}
