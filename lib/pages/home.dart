import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lpdr_mobile/components/sideBar.dart';
import 'package:lpdr_mobile/components/topbar.dart';
import 'package:lpdr_mobile/services/frameService.dart';

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

  Future<void> _startRecording() async {
    if (!_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      isRecording = true;
    });

    pictureTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isRecording) {
        sendFramesToBackend();
      }
    });
  }

  void sendFramesToBackend() async {
    final XFile videoFrame = await _cameraController!.takePicture();
    final bytes = await videoFrame.readAsBytes();
    await frameService.sendFrames(bytes);
  }

  Future<void> _stopRecording() async {
    pictureTimer?.cancel();
    pictureTimer = null;
    setState(() {
      isRecording = false;
    });
  }

  void _toggleRecording() {
    if (isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopBar(
          title: 'Home',
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
                onPressed: _toggleRecording,
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
