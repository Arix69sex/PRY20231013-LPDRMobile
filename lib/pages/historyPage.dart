import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lpdr_mobile/components/messageSnackBar.dart';
import 'package:lpdr_mobile/components/sideBar.dart';
import 'package:lpdr_mobile/components/topbar.dart';
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
  List<Item> items = [
    Item(
        id: 0,
        longitude: 0.0,
        latitude: 0.0,
        code: 'XYZ456',
        imageUrl:
            'https://media.wired.com/photos/5e2b52d1097df7000896da19/16:9/w_2399,h_1349,c_limit/Transpo-licenseplates-502111737.jpg',
        hasInfractions: false,
        takenActions: false)
    // Add more items here
  ];
  List<Item> filteredItems = [];

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

    // Create a list of items from the service response
    items = decodedResponse.map((data) {
      return Item(
        id: data["id"],
        code: data["code"],
        longitude: data["longitude"],
        latitude: data["latitude"],
        imageUrl: data["imageData"],
        hasInfractions: data["hasInfractions"],
        takenActions: data["takenActions"],
      );
    }).toList();

    // Initialize filteredItems with all items
    setState(() {
      filteredItems = List.from(items);
    });
  }

  Future<void> setLicensePlateTakenActions(item) async {
    final response = await licensePlateService.updateLicensePlateById(
        item.id,
        item.code,
        item.longitude,
        item.latitude,
        item.hasInfractions,
        !item.takenActions);

    if (response!.statusCode == 200) {
      MessageSnackBar.showMessage(context, "Taken actions updated.");
      final index = items.indexOf(item);
      if (index != -1) {
        final newItem = Item(
          id: item.id,
          longitude: item.longitude,
          latitude: item.latitude,
          code: item.code,
          imageUrl: item.imageUrl,
          hasInfractions: item.hasInfractions,
          takenActions: !item.takenActions,
        );

        setState(() {
          items[index] = newItem;
        });
      }
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
      return Item(
        id: data["id"],
        code: data["code"],
        longitude: data["longitude"],
        latitude: data["latitude"],
        imageUrl: data["imageData"],
        hasInfractions: data["hasInfractions"],
        takenActions: data["takenActions"],
      );
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
          title: 'History',
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
                      labelText: 'Search',
                      hintText: 'Search items by code...',
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
                            child: Image.network(
                              item.imageUrl,
                              width: 100.0,
                              height: 60.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      title: Text(item.code),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          !filteredItems[index].takenActions
                              ? IconButton(
                                  icon: Icon(Icons.check),
                                  onPressed: () async {
                                    await setLicensePlateTakenActions(item);
                                  },
                                )
                              : IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () async {
                                    await setLicensePlateTakenActions(item);
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

class Item {
  final int id;
  final String code;
  final double longitude;
  final double latitude;
  final String imageUrl;
  final bool hasInfractions;
  final bool takenActions;

  Item(
      {required this.id,
      required this.code,
      required this.longitude,
      required this.latitude,
      required this.imageUrl,
      required this.hasInfractions,
      required this.takenActions});
}
