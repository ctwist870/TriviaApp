import 'package:firebase_database/firebase_database.dart';

class Pack{
  String name;
  String tags;
  List<dynamic> qs = List();
  String user;

  Pack(this.name, this.tags, this.qs, this.user);

  Pack.fromSnapshot(DataSnapshot snapshot):
        name = snapshot.value["name"],
        tags = snapshot.value["tags"],
        qs = snapshot.value["qs"],
        user = snapshot.value["user"];

  toJson() {
    return {
      "name": name,
      "tags": tags,
      "qs": qs,
      "user": user,
    };
  }
}