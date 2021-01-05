// import 'dart:io';
// import 'package:connectySample/src/Notifiers/cubeModel.dart';

// import 'package:flutter/material.dart';

// import 'package:provider/provider.dart';

// import 'package:connectycube_sdk/connectycube_sdk.dart';

// import 'src/utils/configs.dart' as config;
// import 'src/voice_screen.dart';
// import 'src/utils/call_manager.dart';

// import 'src/models/initPackage.dart';
// import 'package:device_info/device_info.dart';

// void main() {
//   // runApp(App());
//   runApp(
//     ChangeNotifierProvider<CubeModel>(
//       create: (context) => CubeModel(),
//       child: App(),
//     ),
//   );
// }

// class App extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return _AppState();
//   }
// }

// class _AppState extends State<App> {
//   CubeUser _user;
//   CubeSession _cubeSession;

//   Future<InitPackage> futureUser;
//   bool signedUp;

//   @override
//   Widget build(BuildContext context) {
//     // getting the user
//     // and signing the user up
//     // or logging the user in
//     // _getId().then((value) {
//     //   this.getUser(value["id"], value["name"], value["model"]);
//     // });

//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: Colors.green,
//       ),
//       home: FutureBuilder(
//         future: futureUser,
//         builder: (BuildContext context, AsyncSnapshot<InitPackage> snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return VoiceScreen(
//               user: snapshot.data.user,
//               session: _cubeSession,
//               callSession: snapshot.data.session,
//               callClient: snapshot.data.client,
//             );
//           } else {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     init(
//       config.APP_ID,
//       config.AUTH_KEY,
//       config.AUTH_SECRET,
//     );
//     // CubeSettings.instance.isDebugEnabled = false;

//     // Sign up user or

//     createSession().then((cubeSession) {
//       setState(() => _cubeSession = cubeSession);
//       _getId().then((value) {
//         setState(() {
//           ConferenceClient _callClient;

//           _callClient = ConferenceClient.instance;
//           int callType = CallType.AUDIO_CALL;
//           getUserRaw(value["id"], value["name"], value["model"])
//               .then((CubeUser user) {
//             _callClient
//                 .createCallSession(user.id, callType)
//                 .then((_callSession) async {
//               futureUser = this.getUser(value["id"], value["name"],
//                   value["model"], _callSession, _callClient);

//               ConferenceSession callSession = await ConferenceClient.instance
//                   .createCallSession(
//                       CubeChatConnection.instance.currentUser.id);
//             });
//           });
//         });
//       });
//     }).catchError((error) {});
//   }

//   Future<Map<String, String>> _getId() async {
//     Map<String, String> returnObject = {
//       "id": null,
//       "name": null,
//       "model": null
//     };
//     var deviceInfo = DeviceInfoPlugin();
//     if (Platform.isIOS) {
//       var iosDeviceInfo = await deviceInfo.iosInfo;
//       print("DEVM: IOS");
//       print('name:' + iosDeviceInfo.name);

//       returnObject["id"] = iosDeviceInfo.identifierForVendor; // unique ID iOS
//       returnObject["name"] = iosDeviceInfo.name;
//       returnObject["model"] = iosDeviceInfo.utsname.machine;

//       return returnObject;
//     } else {
//       var androidDeviceInfo = await deviceInfo.androidInfo;
//       print("DEVM: ANDROID");
//       print('name:' + androidDeviceInfo.version.codename);

//       returnObject["id"] = androidDeviceInfo.androidId; // unique ID Android
//       returnObject["name"] = androidDeviceInfo.version.codename;
//       returnObject["model"] = androidDeviceInfo.model;

//       return returnObject;
//     }
//   }

//   Future<InitPackage> getUser(
//       String username,
//       String phoneName,
//       String phoneModel,
//       ConferenceSession callSession,
//       ConferenceClient callClient) async {
//     print('X0: signing');
//     CubeUser rVal;

//     InitPackage package = new InitPackage();
//     package.client = callClient;
//     package.session = callSession;
//     package.user = rVal;

//     return package;
//   }

//   Future<CubeUser> getUserRaw(username, phoneName, phoneModel) async {
//     CubeUser rUser;

//     CubeUser existingUser;
//     String login = username;

//     existingUser = await getUserByLogin(login).catchError((error) => null);
//     print('FX0: ' + existingUser.toString());
//     if (existingUser != null) {
//       CubeUser user = CubeUser(login: username, password: 'password');
//       rUser = await signIn(user);
//       print('X0: direct singing in ' + rUser.toString());
//     } else {
//       CubeUser newUser = CubeUser(
//           login: username,
//           password: 'password',
//           email: username + '@talkie-walkie.nl',
//           fullName: phoneName,
//           customData: "{device_type: $phoneModel}");
//       var signUpVal = await signUp(newUser);
//       print('X0: signup val is comming up ' + signUpVal.toString());
//       CubeUser user = CubeUser(login: username, password: 'password');
//       rUser = await signIn(user);
//       print('X0: rval is comming up ' + rUser.toString());
//     }
//     await _loginToCC(context, rUser);

//     return rUser;
//   }

//   _loginToCC(BuildContext context, CubeUser user) async {
//     if (CubeSessionManager.instance.isActiveSessionValid()) {
//       print('XC: SESSION IS STILL VALID');
//       await _loginToCubeChat(context, user);
//     } else {
//       createSession(user).then((cubeSession) async {
//         print('XC: CREATED SESSION');
//         await _loginToCubeChat(context, user);
//       }).catchError(_processLoginError);
//     }
//   }

//   _loginToCubeChat(BuildContext context, CubeUser user) async {
//     CubeChatConnection.instance.login(user).then((cubeUser) async {
//       print('XC: LOGGED IN');

//       // init
//       ConferenceConfig.instance.url = 'wss://janus.connectycube.com:8989';

//       // _goSelectOpponentsScreen(context, cubeUser);
//     }).catchError(_processLoginError);
//   }

//   void _processLoginError(exception) {
//     log("Login error $exception");

//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Login Error"),
//             content: Text("Something went wrong during login to ConnectyCube"),
//             actions: <Widget>[
//               FlatButton(
//                 child: Text("OK"),
//                 onPressed: () => Navigator.of(context).pop(),
//               )
//             ],
//           );
//         });
//   }
// }
