import 'package:pet_buddy/model/user_model.dart';

class UserModelWithMessages {
  final UserModel userModel;
  final Map<dynamic, dynamic> messages;

  UserModelWithMessages(this.userModel, this.messages);
}
