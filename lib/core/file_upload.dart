import 'package:dio/dio.dart';

///
/// 云存储 服务
///

//上传文件类型
enum UploadFileType{
  image,//图片
  video,//视频
  audio,//音频
  file,//普通文件
}

//文件上传结果回调
typedef UploadCallback = Function(int result , String? url , String? attach);

//文件上传基类 为不同的云存储服务统一方法
abstract class FileUploadManager{

  //文件上传 
  void uploadFile(String localPath , UploadFileType fileType , UploadCallback? callback);
}//end class 


//文件上传 默认实现
class DefaultFileUploadManager extends FileUploadManager{
  late Dio _dio;

  DefaultFileUploadManager(){
    _dio = Dio();
  }

  @override
  void uploadFile(String localPath, UploadFileType fileType, UploadCallback? callback) {
    _dio.post("" , );
  }
}