import 'package:intl/intl.dart';
final formatter = DateFormat.yMd();

class UserProfile {
  UserProfile(this.username, this.email, this.dob, this.avatarPath, this.userId);

  String username;
  String email;
  DateTime dob;
  String? avatarPath;
  String userId;

  String get formattedDate{
  return formatter.format(dob);
}
}
