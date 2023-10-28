import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lpdr_mobile/components/topbar.dart';
import 'package:lpdr_mobile/models/infractionModel.dart';
import 'package:lpdr_mobile/models/licensePlateModel.dart';
import 'package:lpdr_mobile/services/infractionService.dart';
import 'package:lpdr_mobile/services/licensePlateService.dart';

final borderColor = Color.fromARGB(255, 235, 235, 235);
final itemWidth = 360.0;
final mainAxisAlignment = MainAxisAlignment.center;
final borderRadius = BorderRadius.all(Radius.circular(0.0));
final styleOfCriteria =
    TextStyle(fontSize: 16, color: Color.fromRGBO(143, 143, 143, 1));

class InfractionsPage extends StatefulWidget {
  final int licensePlateId;

  InfractionsPage({required this.licensePlateId});

  @override
  _InfractionsPageState createState() => _InfractionsPageState();
}

class _InfractionsPageState extends State<InfractionsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final LicensePlateService licensePlateService;
  late final InfractionService infractionService;
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  late LicensePlate licensePlate = LicensePlate(
      id: 0,
      longitude: 0.0,
      latitude: 0.0,
      code: '',
      imageUrl: Uint8List.fromList([65, 66, 67, 68, 69]),
      hasInfractions: false,
      takenActions: false,
      userId: 0);

  List<Infraction> infractions = [];
  var dropdownShowList = [false, false];

  void getInfractions(int licensePlateId) async {
    var response = await licensePlateService
        .getLicensePlateById(licensePlateId.toString());
    final Map<String, dynamic> decodedlicensePlateResponse =
        json.decode(response!.body)["licensePlate"];

    response = await infractionService.getInfractionByLicensePlateId(
        decodedlicensePlateResponse["id"].toString());
    final List<dynamic> decodedInfractionsResponse =
        json.decode(response!.body)?["infraction"];

    var infractionItems = decodedInfractionsResponse.map((data) {
      var responseDateTime = DateTime.parse(data['date']);
      return Infraction(
          id: data["id"],
          infractionCode: data["infractionCode"],
          ballotNumber: data["ballotNumber"],
          name: data["name"],
          level: data["level"],
          fine: data["fine"],
          licensePlateId: data["licensePlate"],
          date: responseDateTime);
    }).toList();

    final Uint8List imageBytes = await licensePlateService
        .getImageOfLicensePlate(decodedlicensePlateResponse["id"]);
    setState(() {
      licensePlate = LicensePlate(
          id: decodedlicensePlateResponse["id"],
          code: decodedlicensePlateResponse["code"],
          longitude: decodedlicensePlateResponse["longitude"],
          latitude: decodedlicensePlateResponse["latitude"],
          imageUrl: imageBytes,
          hasInfractions: decodedlicensePlateResponse["hasInfractions"],
          takenActions: decodedlicensePlateResponse["takenActions"],
          userId: decodedlicensePlateResponse["user"]);
      dropdownShowList =
          List.generate(infractionItems.length, (index) => false);
      infractions = List.from(infractionItems);
    });
  }

  void toggleList(index) {
    setState(() {
      dropdownShowList[index] = !dropdownShowList[index];
    });
  }

  @override
  void initState() {
    super.initState();
    licensePlateService = LicensePlateService();
    infractionService = InfractionService();
    getInfractions(widget.licensePlateId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopBar(
          title: 'Cámara',
          onMenuPressed: () => {},
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/banner.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  licensePlate.code ?? "",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(49, 49, 49, 1)),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 15),
                Text(
                  'Infracciones',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(143, 143, 143, 1)),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 5),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 3,
                  child: ListView.builder(
                      key: listKey,
                      itemCount: infractions.length,
                      itemBuilder: (BuildContext context, int index) {
                        var infraction = infractions[index];
                        return Column(children: [
                          GestureDetector(
                              onTap: () => {toggleList(index)},
                              child: Row(
                                  mainAxisAlignment: mainAxisAlignment,
                                  children: [
                                    Container(
                                        width: itemWidth,
                                        decoration: BoxDecoration(
                                            border:
                                                Border.all(color: borderColor),
                                            borderRadius:
                                                borderRadius // Add border here
                                            ),
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.article_outlined,
                                            size: 35,
                                            color: Color.fromRGBO(
                                                152, 175, 185, 1),
                                          ),
                                          title: Text(
                                            infraction.infractionCode ?? "",
                                          ),
                                          trailing: !dropdownShowList[index]
                                              ? Icon(Icons.expand_more)
                                              : Icon(Icons.expand_less),
                                        ))
                                  ])),
                          if (dropdownShowList[index])
                            _buildCriteriaItem("Nombre: ", infraction.name),
                          if (dropdownShowList[index])
                            _buildCriteriaItem("Calificación: ", infraction.level),
                          if (dropdownShowList[index])
                            _buildCriteriaItem("Boleta: ", infraction.ballotNumber),
                          if (dropdownShowList[index])
                            _buildCriteriaItem(
                                "Multa: ", infraction.fine.toString()),
                          if (dropdownShowList[index])
                            _buildCriteriaItem(
                                "Fecha: ", infraction.date.toString()),
                          SizedBox(height: 15)
                        ]);
                      }),
                ),
              ],
            ),
            /*Positioned(
              top: 25.0, // Adjust the top position as needed
              left: 25.0, // Adjust the right position as needed
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaItem(String? criteria, String? value) {
    return Row(mainAxisAlignment: mainAxisAlignment, children: [
      Container(
          width: itemWidth,
          decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: borderRadius // Add border here
              ),
          child: ListTile(
            leading: Text(
              criteria ?? "",
              style: styleOfCriteria,
            ),
            title: Text(value ?? "", style: styleOfCriteria),
          ))
    ]);
  }
}
