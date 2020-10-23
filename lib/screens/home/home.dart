import 'dart:async';
import 'dart:io';
import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/custom_button.dart';
import 'package:atsign_atmosphere_app/services/backend_service.dart';
import 'package:atsign_atmosphere_app/services/navigation_service.dart';
import 'package:atsign_atmosphere_app/services/notification_service.dart';
import 'package:atsign_atmosphere_app/services/size_config.dart';
import 'package:atsign_atmosphere_app/utils/colors.dart';
import 'package:atsign_atmosphere_app/utils/images.dart';
import 'package:atsign_atmosphere_app/utils/text_strings.dart';
import 'package:atsign_atmosphere_app/view_models/file_picker_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' show basename;
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  NotificationService _notificationService;
  bool onboardSuccess = false;
  bool sharingStatus = false;
  BackendService backendService;
  // bool userAcceptance;
  final Permission _cameraPermission = Permission.camera;
  final Permission _storagePermission = Permission.storage;
  Completer c = Completer();
  bool authenticating = false;
  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;
  FilePickerProvider filePickerProvider;

  @override
  void initState() {
    super.initState();
    filePickerProvider = FilePickerProvider();
    _notificationService = NotificationService();
    _initBackendService();
    _checkToOnboard();
    acceptFiles();
    _checkForPermissionStatus();
  }

  void acceptFiles() async {
    _intentDataStreamSubscription = await ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      _sharedFiles = value;

      if (value.isNotEmpty) {
        value.forEach((element) async {
          File file = File(element.path);
          double length = await file.length() / 1024;
          filePickerProvider.selectedFiles.add(PlatformFile(
              name: basename(file.path),
              path: file.path,
              size: length.round(),
              bytes: await file.readAsBytes()));
          await filePickerProvider.calculateSize();
        });

        BuildContext c = NavService.navKey.currentContext;

        print("Shared:wawawawawawa" +
            (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
        Navigator.pushReplacementNamed(c, Routes.WELCOME_SCREEN);
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    await ReceiveSharingIntent.getInitialMedia()
        .then((List<SharedMediaFile> value) {
      _sharedFiles = value;
      if (_sharedFiles != null && _sharedFiles.isNotEmpty) {
        _sharedFiles.forEach((element) async {
          var test = File(element.path);
          var length = await test.length() / 1024;
          filePickerProvider.selectedFiles.add(PlatformFile(
              name: basename(test.path),
              path: test.path,
              size: length.round(),
              bytes: await test.readAsBytes()));
          await filePickerProvider.calculateSize();
        });
        print("Shared:" + (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
        BuildContext c = NavService.navKey.currentContext;
        Navigator.pushReplacementNamed(c, Routes.WELCOME_SCREEN);
      }
    });
  }

  String state;
  void _initBackendService() {
    backendService = BackendService.getInstance();
    _notificationService.setOnNotificationClick(onNotificationClick);
    SystemChannels.lifecycle.setMessageHandler((msg) {
      state = msg;
      debugPrint('SystemChannels> $msg');
      backendService.app_lifecycle_state = msg;
    });
  }

  void _checkToOnboard() async {
    // onboard call to get the already setup atsigns
    await backendService.onboard().then((isChecked) async {
      if (!isChecked) {
        c.complete(true);
        print("onboard returned: $isChecked");
      } else {
        await backendService.startMonitor();
        onboardSuccess = true;
        c.complete(true);
      }
    }).catchError((error) async {
      c.complete(true);
      print("Error in authenticating: $error");
    });
  }

  void _checkForPermissionStatus() async {
    final existingCameraStatus = await _cameraPermission.status;
    if (existingCameraStatus != PermissionStatus.granted) {
      await _cameraPermission.request();
    }
    final existingStorageStatus = await _storagePermission.status;
    if (existingStorageStatus != PermissionStatus.granted) {
      await _storagePermission.request();
    }
  }

  onNotificationClick(String payload) async {
    // this popup added to accept stream to await answer
    // BuildContext c = NavService.navKey.currentContext;
    // print('Payload $payload');
    // bool userAcceptance = null;
    // await showDialog(
    //   context: c,
    //   builder: (c) => ReceiveFilesAlert(
    //     payload: payload,
    //     sharingStatus: (s) {
    //       // sharingStatus = s;
    //       userAcceptance = s;
    //       print('STATUS====>$s');
    //     },
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: SizeConfig().screenWidth,
            height: SizeConfig().screenHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  ImageConstants.welcomeBackground,
                ),
                fit: BoxFit.fill,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 10.toWidth,
                          top: 10.toHeight,
                        ),
                        child: Image.asset(
                          ImageConstants.logoIcon,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 36.toWidth,
                        vertical: 10.toHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Text(
                              TextStrings().homeFileTransferItsSafe,
                              style: GoogleFonts.playfairDisplay(
                                textStyle: TextStyle(
                                  fontSize: 38.toFont,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text.rich(
                              TextSpan(
                                text: TextStrings().homeHassleFree,
                                style: TextStyle(
                                  fontSize: 15.toFont,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: TextStrings().homeWeWillSetupAccount,
                                    style: TextStyle(
                                      color: ColorConstants.fadedText,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: CustomButton(
                                buttonText: TextStrings().buttonStart,
                                onPressed: () async {
                                  this.setState(() {
                                    authenticating = true;
                                  });
                                  await c.future;
                                  // if (onboardSuccess) {
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      Routes.WELCOME_SCREEN, (route) => false);
                                  // } else {
                                  //   Navigator.pushNamedAndRemoveUntil(
                                  //       context,
                                  //       Routes.SCAN_QR_SCREEN,
                                  //       (route) => false);
                                  // }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          authenticating
              ? Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ColorConstants.redText)),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
