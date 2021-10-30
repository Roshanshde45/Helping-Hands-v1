import 'package:bd_app/Screens/ActionButtonScreens/SearchScreen.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/NewPatientDetailScreen.dart';
import 'package:bd_app/Screens/BottomNavigationScreens/Post/PatientDetailScreen.dart';
import 'package:bd_app/Screens/TabBarScreens_Home/myRequests/DonorListScreen.dart';
import 'package:bd_app/provider/server.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:bd_app/Screens/RepeatingScreens/PatientDetailLinkPush.dart';
import 'package:provider/provider.dart';

class DynamicLinkService {
  String uriPrefix = "https://hhapp.page.link";
  String link = "http://helpingHandsassist.in/";
  String appId = "app.helpinghands";
  Notify _notify;
  Future handleDynamicLinks(BuildContext context) async {
    // 1. Get the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    // 2. handle link that has been retrieved
    _handleDeepLink(context, data);

    // 3. Register a link callback to fire if the app is opened up from the background
    // using a dynamic link.
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      // 3a. handle link that has been retrieved
      _handleDeepLink(context, dynamicLink);
    }, onError: (OnLinkErrorException e) async {
      print('Link Failed: ${e.message}');
    });
  }

  Future<String> createFirstPostLink(
      {String postId,
      String bloodGrp,
      @required String requirementType}) async {
    String bloodGrpImg;

    if (bloodGrp == "A-") {
      bloodGrpImg =
          "https://firebasestorage.googleapis.com/v0/b/helping-hands-app-dev.appspot.com/o/BloodGroupIcons%2FA-.png?alt=media&token=72beed42-85e9-4e10-b8b6-c5d7eb1ab4b9";
    } else if (bloodGrp == "B-") {
      bloodGrpImg =
          "https://firebasestorage.googleapis.com/v0/b/helping-hands-app-dev.appspot.com/o/BloodGroupIcons%2FB-.png?alt=media&token=b9bfda3f-4508-4ea1-9f46-6225ed2d60e3";
    } else if (bloodGrp == "AB-") {
      bloodGrpImg =
          "https://firebasestorage.googleapis.com/v0/b/helping-hands-app-dev.appspot.com/o/BloodGroupIcons%2FAB-.png?alt=media&token=9a8944a7-39d4-4340-90c6-c52cbdcc9b5a";
    } else if (bloodGrp == "O-") {
      bloodGrpImg =
          "https://firebasestorage.googleapis.com/v0/b/helping-hands-app-dev.appspot.com/o/BloodGroupIcons%2FO-.png?alt=media&token=6250cb6f-56dd-4656-903d-15deedbc0544";
    } else if (bloodGrp == "A+") {
      bloodGrpImg =
          "https://firebasestorage.googleapis.com/v0/b/helping-hands-app-dev.appspot.com/o/BloodGroupIcons%2FA%2B.png?alt=media&token=da313f65-dfae-4cb2-b5fd-b09f724484b2";
    } else if (bloodGrp == "B+") {
      bloodGrpImg =
          "https://firebasestorage.googleapis.com/v0/b/helping-hands-app-dev.appspot.com/o/BloodGroupIcons%2FB%2B.png?alt=media&token=66071afe-519f-4aee-9e97-1b0ef92ceea7";
    } else if (bloodGrp == "AB+") {
      bloodGrpImg =
          "https://firebasestorage.googleapis.com/v0/b/helping-hands-app-dev.appspot.com/o/BloodGroupIcons%2FAB%2B.png?alt=media&token=05d78118-79d7-4e4e-b69e-198d18ff5718";
    } else if (bloodGrp == "O+") {
      bloodGrpImg =
          "https://firebasestorage.googleapis.com/v0/b/helping-hands-app-dev.appspot.com/o/BloodGroupIcons%2FO%2B.png?alt=media&token=431b3c96-09f7-4318-b4e1-04db872d82c7";
    } else {}

    print("dynamic postId" + postId);

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: uriPrefix,
      link: Uri.parse(link + 'post?postId=$postId'),
      androidParameters: AndroidParameters(
        packageName: appId,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.example.ios',
        minimumVersion: '1.0.1',
        appStoreId: '123456789',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'example-promo',
        medium: 'social',
        source: 'orkut',
      ),
      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
        providerToken: '123456',
        campaignToken: 'example-promo',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: '$bloodGrp ${requirementType.toUpperCase()} Required',
          description: '',
          imageUrl: Uri.parse(bloodGrpImg)),
    );

    final Uri dynamicUrl = await parameters.buildUrl();
    final ShortDynamicLink shortenedLink =
        await DynamicLinkParameters.shortenUrl(
      dynamicUrl,
      DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );

    return shortenedLink.shortUrl.toString();
  }

  Future<String> createShareReferalLink(String referalCode) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: uriPrefix,
      link: Uri.parse(link + 'refer?referalCode=$referalCode'),
      androidParameters: AndroidParameters(
        packageName: appId,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.example.ios',
        minimumVersion: '1.0.1',
        appStoreId: '123456789',
      ),
      googleAnalyticsParameters: GoogleAnalyticsParameters(
        campaign: 'example-promo',
        medium: 'social',
        source: 'orkut',
      ),
      itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
        providerToken: '123456',
        campaignToken: 'example-promo',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: 'Join me on Helping Hands!',
          description: "Referrals!",
          imageUrl: Uri.parse("https://firebasestorage.googleapis.com/v0/b/"
              "helping-hands-app-dev.appspot.com/o/AppImages%2FHelpingHand%"
              "20Logo.png?alt=media&token=a7d1eefe-d2d1-4ef6-97f5-d5d77a092b9b")),
    );

    final Uri dynamicUrl = await parameters.buildUrl();
    final ShortDynamicLink shortenedLink =
        await DynamicLinkParameters.shortenUrl(
      dynamicUrl,
      DynamicLinkParametersOptions(
          shortDynamicLinkPathLength: ShortDynamicLinkPathLength.unguessable),
    );

    return shortenedLink.shortUrl.toString();
  }

  void _handleDeepLink(BuildContext context, PendingDynamicLinkData data) {
    // _notify = Provider.of<Notify>(context,listen: false);
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print('_handleDeepLink | deeplink: $deepLink');

      var isPost = deepLink.pathSegments.contains("post");
      var isReferal = deepLink.pathSegments.contains("refer");
      if (isPost) {
        print(":::::::TRUE::::::PostId: ${deepLink.queryParameters['postId']}");
        var postId = deepLink.queryParameters['postId'];
        if (postId != null && data != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NewPatientDetail(
                        postId: postId,
                      )));
          //Navigate to post
          print("Post ID: $postId => Navigate to post");
        } else {
          print("PostId is null");
        }
      } else if (isReferal) {
        print("Referal Link found:::::::::::::::::::");
        print(deepLink.queryParameters['referalCode']);
        var referalCode = deepLink.queryParameters['referalCode'];
        //Handling in mainDart
      }
    }
  }
}

// Future initDynamicLinks() async{
//   //this called when comes from background
//   FirebaseDynamicLinks.instance.onLink(
//       onSuccess: (PendingDynamicLinkData dynamicLink) async {
//         final Uri deepLink = dynamicLink?.link;
//
//         if (deepLink != null) {
//           // Navigator.pushNamed(context, deepLink.path);
//           print(deepLink.queryParameters.toString());
//         }
//       }, onError: (OnLinkErrorException e) async {
//     print('onLinkError');
//     print(e.message);
//   });
//
//   // this is called when app is not open in background
//   final PendingDynamicLinkData data =
//   await FirebaseDynamicLinks.instance.getInitialLink();
//   final Uri deepLink = data?.link;
//
//   if (deepLink != null) {
//     print(deepLink.queryParameters.toString());
//   }
// }
