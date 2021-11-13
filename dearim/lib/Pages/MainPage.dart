// ignore_for_file: file_names

import 'package:dearim/Pages/ContactModel.dart';
import 'package:dearim/Views/ContactView.dart';
import 'package:flutter/material.dart';


class MainPage extends StatefulWidget {
  const MainPage({ Key? key }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("展信佳",style: TextStyle(
          color: Colors.white),),
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (BuildContext context, int index) {
          return ContactView(ContactModel());
        },
      ),
    );
  }
}