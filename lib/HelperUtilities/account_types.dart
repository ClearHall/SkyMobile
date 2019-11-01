import 'package:skyscrapeapi/data_types.dart';

class Account {
  String nick;
  String user;
  String pass;
  SkywardDistrict district;

  Account(this.nick, this.user, this.pass, this.district);

  Account.fromJson(Map<String, dynamic> json)
      : nick = json['nick'],
        user = json['user'],
        pass = json['pass'],
        district = SkywardDistrict.fromJson(json['district']);

  Map<String, dynamic> toJson() =>
      {'nick': nick, 'user': user, 'pass': pass, 'district': district};

  @override
  String toString() {
    return 'Account{nick: $nick, user: $user, pass: $pass, district: $district}';
  }
}
