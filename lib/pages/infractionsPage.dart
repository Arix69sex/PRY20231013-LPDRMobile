import 'package:flutter/material.dart';
import 'package:lpdr_mobile/components/sideBar.dart';
import 'package:lpdr_mobile/components/topbar.dart';

class InfractionsPage extends StatefulWidget {
  final int licensePlateId;

  InfractionsPage({required this.licensePlateId});

  @override
  _InfractionsPageState createState() => _InfractionsPageState();
}

class _InfractionsPageState extends State<InfractionsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    _scaffoldKey.currentState!.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: TopBar(
          title: 'Infractions',
          onMenuPressed: openDrawer,
        ),
      ),
      drawer: Sidebar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text(
                'This is the home page',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
