// import 'package:connectycube_sdk/connectycube_sdk.dart';
// import 'package:flutter/material.dart';
// import 'utils/call_manager.dart';
// import 'package:flutter/cupertino.dart';

// class VoiceScreen extends StatelessWidget {
//   final CubeUser user;
//   final CubeSession session;
//   VoiceScreen({
//     Key key,
//     this.user,
//     this.session,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // print('X2: First entry ' + user.toString());

//     return CupertinoPageScaffold(
//       // appBar: AppBar(
//       // automaticallyImplyLeading: false, title: Text('Talkie Walkie')),
//       backgroundColor: Colors.yellow,
//       child: SafeArea(child: BodyLayout(user: user, session: session)),
//     );
//   }
// }

// class BodyLayout extends StatefulWidget {
//   final CubeUser user;
//   final CubeSession session;

//   BodyLayout({Key key, @required this.user, @required this.session})
//       : super(key: key) {
//     // print('X2: Second entry ' + user.toString());
//   }

//   @override
//   _BodyLayoutState createState() {
//     // print('X2: stil Second entry ' + this.user.toString());
//     return _BodyLayoutState(user: this.user, session: this.session);
//   }
// }

// class _BodyLayoutState extends State<BodyLayout> {
//   CubeUser user;
//   CubeSession session;
//   bool _loggedIn = false;

//   bool _isLoginContinues = false;
//   int _selectedUserId;
//   Map<int, RTCVideoRenderer> streams = {};

//   String joinRoomId;
//   // CallManager _callManager;
//   ConferenceClient _callClient;
//   ConferenceSession _callSession;
//   ConferenceSession _currentCall;
//   CallManager _callManager;

//   _BodyLayoutState({this.user, this.session});

//   String muteText = "stop talking";
//   String speakerText = "Start speaker";
//   String joinText = 'Tap me to join room 1';
//   bool showButtons = false;
//   @override
//   void initState() {
//     super.initState();

//     print('XC: ' + user.toString());
//     CubeUser userLogin =
//         CubeUser(id: user.id, login: user.login, password: 'password');
//     _loginToCC(context, userLogin);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     streams.forEach((opponentId, stream) async {
//       await stream.dispose();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('X2: third entry ' + user.toString());

