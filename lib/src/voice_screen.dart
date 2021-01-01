import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
// import 'package:connectycube_sdk/connectycube_sdk.dart';

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

  _BodyLayoutState({this.user, this.session});

  @override
  Widget build(BuildContext context) {
    print('X2: third entry ' + user.toString());

    String name = this.user != null ? this.user.fullName : 's';

    return Padding(
      padding: EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Select user to login hellos:" + name,
            style: TextStyle(
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}
