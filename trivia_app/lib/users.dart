import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class UserInformation {
  String name;
  String email;
  String userKey;
  String status;

  UserInformation(this.name, this.email, this.userKey);

  UserInformation.fromSnapshot(DataSnapshot snapshot)
      :
        name = snapshot.value["name"],
        email = snapshot.value["email"],
        userKey = snapshot.value["user id"];

  toJson() {
    return {
      "name": name,
      "email": email,
      "user id": userKey
    };
  }

  UserInformation.fromJson(this.userKey, Map data) {
    status = data['status'];
    if (status == null) {
      status = "false";
    }
  }
}

void getUserInfo(String n, String e, String k, UserInformation u) {
  u.name = n;
  u.email = e;
  u.userKey = k;
}

void handleSubmit(DatabaseReference d, String id, UserInformation u) {
  d.child(id).set(u.toJson());
}

class FirebaseTodos {
  static Future<UserInformation> getStatus(String todoKey) async {
    Completer<UserInformation> completer = new Completer<UserInformation>();

    FirebaseDatabase.instance
        .reference()
        .child("permissions")
        .child(todoKey)
        .once()
        .then((DataSnapshot snapshot) {
      var todo = new UserInformation.fromJson(snapshot.key, snapshot.value);
      completer.complete(todo);
    });

    return completer.future;
  }
}