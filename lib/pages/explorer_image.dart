
import 'package:dearim/views/image.dart';
import 'package:flutter/material.dart';

///
/// 图片游览
///
class ExplorerImagePage extends StatelessWidget{
  final String imageUrl;
  final String? heroId;

  const ExplorerImagePage(this.imageUrl , {Key? key , this.heroId}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "游览图片",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: ScanImageWidget(
          imageUrl,
          heroId: heroId,
        ),
      ),
    );
  }
}
