import 'package:connectySample/src/models/initPackage.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'utils/call_manager.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';

class VoiceScreen extends StatelessWidget {
  final CubeUser user;
  final CubeSession session;

  VoiceScreen({Key key, this.user, this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print('X2: First entry ' + user.toString());

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false, title: Text('Talkie Walkie')),
      body: BodyLayout(
        user: user,
        session: session,
      ),
    );
  }
}

class BodyLayout extends StatefulWidget {
  final CubeUser user;
  final CubeSession session;

  BodyLayout({Key key, @required this.user, @required this.session})
      : super(key: key) {
    // print('X2: Second entry ' + user.toString());
  }

  @override
  _BodyLayoutState createState() {
    // print('X2: stil Second entry ' + this.user.toString());
    return _BodyLayoutState(user: this.user, session: this.session);
  }
}

class _BodyLayoutState extends State<BodyLayout> {
  CubeUser user;
  CubeSession session;
  bool _loggedIn = false;

  bool _isLoginContinues = false;
  int _selectedUserId;
  Map<int, RTCVideoRenderer> streams = {};

  String joinRoomId;
  CallManager _callManager;
  ConferenceClient callClient;
  ConferenceSession callSession;
  ConferenceSession _currentCall;

  Future<InitPackage> futurePackage;

  _BodyLayoutState({this.user, this.session});

  String muteText = "stop talking";
  String speakerText = "Start speaker";
  String joinText = 'Tap me to join room 1';
  bool showButtons = false;
  @override
  void initState() {
    super.initState();

    print('XC: ' + user.toString());
    CubeUser userLogin =
        CubeUser(id: user.id, login: user.login, password: 'password');
    _loginToCC(context, userLogin);

    futurePackage = getPackage()
        .catchError((error) => print("DDDDDDDDDDDDDDDDDDDDDDDDDDDD" + error));
  }

