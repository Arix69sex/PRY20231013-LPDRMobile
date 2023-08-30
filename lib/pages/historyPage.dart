import 'package:flutter/material.dart';
import 'package:lpdr_mobile/components/sideBar.dart';
import 'package:lpdr_mobile/components/topbar.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  List<Item> items = [
    Item(
      code: 'ABC123',
      base64Image: 'base64_image_data_here',
    ),
    Item(
      code: 'XYZ456',
      base64Image: 'base64_image_data_here',
    ),
    // Add more items here
  ];
  List<Item> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = items; // Initialize with all items
  }

  void openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
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
              itemCount: filteredItems.length,
              // Inside the ListView.builder
itemBuilder: (context, index) {
  final item = filteredItems[index];

  return Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 15.0, // Add horizontal padding
    ),
    child: Container(
      color: Color.fromRGBO(236, 236, 236, 1), // Set the background color to light grey
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0), // Set the border radius
        ),
        leading: Text("Test Image"),
        title: Text(item.code),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                // Handle the check action
              },
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // Handle the X action
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
  final String code;
  final String base64Image;

  Item({required this.code, required this.base64Image});
}
