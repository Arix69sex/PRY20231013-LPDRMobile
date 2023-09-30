import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lpdr_mobile/components/sideBar.dart';
import 'package:lpdr_mobile/components/topbar.dart';
import 'package:lpdr_mobile/models/licensePlateModel.dart';
import 'package:lpdr_mobile/pages/licensePlateInfoPage.dart';
import 'package:lpdr_mobile/services/frameService.dart';
import 'package:lpdr_mobile/util/Jwt.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FrameService frameService = FrameService();
  CameraController? _cameraController;
  bool isRecording = false;
  bool takingPicture = false;
  Timer? pictureTimer;
  final int _duration = 2000;

  List<LicensePlate> detectedLicensePlates = [
    LicensePlate(
        id: 0,
        longitude: 0.0,
        latitude: 0.0,
        code: 'XYZ456',
        imageUrl: Uint8List.fromList([65, 66, 67, 68, 69]),
        hasInfractions: false,
        takenActions: false,
        userId: 0)
    // Add more items here
  ];
  void openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras[0];

    _cameraController = CameraController(firstCamera, ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.yuv420);

    try {
      await _cameraController?.initialize();
      if (!mounted) return;
      setState(() {});
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    pictureTimer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording(BuildContext context) async {
    if (!_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      isRecording = true;
    });

    pictureTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isRecording) {
        sendFramesToBackend(context);
      }
    });
  }

  void sendFramesToBackend(BuildContext context) async {
    final XFile videoFrame = await _cameraController!.takePicture();
    final bytes = await videoFrame.readAsBytes();
    var token = await Jwt.getToken();
    var decodedToken = await Jwt.decodeToken(token!);
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    double latitude = position.latitude;
    double longitude = position.longitude;
    final response = await frameService.sendFrames(
        decodedToken!["id"].toString(), bytes, latitude, longitude);
    final Map<String, dynamic> decodedResponse = json.decode(response!.body);

    if (response.statusCode == 201) {
      for (int i = 0; i < decodedResponse["licensePlatesCreated"].length; i++) {
        var data = decodedResponse["licensePlatesCreated"][i];
        final code = data['code'];
        InAppNotification.show(
          child: NotificationBody(message: "$code has infractions!"),
          context: context,
          onTap: () => {
            _stopRecording(),
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LicensePlateInfoPage(id: data["id"])),
            )
          },
          duration: Duration(milliseconds: _duration),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    pictureTimer?.cancel();
    pictureTimer = null;
    setState(() {
      isRecording = false;
    });
  }

  void _toggleRecording(BuildContext context) {
    if (isRecording) {
      _stopRecording();
    } else {
      _startRecording(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopBar(
          title: 'Cámara',
          onMenuPressed: openDrawer,
        ),
      ),
      drawer: Sidebar(),
      body: Stack(
        children: <Widget>[
          Center(
            child: _cameraController != null &&
                    _cameraController!.value.isInitialized
                ? CameraPreview(_cameraController!)
                : CircularProgressIndicator(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: () {
                  _toggleRecording(context);
                },
                shape: isRecording
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )
                    : CircleBorder(),
                backgroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationBody extends StatelessWidget {
  final String message;

  const NotificationBody({
    Key? key,
    this.message = "test",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minHeight = math.min(
      16,
      MediaQuery.of(context).size.height,
    );
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 12,
                blurRadius: 16,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.lightBlue, // Changed to light blue
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  width: 1.4,
                  color: Colors.white.withOpacity(0.2), // Changed border color
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white, // Changed font color to white
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
