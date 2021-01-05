import 'package:connectySample/src/utils/call_manager.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';

class InitPackage {
  CubeUser _user;

  CubeUser get user => _user;

  set user(CubeUser user) {
    _user = user;
  }

  ConferenceClient _client;

  ConferenceClient get client => _client;

  set client(ConferenceClient client) {
    _client = client;
  }

  ConferenceSession _session;

  ConferenceSession get session => _session;

  set session(ConferenceSession session) {
    _session = session;
  }

  CallManager _manager;

  CallManager get manager => _manager;

  set manager(CallManager manager) {
    _manager = manager;
  }

  InitPackage(
      {CubeUser user,
      ConferenceClient client,
      ConferenceSession session,
      CallManager manager}) {
    _user = user;
    _client = client;
    _session = session;
    _manager = manager;
  }

  InitPackage.blank();

  InitPackage.auto(this._user, this._client, this._session, this._manager);
}
