import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'utils/call_manager.dart';
import 'package:flutter/cupertino.dart';

class VoiceScreen extends StatelessWidget {
  final CubeUser user;
  final CubeSession session;
  VoiceScreen({
    Key key,
    this.user,
    this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print('X2: First entry ' + user.toString());

    return Scaffold(
      // appBar: AppBar(
      // automaticallyImplyLeading: false, title: Text('Talkie Walkie')),
      backgroundColor: Colors.yellow,
      body: BodyLayout(user: user, session: session),
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
  // CallManager _callManager;
  ConferenceClient _callClient;
  ConferenceSession _callSession;
  ConferenceSession _currentCall;
  CallManager _callManager;

  _BodyLayoutState({this.user, this.session});

  String muteText = "stop talking";
  String speakerText = "Start speaker";
  String joinText = 'Tap me to join room 1';
  bool showButtons = false;

  int _channelFirstPart = 9;
  int _channelSecondPart = 99;
  double _btnTalkOpacity = 1;
  double _pwrOpacity = 1;
  double _btnLockOpacity = 1;
  bool _btnDownPressed = false;
  bool _btnUpPressed = false;
  bool _btnTalkingPressed = false;

  bool _loopActive = false;
  String talkImage = "assets/images/talk-image-off.png";

  @override
  void initState() {
    super.initState();

    print('XC: ' + user.toString());
    CubeUser userLogin =
        CubeUser(id: user.id, login: user.login, password: 'password');
    _loginToCC(context, userLogin);
  }

  @override
  void dispose() {
    super.dispose();
    streams.forEach((opponentId, stream) async {
      await stream.dispose();
    });
  }

  void _increaseCounterWhilePressed() async {
    // make sure that only one loop is active
    if (_loopActive) return;

    _loopActive = true;

    // debouncing the button
    await Future.delayed(Duration(milliseconds: 200));

    while (_btnDownPressed) {
      // do your thing
      setState(() {
        if (_channelFirstPart == 0 && _channelSecondPart == 0) return;
        if (_channelSecondPart == 0) {
          _channelFirstPart -= 1;
          _channelSecondPart = 99;
        } else {
          _channelSecondPart -= 1;
        }
      });

      // wait a bit
      await Future.delayed(Duration(milliseconds: 200));
    }

    while (_btnUpPressed) {
      setState(() {
        if (_channelSecondPart == 99) {
          _channelFirstPart += 1;
          _channelSecondPart = 0;
        } else {
          _channelSecondPart += 1;
        }
      });

      // wait a bit
      await Future.delayed(Duration(milliseconds: 200));
    }

    _loopActive = false;
  }

  @override
  Widget build(BuildContext context) {
    print('X2: third entry ' + user.toString());

    String channelRenderer = '00.00';
    String channelStringFirstPart = '';
    String channelStringSecondPart = '';

    if (_channelFirstPart < 10)
      channelStringFirstPart = '0' + _channelFirstPart.toString();
    else
      channelStringFirstPart = _channelFirstPart.toString();

    if (_channelSecondPart < 10)
      channelStringSecondPart = '0' + _channelSecondPart.toString();
    else
      channelStringSecondPart = _channelSecondPart.toString();

    channelRenderer = channelStringFirstPart + '.' + channelStringSecondPart;

    String name = this.user != null ? this.user.fullName : 's';
    List<dynamic> talkButtons = [];
    if (showButtons) {
      talkButtons = [
        GestureDetector(
          onTap: () => _muteTalking(context, user),
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
          onTap: () => _toggleSpeaker(context, user, _callSession),
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
      ];
    } else {
      talkButtons = [];
    }

    return SafeArea(
      child: new Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Align(
              alignment: Alignment.center,
              child: new Column(
                // alignment: Alignment.bottomCenter,
                children: <Widget>[
                  new Container(
                    // margin: new EdgeInsets.all(20.0),
                    padding: new EdgeInsets.all(20),
                    // color: CupertinoColors.systemTeal,
                    width: MediaQuery.of(context).size.width / 100 * 90,
                    height: MediaQuery.of(context).size.height /
                        100 *
                        30, // 30 precent of the screen
                    child: new Column(
                      children: [
                        new Container(
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Text(
                                "00.00",
                                // style: DefaultTextStyle.of(context)
                                //     .style
                                //     .apply(fontSizeFactor: 2.0),
                                style: TextStyle(
                                  fontFamily: '24 display',
                                  fontSize: 50,
                                  color: Colors.black12,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              Text(
                                channelRenderer,
                                // style: DefaultTextStyle.of(context)
                                //     .style
                                //     .apply(fontSizeFactor: 2.0),
                                style: TextStyle(
                                  fontFamily: '24 display',
                                  fontSize: 50,
                                  color: Colors.black,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                          width: MediaQuery.of(context).size.width /
                              100 *
                              90 / // this is the width of the parent
                              100 *
                              50,
                          height: MediaQuery.of(context).size.height /
                              100 *
                              30 /
                              100 *
                              30,
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius:
                                new BorderRadius.all(Radius.circular(3)),
                            border: Border.all(
                              width: 5,
                              color: Colors.black,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        new IntrinsicHeight(
                            child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (_callSession != null)
                                    _toggleSpeaker(context, user, _callSession);
                                },
                                child: Opacity(
                                  opacity: _btnLockOpacity,
                                  child: new Container(
                                    height: MediaQuery.of(context).size.width /
                                        100 *
                                        23 // this is the width of the parent
                                    ,
                                    child: Center(
                                      child: Text(
                                        "Lock",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        width: 5,
                                        color: Colors.black,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Listener(
                                onPointerDown: (details) {
                                  print(details);
                                  _btnUpPressed = true;
                                  _increaseCounterWhilePressed();
                                },
                                onPointerUp: (details) {
                                  _btnUpPressed = false;
                                  print(details);
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    print('pressed up');
                                    setState(() {
                                      if (_channelSecondPart == 99) {
                                        _channelFirstPart += 1;
                                        _channelSecondPart = 0;
                                      } else {
                                        _channelSecondPart += 1;
                                      }
                                    });
                                  },
                                  child: new Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: new Container(
                                          child: Center(
                                              child: Text(
                                            "Up",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              decoration: TextDecoration.none,
                                            ),
                                          )),
                                          decoration: BoxDecoration(
                                            color: Colors.black45,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                            border: Border.all(
                                              width: 5,
                                              color: Colors.black,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Listener(
                                          onPointerDown: (details) {
                                            print(details);
                                            _btnDownPressed = true;
                                            _increaseCounterWhilePressed();
                                          },
                                          onPointerUp: (details) {
                                            _btnDownPressed = false;
                                            print(details);
                                          },
                                          child: GestureDetector(
                                            onTap: () => (setState(() {
                                              if (_channelFirstPart == 0 &&
                                                  _channelSecondPart == 0)
                                                return;
                                              if (_channelSecondPart == 0) {
                                                _channelFirstPart -= 1;
                                                _channelSecondPart = 99;
                                              } else {
                                                _channelSecondPart -= 1;
                                              }
                                            })),
                                            child: new Container(
                                              child: Center(
                                                child: Text(
                                                  "Down",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.black45,
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                ),
                                                border: Border.all(
                                                  width: 5,
                                                  color: Colors.black,
                                                  style: BorderStyle.solid,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  print('Power');
                                  _startTalking(context, user, channelRenderer);
                                },
                                child: Opacity(
                                  opacity: _pwrOpacity,
                                  child: new Container(
                                    child: Center(
                                      child: Text(
                                        "Power",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        width: 5,
                                        color: Colors.black,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: new BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                      ),
                      border: Border.all(
                        width: 5,
                        color: Colors.black,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _muteTalking(context, user),
                    onTapDown: (TapDownDetails details) =>
                        (setState(() => (_btnTalkOpacity = 0.5))),
                    onTapUp: (TapUpDetails details) =>
                        (setState(() => (_btnTalkOpacity = 1))),
                    child: Opacity(
                      opacity: _btnTalkOpacity,
                      child: new Container(
                        alignment: Alignment.center,
                        margin: new EdgeInsets.only(top: 80),
                        // color: CupertinoColors.systemTeal,
                        width: MediaQuery.of(context).size.width / 100 * 90,
                        height: MediaQuery.of(context).size.height /
                            100 *
                            30, // 30 precent of the screen
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(talkImage),
                          ),
                        ),
                      ),
                    ),
                  ), // ptt button
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
      // await _initCalls(cubeUser, null);
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

  _initCalls(CubeUser user, ConferenceSession __callSession) async {
    _callClient = ConferenceClient.instance;

    setState(() {
      _callManager = CallManager.instance;
    });

    int callType = CallType.AUDIO_CALL;
    if (__callSession == null) {
      __callSession = await _callClient.createCallSession(user.id, callType);
      print('CREATEDX 1: ' + _callSession.toString());
      setState(() {
        _callSession = __callSession;
      });
    }

    __callSession.onLocalStreamReceived = (mediaStream) {
      // called when local media stream completely prepared
      print('CD: prepared');

      _onStreamAdd(ConferenceClient.instance.currentUserId, mediaStream);
    };

    __callSession.onRemoteStreamReceived =
        (callSession, opponentId, mediaStream) {
      // called when remote media stream received from opponent
      print('CD: onremotereceived');

      _onStreamAdd(ConferenceClient.instance.currentUserId, mediaStream);
    };

    __callSession.onPublishersReceived = (publishers) {
      // called when received new opponents/publishers
      print('CD: onpubreceived');

      subscribeToPublishers(publishers);
      handlePublisherReceived(publishers);
    };

    __callSession.onPublisherLeft = (publisher) {
      // called when opponent/publisher left room
      print('CD: onpubleft');
      __callSession.unsubscribeFromPublisher(publisher);
    };

    __callSession.onError = (ex) {
      // called when received some exception from conference
      print('CD: error');
    };

    __callSession.onSessionClosed = (callSession) {
      print('CD: closed');
      // called when current session was closed

      // __callSession.unsubscribeFromPublisher(publisher);
    };
  }

  void _initConferenceConfig() {
    ConferenceConfig.instance.url = 'wss://janus.connectycube.com:8989';
  }

  _startTalking(
      BuildContext context, CubeUser user, String _channelRenderer) async {
    // activate chat
    log('PRESSED TO GO');
    print('pressing gooo');

    setState(() {
      showButtons = true;
      _pwrOpacity = 0.5;
    });
    if (joinText == 'Tap me to join room 1') {
      // inverting the text

      setState(() {
        joinText = 'Tap me to leave room 1';
        talkImage = "assets/images/talk-image-pushed.png";
      });

      // if (_callSession != null) {
      //   _callSession.joinDialog('1', ((publishers) {
      //     log('YD: ', publishers.toString());
      //     _callManager.startCall('1', publishers,
      //         _callSession.currentUserId); // event by system message e.g.
      //   }));
      // } else {
      _callClient = ConferenceClient.instance;

      int callType = CallType.AUDIO_CALL;
      _callSession = await _callClient.createCallSession(user.id, callType);
      await _initCalls(user, _callSession);

      setState(() => _callSession = _callSession);
      // _callSession.setMicrophoneMute(false);
      // _callSession.enableSpeakerphone(false);

      // _callSession.setMicrophoneMute(false);
      // _callSession.enableSpeakerphone(true);
      print("CREATEDX 2:" + _callSession.toString());
      _callSession.joinDialog(_channelRenderer, ((publishers) {
        log('YD: ', publishers.toString());
        print('publishersx:' + publishers.toString());
        _callManager.startCall(
            _channelRenderer, publishers, _callSession.currentUserId);
        // event by system message e.g.
        subscribeToPublishers(publishers);
        handlePublisherReceived(publishers);
      }));
      // }
    } else {
      print("XDX: " + _callSession.toString());
      setState(() {
        showButtons = false;
        _pwrOpacity = 1;
        talkImage = "assets/images/talk-image-off.png";
      });

      setState(() {
        muteText = "stop talking";
        speakerText = "Stop speaker";
      });

      _callSession.setMicrophoneMute(false);
      _callSession.enableSpeakerphone(true);

      _callManager.stopCall();

      _callSession.leave();
      // inverting the text
      setState(() {
        joinText = 'Tap me to join room 1';
        _callSession = null;
      });
    }
  }

  _muteTalking(BuildContext context, CubeUser user) async {
    print('muting');
    if (muteText == "stop talking") {
      _callSession.setMicrophoneMute(true);
      setState(() => (muteText = "start talking"));
    } else {
      _callSession.setMicrophoneMute(false);
      setState(() => (muteText = "stop talking"));
    }
  }

  void _toggleSpeaker(
      BuildContext context, CubeUser user, ConferenceSession calSession) async {
    print('speaker toggle');
    if (speakerText == "Stop speaker") {
      calSession.enableSpeakerphone(false);
      setState(() => (speakerText = "Start speaker"));
      setState(() {
        _btnLockOpacity = 0.5;
      });
    } else {
      calSession.enableSpeakerphone(true);
      setState(() => (speakerText = "Stop speaker"));
      setState(() {
        _btnLockOpacity = 1;
      });
    }
  }

  void subscribeToPublishers(List<int> publishers) {
    for (int publisher in publishers) {
      _callSession.subscribeToPublisher(publisher);
    }
  }

  void handlePublisherReceived(List<int> publishers) {
    // if (!_isIncoming) {
    print('callmanager' + _callManager.toString());
    publishers.forEach((id) => _callManager.handleAcceptCall(id));

    print("pubs" + publishers.toString());
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
