
import 'package:dearim/views/image.dart';
import 'package:flutter/material.dart';

class PreviewSendImage extends StatelessWidget{
  final String imagePath;

  const PreviewSendImage(
    this.imagePath ,
    {Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "发送图片",
          style: TextStyle(color: Colors.white),
        ),
        actions:[
          InkWell(
            onTap: (){
              Navigator.of(context).pop(imagePath);
            },
            child:const Padding(
              padding: EdgeInsets.all(8),
              child: Center(
                child: Text("发送"),
              )
            ),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,  
        color: Colors.black,
        child: ScanImageWidget(
          imagePath,
          type: ScanImageWidget.TYPE_FILE,
        ),
      ),
    );
  }
}


///
/// 图片游览
///
class ExplorerImagePage extends StatelessWidget{
  final String imageUrl;
  final String? heroId;
  final int? type;

  const ExplorerImagePage(
    this.imageUrl , 
    {Key? key , 
    this.heroId , this.type}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "查看图片",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,  
        color: Colors.black,
        child: ScanImageWidget(
          imageUrl,
          heroId: heroId??imageUrl,
          type: type??ScanImageWidget.TYPE_HTTP,
        ),
      ),
    );
  }
}
