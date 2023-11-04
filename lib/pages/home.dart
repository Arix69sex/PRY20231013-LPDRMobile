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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FrameService frameService = FrameService();
  CameraController? _cameraController;
  bool isRecording = false;
  bool takingPicture = false;
  Timer? pictureTimer;
  final int _duration = 2000;
  int recordingProgres = 0;
  bool detectedPlate = false;
  bool notDetectedPlate = false;
  late AnimationController progressBarController;
  bool isOnCameraView = false;
  bool isOnManualInputView = false;
  TextEditingController licensePlateTextController = TextEditingController();

  List<int> detectedLicensePlatesIds = [275];
  void openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  void toggleCameraView() {
    setState(() {
      isOnCameraView = !isOnCameraView;
    });
  }

  void toggleManualInputView() {
    setState(() {
      isOnManualInputView = !isOnManualInputView;
    });
  }

  @override
  void initState() {
    //dispose();
    super.initState();
    _initializeCamera();
    progressBarController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..addListener(() {
        setState(() {
          if (isRecording) {
            if (progressBarController.value >=
                progressBarController.upperBound) {
              _stopRecording();
              notDetectedPlate = true;
            }
          }
        });
      });
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
    progressBarController.forward(from: 0.0);
    setState(() {
      isRecording = true;
    });

    pictureTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (isRecording) {
        print("sending frame to back");
        sendFramesToBackend(context);
      }
    });
  }

  void sendFramesToBackend(BuildContext context) async {
    if (_cameraController!.value.isInitialized) {
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
        for (int i = 0;
            i < decodedResponse["licensePlatesCreated"].length;
            i++) {
          var data = decodedResponse["licensePlatesCreated"][i];
          detectedLicensePlatesIds.add(data["id"]);
          setState(() {
            _stopRecording();
            detectedPlate = true;
          });
          /*InAppNotification.show(
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
        );*/
        }
      }
    }
  }

  Future<void> _stopRecording() async {
    pictureTimer?.cancel();
    //pictureTimer = null;
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
    return cameraView();
    if (!isOnCameraView && !isOnManualInputView) {
      return optionsView();
    } else if (isOnCameraView) {
      return cameraView();
    } else if (isOnManualInputView) {
      return manualInputView();
    }
    return Container();
  }

  Widget optionsView() {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopBar(
          title: 'Cámara',
          onMenuPressed: openDrawer,
        ),
      ),
      drawer: Sidebar(),
      body: Container(
          color: Colors.white,
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 30.0),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Detector de infracciones",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )),
                    Text("Selecciona una opción",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        )),
                  ],
                ),
              ),
              SizedBox(height: 30.0),
              Container(
                height: 56,
                child: OutlinedButton(
                  onPressed: () async {
                    toggleCameraView();
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.camera_alt_outlined),
                            SizedBox(width: 10.0),
                            Text(
                              'Cámara',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right),
                      ]),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4.0),
                          topRight: Radius.circular(4.0),
                        ),
                      ),
                    ),
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(
                        color: const Color.fromRGBO(
                            235, 235, 235, 1), // Border color
                        width: 2.0, // Border width
                      ),
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Colors.black), // Text color
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.white), // Button color
                  ),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                height: 56,
                child: OutlinedButton(
                  onPressed: () async {
                    toggleManualInputView();
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.logout_outlined),
                            SizedBox(width: 10.0),
                            Text(
                              'Ingresar número de placa',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right),
                      ]),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4.0),
                      bottomRight: Radius.circular(4.0),
                    ))),
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(
                        color: const Color.fromRGBO(
                            235, 235, 235, 1), // Border color
                        width: 2.0, // Border width
                      ),
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Colors.black), // Text color
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.white), // Button color
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget manualInputView() {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopBar(
          title: 'Cámara',
          onMenuPressed: openDrawer,
        ),
      ),
      drawer: Sidebar(),
      body: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 30.0),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ingresa el código de ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )),
                    Text("la placa vehicular",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ))
                  ],
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                height: 60,
                child: buildProfileField("Código", licensePlateTextController),
              ),
            ],
          )),
    );
  }

  Widget cameraView() {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: PreferredSize(
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
          if (isRecording) _loadingScreen(context),
          if (!isRecording) _recordButton(),
          if (!isRecording && notDetectedPlate) notDetectedPlateScreen(context),
          if (!isRecording && detectedPlate) detectedPlateScreen(context)
        ],
      ),
    );
  }

  Widget _recordButton() {
    return Align(
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
    );
  }

  Widget _loadingScreen(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.8),
          width: double.infinity,
          height: double.infinity,
        ),
        Align(
            alignment: Alignment.center,
            child: Container(
              child: Column(children: [
                SizedBox(height: MediaQuery.of(context).size.height / 2.5),
                Text("Analizando Placa",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                LinearProgressIndicator(
                  value: progressBarController.value,
                  semanticsLabel: 'Analizando placa',
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                )
              ]),
            ))
      ],
    );
  }

  Widget notDetectedPlateScreen(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              notDetectedPlate = false;
            });
          },
          child: Container(
            color: Color.fromRGBO(20, 132, 65, 1).withOpacity(0.32),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Shadow color
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("No se han detectado infracciones",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                        Text("El número de placa no cuenta con infracciones.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            )),
                      ],
                    ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            notDetectedPlate = false;
                          });
                        },
                        child: Text('Aceptar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(11, 161, 125, 1),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          minimumSize: Size(350, 40),
                        ))
                  ]),
            ))
      ],
    );
  }

  Widget detectedPlateScreen(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              detectedPlate = false;
            });
          },
          child: Container(
            color: Color.fromRGBO(241, 75, 80, 1).withOpacity(0.32),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Shadow color
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Se han detectado infracciones",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                        Text("El número de placa cuenta con infracciones.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            )),
                      ],
                    ),
                    ElevatedButton(
                        onPressed: () {
                          notDetectedPlate = false;
                          _stopRecording();
                          print("detectedLicensePlatesIds.last -> " +
                              detectedLicensePlatesIds.last.toString());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LicensePlateInfoPage(
                                    id: detectedLicensePlatesIds.last)),
                          );
                        },
                        child: Text('Ver infracciones'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(241, 75, 80, 1),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          minimumSize: Size(350, 40),
                        ))
                  ]),
            ))
      ],
    );
  }

  Widget buildProfileField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 56.0,
          width: 350.0,
          child: TextFormField(
            controller: controller,
            enabled: true, // Set the TextField as disabled

            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Color.fromRGBO(
                    14, 26, 48, 1), // Change label text color here
              ),
              hintStyle: TextStyle(
                  color: Color(0x49454F), fontWeight: FontWeight.bold),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                    color: Color.fromRGBO(56, 56, 56, 1), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                // Set the focused border style
                borderRadius: BorderRadius.circular(4.0),
                borderSide: BorderSide(
                    color: Color.fromRGBO(14, 26, 48, 1), width: 1.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationBody extends StatelessWidget {
  final String message;

  const NotificationBody({
    Key? key,
    this.message = "Infracciones Detectadas",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: Container(
          width: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(35, 34, 40, 1),
                borderRadius: BorderRadius.circular(100.0),
                border: Border.all(width: 1.4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
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
