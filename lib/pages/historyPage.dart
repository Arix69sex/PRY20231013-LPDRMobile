import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lpdr_mobile/components/messageSnackBar.dart';
import 'package:lpdr_mobile/components/sideBar.dart';
import 'package:lpdr_mobile/components/topbar.dart';
import 'package:lpdr_mobile/models/licensePlateModel.dart';
import 'package:lpdr_mobile/pages/licensePlateInfoPage.dart';
import 'package:lpdr_mobile/services/licensePlateService.dart';
import 'package:lpdr_mobile/util/Jwt.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _searchController = TextEditingController();
  late final LicensePlateService licensePlateService;
  List<LicensePlate> items = [
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
  List<LicensePlate> filteredItems = [];
  var shouldBeX = false;
  @override
  void initState() {
    super.initState();
    licensePlateService = LicensePlateService();
    getUserLicensePlates();
  }

  void openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  void getUserLicensePlates() async {
    var token = await Jwt.getToken();
    var decodedToken = await Jwt.decodeToken(token!);
    final response = await licensePlateService
        .getLicensePlateByUserId(decodedToken!["id"].toString());
    final List<dynamic> decodedResponse =
        json.decode(response!.body)["licensePlate"];

    items = [];
    for (var index = 0; index < decodedResponse.length; index++) {
      var data = decodedResponse[index];
      final Uint8List imageBytes =
          await licensePlateService.getImageOfLicensePlate(data["id"]);
      items.add(LicensePlate(
          id: data["id"],
          code: data["code"],
          longitude: data["longitude"],
          latitude: data["latitude"],
          imageUrl: imageBytes,
          hasInfractions: data["hasInfractions"],
          takenActions: data["takenActions"],
          userId: decodedToken["id"]));
    }

    // Initialize filteredItems with all items
    setState(() {
      filteredItems = List.from(items);
    });
  }

  Future<void> setLicensePlateTakenActions(index) async {
    var item = items[index];

    final response = await licensePlateService.updateLicensePlateById(
        item.id,
        item.code,
        item.longitude,
        item.latitude,
        item.hasInfractions,
        !item.takenActions);

    if (response!.statusCode == 200) {
      MessageSnackBar.showMessage(context, "Taken actions updated.");

      setState(() {
        items[index].takenActions = !item.takenActions;
      });
    } else {
      MessageSnackBar.showMessage(context, "Taken actions update failed.");
    }
  }

  void routeToDetails() async {
    var token = await Jwt.getToken();
    var decodedToken = await Jwt.decodeToken(token!);
    final response = await licensePlateService
        .getLicensePlateByUserId(decodedToken!["id"].toString());
    final List<dynamic> decodedResponse =
        json.decode(response!.body)["licensePlate"];
    // Create a list of items from the service response
    items = decodedResponse.map((data) {
      return LicensePlate(
          id: data["id"],
          code: data["code"],
          longitude: data["longitude"],
          latitude: data["latitude"],
          imageUrl: data["imageData"],
          hasInfractions: data["hasInfractions"],
          takenActions: data["takenActions"],
          userId: data["userId"]);
    }).toList();

    // Initialize filteredItems with all items
    setState(() {
      filteredItems = List.from(items);
    });
  }

  void _filterItems(String query) {
    setState(() {
      filteredItems = items
          .where(
              (item) => item.code.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopBar(
          title: 'Historial',
          onMenuPressed: openDrawer,
        ),
      ),
      drawer: Sidebar(),
      body: Column(
        children: <Widget>[
          // Search Bar
          Container(
            margin: EdgeInsets.only(top: 10.0), // Add margin to create space
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 350,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged:
                        _filterItems, // Trigger filtering when text changes
                    decoration: InputDecoration(
                      labelText: 'Buscar',
                      hintText: 'Buscar items por código...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none, // Remove the border
                        borderRadius: BorderRadius.all(
                            Radius.circular(10.0)), // Add border radius
                      ),
                      filled: true, // Fill the background
                      fillColor: Colors.grey[200], // Set the background color
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 10.0), // Adjust padding
                    ),
                    style: TextStyle(fontSize: 14.0), // Make the text bigger
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 15.0,
            ),
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.blueAccent, // Change the color as needed
              child: Row(
                children: <Widget>[
                  SizedBox(width: 25.0),
                  Text(
                    'Imágen',
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 60.0),
                  Text(
                    'Código',
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 40.0),
                  Text(
                    'Tomó acciones?',
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          // List of Items
          Expanded(
            child: ListView.builder(
              key: listKey,
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                var item = filteredItems[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 15.0,
                  ),
                  child: Container(
                    color: Color.fromRGBO(236, 236, 236, 1),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      leading: ClipRRect(
                        // Use ClipRRect to clip the image to a rounded rectangle
                        borderRadius: BorderRadius.circular(
                            8.0), // Adjust the border radius as needed
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to the new view here
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  // Return the widget for the new view
                                  return LicensePlateInfoPage(id: item.id);
                                },
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.memory(
                              item.imageUrl,
                              width: 100.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      title: Text(item.code),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: !items[index].takenActions
                                ? Icon(Icons.check)
                                : Icon(Icons.close),
                            onPressed: () async {
                              await setLicensePlateTakenActions(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
