import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lpdr_mobile/components/sideBar.dart';
import 'package:lpdr_mobile/components/topbar.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image/image.dart' as img;
import 'package:lpdr_mobile/pages/previewScreenTest.dart';
import 'package:lpdr_mobile/util/HttpRequest.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CameraController? _cameraController;
  bool isRecording = false;
  bool takingPicture = false;
  Timer? pictureTimer;
  late CameraImage _cameraImage;
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
    pictureTimer?.cancel(); // Cancel the timer when disposing
    super.dispose();
  }

  Future<void> _startRecording() async {
    /*if (isRecording) return;

    /*pictureTimer = Timer.periodic(Duration(milliseconds: 333), (_) {
      // Capture and send an image every 1/3 of a second
      _captureAndSendImage();
    });*/
    print(takingPicture);

      if (!takingPicture) {
       await _cameraController!.stopImageStream();
      takingPicture = true;
      final XFile videoFrame = await _cameraController!.takePicture();
      print(videoFrame.path);
      Navigator.push(
        this.context,
        MaterialPageRoute(
            builder: (context) => PreviewScreen(
                  imgPath: videoFrame.path,
                )),
      );
      final bytes = await videoFrame.readAsBytes();
      print(bytes);
      takingPicture = false;
    } else {
      takingPicture = false;
    }
    
    

    /*_cameraController!.startImageStream((image) => {
          if (isRecording)
            {
              print(image)
              //_cameraImage = image
            }
        });
*/
    setState(() {
      isRecording = true;
    });

    */

    if (!_cameraController!.value.isInitialized) {
      return;
    }
    //await _cameraController!.stopVideoRecording();
    //await _cameraController!.startVideoRecording();

    setState(() {
      isRecording = true;
    });

    // Start sending frames to the backend while recording

    final XFile videoFrame = await _cameraController!.takePicture();
    final bytes = await videoFrame.readAsBytes();
    print("bytes");
    print(bytes);
    var baseurl = dotenv.env["API_URL"];
    print(baseurl);
    var httpRequest = new HttpRequest();

    var body = {"bytes": bytes};
    final response =
        await httpRequest.post('${baseurl}licensePlates/test/create', jsonEncode(body));

    // Send the bytes to your backend using HTTP POST or your preferred method
    //await _sendFrameToBackend(bytes);
  }

  void capture() {
    ByteBuffer byteBuffer =
        Uint8List.fromList(_cameraImage.planes[0].bytes).buffer;
    img.Image image = img.Image.fromBytes(
        width: _cameraImage.width,
        height: _cameraImage.height,
        bytes: byteBuffer);
    Uint8List jpeg = Uint8List.fromList(img.encodeJpg(image));
    print(jpeg.length);
    print("Image captured");
  }

  Future<void> _stopRecording() async {
    if (!isRecording) return;

    pictureTimer?.cancel(); // Cancel the picture-taking timer
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
