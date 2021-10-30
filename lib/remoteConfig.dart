import 'package:firebase_remote_config/firebase_remote_config.dart';

const String _BOOLEAN_VALUE = 'sample_bool_value';
const String _INT_VALUE = 'sample_int_value';
const String _STRING_VALUE = 'sample_string_value';

class RemoteConfigService {
  final RemoteConfig _remoteConfig;
  RemoteConfigService({RemoteConfig remoteConfig})
      : _remoteConfig = remoteConfig;

  final defaults = <String, dynamic>{
    "critical_version": "1.0.0",
    "current_version": "1.0.0",
    "message": "normage message",
  };

  static RemoteConfigService _instance;
  static Future<RemoteConfigService> getInstance() async {
    if (_instance == null) {
      _instance = RemoteConfigService(
        remoteConfig: await RemoteConfig.instance,
      );
    }
    return _instance;
  }

  String get getCriticalVersion => _remoteConfig.getString("critical_version");
  String get getCurrentversion => _remoteConfig.getString("current_version");
  String get getUpdateMessage => _remoteConfig.getString("message");

  Future initialize() async {
    try {
      await _remoteConfig.setDefaults(defaults);
      await _fetchAndActivate();
    } on FetchThrottledException catch (e) {
      print("Rmeote Config fetch throttled: $e");
    } catch (e) {
      print("Unable to fetch remote config. Default value will be used");
    }
  }

  Future _fetchAndActivate() async {
    await _remoteConfig.fetch(expiration: Duration(seconds: 0));
    await _remoteConfig.activateFetched();
    print("critical version::: $getCriticalVersion");
    print("current version::: $getCurrentversion");
  }
}
