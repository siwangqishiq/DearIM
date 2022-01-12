import 'package:dearim/core/log.dart';
import 'package:dearim/utils/text_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///
/// 用户头像 
///

class HeadView extends StatelessWidget{
  final String? originUrl;

  final double width;
  final double height;
  final ImageSize size;
  final double circle;

  static String urlFromSize(String? url ,ImageSize size){
    if(url == null || url == ""){
      return "";
    }
    
    switch(size){
      case ImageSize.middle:
        return "$url!imgmiddle";
      case ImageSize.small:
        return "$url!imgsmall";
      default:
        return url;
    }//end switch
  }
   
  const HeadView(this.originUrl , {Key? key ,
          this.size = ImageSize.middle ,  
          this.circle = 16,
          this.width = 64 , 
          this.height = 64}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if(TextUtils.isEmpty(originUrl)){
      return _errorOrEmptyViewHolder(width);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(circle),
      child: FadeInImage.assetNetwork(
        height: height,
        width: width,
        fit: BoxFit.cover, 
        image: urlFromSize(originUrl , size), 
        imageErrorBuilder: (context, error, st) {
          LogUtil.log("图片加载 发生错误 $error");
          return _errorOrEmptyViewHolder(width);
        },
        placeholder: 'avatar_loading.png', 
      ),  
    );
  }

  Widget _errorOrEmptyViewHolder(double size){
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset("avatar_loading.png"),
    );
  }

}

enum ImageSize{
  origin,//原图
  middle,//中等
  small,//小图
}