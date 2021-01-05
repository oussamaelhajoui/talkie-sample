// CubeUser userLogin = CubeUser(login: user.login, password: 'password');
// CubeChatConnection.instance.login(userLogin).then((loggedUser) {
//   print('XZY: ' + loggedUser.toString());
//   setState(() {
//     callClient = P2PClient.instance; // returns instance of P2PClient
//   });
//   print('XZ: ' + callClient.toString());
//   callClient.init(); // starts listening of incoming calls
//   // callClient.destroy(); // stops listening incoming calls and clears callbacks

//   // calls when P2PClient receives new incoming call
//   // callClient.onReceiveNewSession = (incomingCallSession) {};

//   // calls when any callSession closed
//   // callClient.onSessionClosed = (closedCallSession) {};

//   // creates new P2PSession
//   Set<int> opponentsIds = {};
//   int callType =
//       CallType.AUDIO_CALL; // or CallType.AUDIO_CALL // VIDEO_CALL

//   setState(() {
//     callSession = callClient.createCallSession(callType, opponentsIds);
//   });

//   callSession.startCall();
// }).catchError((error) {
//   print('XYZ: error: ' + error.toString());
// });
