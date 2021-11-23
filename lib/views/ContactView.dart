// ignore_for_file: file_names

import 'dart:developer';

import 'package:dearim/models/ContactModel.dart';
import 'package:dearim/views/RedPoint.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ContactView extends StatefulWidget {
  ContactModel model;
  VoidCallback onPress;
  ContactView(this.model, this.onPress, {Key? key}) : super(key: key);

  @override
  _ContactViewState createState() =>
      _ContactViewState(this.model, this.onPress);
}

class _ContactViewState extends State<ContactView> {
  ContactModel model;
  VoidCallback onPress;
  double imageWidth = 50;
  double leftSpace = 16;
  double rightSpace = 16;
  double space = 15;

  _ContactViewState(this.model, this.onPress);

  @override
  Widget build(BuildContext context) {
    String imageURL =
        "https://seopic.699pic.com/photo/50046/5562.jpg_wh1200.jpg";
    if (this.model.avatar.length > 0) {
      imageURL = this.model.avatar;
    }
    return FlatButton(
      onPressed: this.onPress,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            SizedBox(
              height: space,
            ),
            Row(
              children: [
                RedPoint(
                  width: imageWidth + 10,
                  height: imageWidth + 10,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageURL,
                        width: imageWidth,
                        height: imageWidth,
                        fit: BoxFit.cover,
                      )),
                  number: 12,
                  pointStyle: RedPointStyle.number,
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Text(
                      this.model.name,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(this.model.message),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
