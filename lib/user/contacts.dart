
import 'package:dearim/models/contact_model.dart';
import 'package:flutter/cupertino.dart';

///
///联系人数据 全局缓存
///
class ContactsDataCache with ChangeNotifier{
  static final ContactsDataCache _instance = ContactsDataCache();

  static ContactsDataCache get instance => _instance;

  Map<int , ContactModel> contacts = <int , ContactModel>{};

  //增加或更新联系人
  void addOrUpdateContact(ContactModel contact){
    contacts[contact.userId] = contact;
    notifyListeners();
  }

  //移除联系人
  void removeContact(int userId){
    if(contacts.containsKey(userId)){
      contacts.remove(userId);
      notifyListeners();
    }
  }

  //获取联系人
  ContactModel? getContact(int userId){
    return contacts[userId];
  }

  //重置联系人数据
  void resetContacts(List<ContactModel> list){
    contacts.clear();
    for(ContactModel contact in list){
      contacts[contact.userId] = contact;
    }//end for each
    notifyListeners();
  }

  List<ContactModel> get allContacts {
    List<ContactModel> list = <ContactModel>[];
    for(var key in contacts.keys){
      list.add(contacts[key]!);
    }
    return list;
  }

}//end class