// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';

///
/// 图片游览
/// 
class ScanImageWidget extends StatelessWidget{
  static const int TYPE_HTTP = 1;//网络图片
  static const int TYPE_FILE = 2;//本地文件

  final String mImageUrl;
  final int type;
  
  const ScanImageWidget(this.mImageUrl , {Key? key, this.type = TYPE_HTTP}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      child: Center(
        child:Hero(
          tag: mImageUrl, 
          child: InteractiveViewer(
            child: type == TYPE_FILE ?Image.file(File(mImageUrl) , width: double.infinity) :Image.network(mImageUrl , width: double.infinity),
            panEnabled: true, 
            boundaryMargin:const EdgeInsets.all(8),
            minScale: 0.5,
            maxScale: 4.5,
            clipBehavior: Clip.none
          )
        )
      )
    );
  }
}//end class