//     String name = this.user != null ? this.user.fullName : 's';
//     List<dynamic> talkButtons = [];
//     if (showButtons) {
//       talkButtons = [
//         GestureDetector(
//           onTap: () => _muteTalking(context, user),
//           child: Container(
//             margin: EdgeInsets.all(15),
//             width: 200,
//             height: 100,
//             decoration: BoxDecoration(color: Colors.red),
//             child: Center(
//               child: Text(
//                 muteText,
//                 style: TextStyle(color: Colors.white, fontSize: 25),
//               ),
//             ),
//           ),
//         ),
//         GestureDetector(
//           onTap: () => _toggleSpeaker(context, user),
//           child: Container(
//             margin: EdgeInsets.all(15),
//             width: 200,
//             height: 100,
//             decoration: BoxDecoration(color: Colors.purple),
//             child: Center(
//               child: Text(
//                 speakerText,
//                 style: TextStyle(color: Colors.white, fontSize: 25),
//               ),
//             ),
//           ),
//         ),
//       ];
//     } else {
//       talkButtons = [];
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: <Widget>[
//         Padding(
//           padding: EdgeInsets.all(48),
//           child: Column(mainAxisSize: MainAxisSize.min, children: [
//             Text(
//               "Select user to login hello: " + name,
//               style: TextStyle(
//                 fontSize: 22,
//               ),
//             ),
//             GestureDetector(
//               onTap: () => _startTalking(context, user),
//               child: Container(
//                 margin: EdgeInsets.all(15),
//                 width: 200,
//                 height: 200,
//                 decoration: BoxDecoration(color: Colors.blue),
//                 child: Center(
//                   child: Text(
//                     joinText,
//                     style: TextStyle(color: Colors.white, fontSize: 25),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//             ...talkButtons,
//           ]),
//         ),
//       ],
//     );
//   }

//   _loginToCC(BuildContext context, CubeUser user) async {
//     if (_isLoginContinues) return;

//     setState(() {
//       _isLoginContinues = true;
//       // _selectedUserId = user.id;
//     });

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
//       setState(() {
//         _isLoginContinues = false;
//         _selectedUserId = 0;
//         _loggedIn = true;
//       });

//       // init
//       _initConferenceConfig();
//       // await _initCalls(cubeUser, null);
//       joinRoomId = '1';
//       // _goSelectOpponentsScreen(context, cubeUser);
//     }).catchError(_processLoginError);
//   }

//   void _processLoginError(exception) {
//     log("Login error $exception");

//     setState(() {
//       _isLoginContinues = false;
//       _selectedUserId = 0;
//       _loggedIn = false;
//     });

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

//   _initCalls(CubeUser user, ConferenceSession __callSession) async {
//     _callClient = ConferenceClient.instance;

//     setState(() {
//       _callManager = CallManager.instance;
//     });

//     int callType = CallType.AUDIO_CALL;
//     if (__callSession == null) {
//       __callSession = await _callClient.createCallSession(user.id, callType);
//       print('CREATEDX 1: ' + _callSession.toString());
//       setState(() {
//         _callSession = __callSession;
//       });
//     }

//     __callSession.onLocalStreamReceived = (mediaStream) {
//       // called when local media stream completely prepared
//       print('CD: prepared');

//       _onStreamAdd(ConferenceClient.instance.currentUserId, mediaStream);
//     };

//     __callSession.onRemoteStreamReceived =
//         (callSession, opponentId, mediaStream) {
//       // called when remote media stream received from opponent
//       print('CD: onremotereceived');

//       _onStreamAdd(ConferenceClient.instance.currentUserId, mediaStream);
//     };

//     __callSession.onPublishersReceived = (publishers) {
//       // called when received new opponents/publishers
//       print('CD: onpubreceived');

//       subscribeToPublishers(publishers);
//       handlePublisherReceived(publishers);
//     };

//     __callSession.onPublisherLeft = (publisher) {
//       // called when opponent/publisher left room
//       print('CD: onpubleft');
//       __callSession.unsubscribeFromPublisher(publisher);
//     };

//     __callSession.onError = (ex) {
//       // called when received some exception from conference
//       print('CD: error');
//     };

//     __callSession.onSessionClosed = (callSession) {
//       print('CD: closed');
//       // called when current session was closed

//       // __callSession.unsubscribeFromPublisher(publisher);
//     };
//   }

//   void _initConferenceConfig() {
//     ConferenceConfig.instance.url = 'wss://janus.connectycube.com:8989';
//   }

//   _startTalking(BuildContext context, CubeUser user) async {
//     // activate chat
//     log('PRESSED TO GO');
//     print('pressing gooo');

//     setState(() {
//       showButtons = true;
//     });
//     if (joinText == 'Tap me to join room 1') {
//       // inverting the text
//       setState(() {
//         joinText = 'Tap me to leave room 1';
//       });

//       // if (_callSession != null) {
//       //   _callSession.joinDialog('1', ((publishers) {
//       //     log('YD: ', publishers.toString());
//       //     _callManager.startCall('1', publishers,
//       //         _callSession.currentUserId); // event by system message e.g.
//       //   }));
//       // } else {
//       _callClient = ConferenceClient.instance;

//       int callType = CallType.AUDIO_CALL;
//       _callSession = await _callClient.createCallSession(user.id, callType);
//       await _initCalls(user, _callSession);

//       setState(() => _callSession = _callSession);
//       // _callSession.setMicrophoneMute(false);
//       // _callSession.enableSpeakerphone(false);

//       // _callSession.setMicrophoneMute(false);
//       // _callSession.enableSpeakerphone(true);
//       print("CREATEDX 2:" + _callSession.toString());
//       _callSession.joinDialog('1', ((publishers) {
//         log('YD: ', publishers.toString());
//         print('publishersx:' + publishers.toString());
//         _callManager.startCall('1', publishers,
//             _callSession.currentUserId); // event by system message e.g.
//         subscribeToPublishers(publishers);
//         handlePublisherReceived(publishers);
//       }));
//       // }
//     } else {
//       print("XDX: " + _callSession.toString());
//       setState(() {
//         showButtons = false;
//       });

//       setState(() {
//         muteText = "stop talking";
//         speakerText = "Stop speaker";
//       });

//       _callSession.setMicrophoneMute(false);
//       _callSession.enableSpeakerphone(true);

//       _callManager.stopCall();

//       _callSession.leave();
//       // inverting the text
//       setState(() {
//         joinText = 'Tap me to join room 1';
//         _callSession = null;
//       });
//     }
//   }

//   _muteTalking(BuildContext context, CubeUser user) async {
//     print('muting');
//     if (muteText == "stop talking") {
//       _callSession.setMicrophoneMute(true);
//       setState(() => (muteText = "start talking"));
//     } else {
//       _callSession.setMicrophoneMute(false);
//       setState(() => (muteText = "stop talking"));
//     }
//   }

//   void _toggleSpeaker(BuildContext context, CubeUser user) async {
//     print('speaker toggle');
//     if (speakerText == "Stop speaker") {
//       _callSession.enableSpeakerphone(false);
//       setState(() => (speakerText = "Start speaker"));
//     } else {
//       _callSession.enableSpeakerphone(true);
//       setState(() => (speakerText = "Stop speaker"));
//     }
//   }

//   void subscribeToPublishers(List<int> publishers) {
//     for (int publisher in publishers) {
//       _callSession.subscribeToPublisher(publisher);
//     }
//   }

//   void handlePublisherReceived(List<int> publishers) {
//     // if (!_isIncoming) {
//     print('callmanager' + _callManager.toString());
//     publishers.forEach((id) => _callManager.handleAcceptCall(id));

//     print("pubs" + publishers.toString());
//     // }
//   }

//   void _onStreamAdd(int opponentId, MediaStream stream) async {
//     // log("_onStreamAdd for user $opponentId", TAG);
//     RTCVideoRenderer streamRender = RTCVideoRenderer();
//     await streamRender.initialize();
//     streamRender.srcObject = stream;
//     setState(() => streams[opponentId] = streamRender);
//   }
// }
