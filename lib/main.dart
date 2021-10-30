import 'package:bd_app/Model/Colors.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/PostBloodRequirement.dart';
import 'package:bd_app/Screens/DashboardScreen.dart';
import 'package:bd_app/appUpdate.dart';
import 'package:bd_app/lifeCycle.dart';
import 'package:bd_app/mockLocation.dart';
import 'package:bd_app/provider/server.dart';
import 'package:bd_app/provider/time.dart';
import 'package:bd_app/remoteConfig.dart';
import 'package:bd_app/services/DynamicLinkService.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'Screens/TestingNotification/MyAppllication.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bd_app/Screens/OnBoardUser/UserEmailScreen.dart';
import 'package:get/get.dart';
import 'Screens/OnBoardUser/SplashScreen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

RemoteConfigService _remoteConfigService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeRemoteConfig();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //     statusBarColor: Colors.white,
  //
  //     // statusBarBrightness: Brightness.dark
  //     statusBarIconBrightness: Brightness.dark
  //     // statusBarIconBrightness: Brightness.dark,
  //     //   statusBarBrightness: Brightness.dark
  //     ));

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    // statusBarBrightness: Brightness.dark
  )); // status bar color
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  await Future.wait([
    precachePicture(
      ExactAssetPicture(
          SvgPicture.svgStringDecoder, 'images/HelpingHands_Red.svg'),
      null,
    ),
  ]);

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) => runApp(MyApp(packageInfo)));
}

class MyApp extends StatelessWidget {
  PackageInfo packageInfo;
  MyApp(this.packageInfo);
  Notify _notify = new Notify();
  Time _time = Time();
  bool critical_update = false;
  bool normal_update = false;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // _notify = Provider.of<Notify>(context);
    print("version");
    print(packageInfo.version);
    print(_remoteConfigService.getCriticalVersion);
    print(_remoteConfigService.getCurrentversion);

    if (_notify.versionCompare(
        packageInfo.version, _remoteConfigService.getCriticalVersion)) {
      print("critical update");
      critical_update = true;
    }

    //  if (_notify.versionCompare(
    //         "1.0.0","1.0.1") <
    //     0) {
    //   print("critical update");
    //   critical_update = true;
    // }

    if (_notify.versionCompare(
        packageInfo.version, _remoteConfigService.getCurrentversion)) {
      print("normal update");
      normal_update = true;
    }

    print("update info");

    print(critical_update);
    print(normal_update);

    _notify.setUpadte(
        critical_update, normal_update, _remoteConfigService.getUpdateMessage);

    // _notify.initDynamicLinks();

    // _notify.extractRefferalCodeFromLink();

    try {
      print("Trying");
      print(_notify.textint);
      _notify.initDynamicLinks();
    } catch (e) {
      print(e);
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => _notify),
        ChangeNotifierProvider(create: (_) => _time),
      ],
      child: LifeCycleManager(
        child: ScreenUtilInit(
          designSize: Size(1080, 2160),
          allowFontScaling: false,
          builder: () => MaterialApp(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: CustomColor.red,
              // bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.black54),
              buttonTheme: ButtonThemeData(
                buttonColor: Colors.deepPurple, //  <-- dark color
                textTheme: ButtonTextTheme
                    .primary, //  <-- this auto selects the right color
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: SplashScreen(),
            builder: EasyLoading.init(),
            navigatorKey: Get.key,
          ),
        ),
      ),
    );
  }
}

initializeRemoteConfig() async {
  _remoteConfigService = await RemoteConfigService.getInstance();
  await _remoteConfigService.initialize();
}