  @override
  void dispose() {
    super.dispose();
    streams.forEach((opponentId, stream) async {
      await stream.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('X2: third entry ' + user.toString());

    String name = this.user != null ? this.user.fullName : 's';
    dynamic talkButtons = (InitPackage package) => [];
    if (showButtons) {
      talkButtons = (InitPackage package) => ([
            GestureDetector(
              onTap: () => _muteTalking(context, user, package),
              child: Container(
                margin: EdgeInsets.all(15),
                width: 200,
                height: 100,
                decoration: BoxDecoration(color: Colors.red),
                child: Center(
                  child: Text(
                    muteText,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _toggleSpeaker(context, user, package),
              child: Container(
                margin: EdgeInsets.all(15),
                width: 200,
                height: 100,
                decoration: BoxDecoration(color: Colors.purple),
                child: Center(
                  child: Text(
                    speakerText,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
            ),
          ]);
    } else {
      talkButtons = (InitPackage package) => [];
    }

    return FutureBuilder(
        future: futurePackage,
        builder: (BuildContext context, AsyncSnapshot<InitPackage> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: EdgeInsets.all(48),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  "Select user to login hello: " + name,
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
                GestureDetector(
                  onTap: () => _startTalking(context, user, snapshot.data),
                  child: Container(
                    margin: EdgeInsets.all(15),
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Center(
                      child: Text(
                        joinText,
                        style: TextStyle(color: Colors.white, fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                ...talkButtons(snapshot.data),
              ]),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  _loginToCC(BuildContext context, CubeUser user) async {
    if (_isLoginContinues) return;

    setState(() {
      _isLoginContinues = true;
      // _selectedUserId = user.id;
    });

    if (CubeSessionManager.instance.isActiveSessionValid()) {
      print('XC: SESSION IS STILL VALID');
      await _loginToCubeChat(context, user);
    } else {
      createSession(user).then((cubeSession) async {
        print('XC: CREATED SESSION');
        await _loginToCubeChat(context, user);
      }).catchError(_processLoginError);
    }
  }

  _loginToCubeChat(BuildContext context, CubeUser user) async {
    CubeChatConnection.instance.login(user).then((cubeUser) async {
      print('XC: LOGGED IN');
      setState(() {
        _isLoginContinues = false;
        _selectedUserId = 0;
        _loggedIn = true;
      });

      // init
      _initConferenceConfig();
      // await _initCalls(cubeUser);
      joinRoomId = '1';
      // _goSelectOpponentsScreen(context, cubeUser);
    }).catchError(_processLoginError);
  }

  void _processLoginError(exception) {
    log("Login error $exception");

    setState(() {
      _isLoginContinues = false;
      _selectedUserId = 0;
      _loggedIn = false;
    });

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Login Error"),
            content: Text("Something went wrong during login to ConnectyCube"),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  _initCalls(CubeUser user) async {
    callSession.onLocalStreamReceived = (mediaStream) {
      // called when local media stream completely prepared
      print('CD: prepared');

      _onStreamAdd(ConferenceClient.instance.currentUserId, mediaStream);
    };

    callSession.onRemoteStreamReceived =
        (callSession, opponentId, mediaStream) {
      // called when remote media stream received from opponent
      print('CD: onremotereceived');

      _onStreamAdd(ConferenceClient.instance.currentUserId, mediaStream);
    };

    callSession.onPublishersReceived = (publishers) {
      // called when received new opponents/publishers
      print('CD: onpubreceived');

      subscribeToPublishers(publishers);
      handlePublisherReceived(publishers);
    };

    callSession.onPublisherLeft = (publisher) {
      // called when opponent/publisher left room
      print('CD: onpubleft');
    };

    callSession.onError = (ex) {
      // called when received some exception from conference
      print('CD: error');
    };

    callSession.onSessionClosed = (callSession) {
      print('CD: closed');
      // called when current session was closed
    };
  }

  void _initConferenceConfig() {
    ConferenceConfig.instance.url = 'wss://janus.connectycube.com:8989';
  }

  Future<InitPackage> getPackage() async {
    // if (callSession != null) {
    //   callSession.joinDialog('1', ((publishers) {
    //     log('YD: ', publishers.toString());
    //     _callManager.startCall('1', publishers,
    //         callSession.currentUserId); // event by system message e.g.
    //   }));
    // } else {
    print('DDDDDDDDDDDDDDDDDDDDDDDDDDDD: ' + callSession.toString());

    callClient = ConferenceClient.instance;

    int callType = CallType.AUDIO_CALL;
    callSession = await callClient.createCallSession(user.id, callType);
    callSession.setMicrophoneMute(false);
    callSession.enableSpeakerphone(false);

    CallManager _callManager = CallManager.instance;
    return InitPackage.auto(user, callClient, callSession, _callManager);
    // callSession.joinDialog('1', ((publishers) {
    //   log('YD: ', publishers.toString());
    //   callSession.setMicrophoneMute(false);
    //   callSession.enableSpeakerphone(false);
    //   _callManager.startCall('1', publishers,
    //       callSession.currentUserId); // event by system message e.g.
    // }));
    // }
  }

  _startTalking(
      BuildContext context, CubeUser user, InitPackage package) async {
    // activate chat
    log('PRESSED TO GO');
    print('pressing gooo');
    log('DSA: ' + package.toString());
    return;

    setState(() {
      showButtons = true;
    });
    if (joinText == 'Tap me to join room 1') {
      // inverting the text
      setState(() {
        joinText = 'Tap me to leave room 1';
      });

      if (package.session != null) {
        package.session.joinDialog('1', ((publishers) {
          log('YD: ', publishers.toString());
          package.manager.startCall('1', publishers,
              package.session.currentUserId); // event by system message e.g.
        }));
      } else {
        // callClient = ConferenceClient.instance;

        // int callType = CallType.AUDIO_CALL;
        package.session.setMicrophoneMute(false);
        callSession.enableSpeakerphone(false);
        // package.session = await callClient.createCallSession(user.id, callType);

        package.session.joinDialog('1', ((publishers) {
          log('YD: ', publishers.toString());
          package.session.setMicrophoneMute(false);
          package.session.enableSpeakerphone(false);
          package.manager.startCall('1', publishers,
              package.session.currentUserId); // event by system message e.g.
        }));
      }
    } else {
      setState(() {
        showButtons = false;
      });
      setState(() => (muteText = "stop talking"));
      setState(() => (speakerText = "Stop speaker"));

      callSession.leave();
      // inverting the text
      setState(() {
        joinText = 'Tap me to join room 1';
      });
    }
  }

  _muteTalking(BuildContext context, CubeUser user, InitPackage package) async {
    print('muting');
    if (muteText == "stop talking") {
      package.session.setMicrophoneMute(true);
      setState(() => (muteText = "start talking"));
    } else {
      package.session.setMicrophoneMute(false);
      setState(() => (muteText = "stop talking"));
    }
  }

  void _toggleSpeaker(
      BuildContext context, CubeUser user, InitPackage package) async {
    print('speaker toggle');
    if (speakerText == "Stop speaker") {
      package.session.enableSpeakerphone(false);
      setState(() => (speakerText = "Start speaker"));
    } else {
      package.session.enableSpeakerphone(true);
      setState(() => (speakerText = "Stop speaker"));
    }
  }

  void subscribeToPublishers(List<int> publishers) {
    for (int publisher in publishers) {
      callSession.subscribeToPublisher(publisher);
    }
  }

  void handlePublisherReceived(List<int> publishers) {
    // if (!_isIncoming) {
    publishers.forEach((id) => _callManager.handleAcceptCall(id));
    // }
  }

  void _onStreamAdd(int opponentId, MediaStream stream) async {
    // log("_onStreamAdd for user $opponentId", TAG);
    RTCVideoRenderer streamRender = RTCVideoRenderer();
    await streamRender.initialize();
    streamRender.srcObject = stream;
    setState(() => streams[opponentId] = streamRender);
  }
}
