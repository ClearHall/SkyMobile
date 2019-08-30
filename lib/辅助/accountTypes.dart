import 'package:skymobile/SkywardScraperAPI/SkywardAPITypes.dart';

class Account{
  String nick;
  String user;
  String pass;
  SkywardDistrict district;

  Account(this.nick, this.user, this.pass, this.district);

  Account.fromJson(Map<String, dynamic> json)
  : nick = json['nick'],
  user = json['user'],
  pass = json['pass'],
  district = SkywardDistrict(json['districtName'], json['districtLink']);

  Map<String, dynamic> toJson() =>
      {
        'nick': nick,
        'user': user,
        'pass': pass,
        'districtName': district.districtName,
        'districtLink': district.districtLink,
      };

  @override
  String toString() {
    return 'Account{nick: $nick, user: $user, pass: $pass, district: $district}';
  }
}