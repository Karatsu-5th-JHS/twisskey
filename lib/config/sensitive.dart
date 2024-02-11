import 'package:shared_preferences/shared_preferences.dart';

class config_timeline_sensitive{
  Future<bool> get() {
    return SharedPreferences.getInstance().then((instance) {
      bool? flag = instance.getBool("config_timeline_sensitive");
      if(flag == null){
        return false;
      }else{
        return flag;
      }
    });
  }
  void save(bool flag) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    instance.setBool("config_timeline_sensitive", flag);
  }
}