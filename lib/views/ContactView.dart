// ignore_for_file: file_names

import 'package:dearim/models/ContactModel.dart';
import 'package:dearim/Pages/RedPoint.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ContactView extends StatefulWidget {
  ContactModel model;
  ContactView(this.model, {Key? key}) : super(key: key);

  @override
  _ContactViewState createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  double imageWidth = 50;
  double leftSpace = 16;
  double rightSpace = 16;
  double space = 15;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(
            height: space,
          ),
          Row(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              SizedBox(
                width: leftSpace,
              ),
              RedPoint(
                width: imageWidth + 10,
                height: imageWidth + 10,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://seopic.699pic.com/photo/50046/5562.jpg_wh1200.jpg',
                      width: imageWidth,
                      height: imageWidth,
                      fit: BoxFit.fill,
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
                  const Text(
                    "一个标题",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text("最新的消息"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
