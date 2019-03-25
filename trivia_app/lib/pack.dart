import 'package:firebase_database/firebase_database.dart';

class Pack{
  String name;
  String tags;
  List<dynamic> qs = List();
  String user;
  double rating;
  int rateCount;

  Pack(this.name, this.tags, this.qs, this.user, this.rating, this.rateCount);

  Pack.fromSnapshot(DataSnapshot snapshot):
        name = snapshot.value["name"],
        tags = snapshot.value["tags"],
        qs = snapshot.value["qs"],
        user = snapshot.value["user"],
        rating = snapshot.value["rating"],
        rateCount = snapshot.value["rateCount"];

  toJson() {
    return {
      "name": name,
      "tags": tags,
      "qs": qs,
      "user": user,
      "rating": rating,
      "rateCount": rateCount,
    };
  }
}