import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'pack.dart';
import 'dart:core';
import 'pack_select.dart';

class Search extends StatefulWidget {
  @override
  SearchForm createState() => new SearchForm();
}

class SearchForm extends State<Search> {
  List<Pack> _packs = List();
  List<Pack> matchPacks = List();
  List<String> keys = List();
  DatabaseReference _dbRef;
  int searched = 0;
  String searchTags;
  double rating;

  RegExp tagCheck;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    _dbRef = database.reference().child('Packs');
    _dbRef.onChildAdded.listen(_onEntryAdded);
  }

  _onEntryAdded(Event event) {
    setState(() {
      _packs.add(Pack.fromSnapshot(event.snapshot));
      keys.add(event.snapshot.key);
    });
  }

  createRegex(String tags){
    String regex = "";
    var wordList = tags.split(" ");
    for(String s in wordList){
      regex += '(?=.*\\b$s\\b)';
    }

    tagCheck = RegExp('$regex', caseSensitive: false);
  }

  void handleSubmit(){
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    if(searched == 0){
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Search for packs"),
          backgroundColor: Colors.yellowAccent,
        ),
        body: Column(
          children: <Widget>[
            Text("Search for packs by tags",
              style: TextStyle(fontSize: 15),
            ),
            Flexible(
              flex: 0,
              child: Center(
                child: Form(
                  key: formKey,
                  child: Center(
                    child: ListTile(
                      title: TextFormField(
                        initialValue: "",
                        onSaved: (val) => searchTags = val,
                        validator: (val) => val == "" ? val : null,
                        decoration: InputDecoration(
                            labelText: 'Enter tag(s)'
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            RaisedButton(
                child: const Text('Initiate Search'),
                textColor: Colors.white,
                onPressed: () {
                  setState(() {
                    handleSubmit();
                    createRegex(searchTags);
                    searched = 1;
                  });
                },
                color: Colors.yellow
            ),
          ],
        ),
      );
    }
    else {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Play a pack"),
          backgroundColor: Colors.yellowAccent,
        ),
        body: Column(
          children: <Widget>[
            Flexible(
              flex: 0,
              child: Center(
                child: Center(
                  heightFactor: 5.0,
                  widthFactor: 1.0,
                  child: Text("Tap a pack to get started!",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
            Flexible(
              child: new FirebaseAnimatedList(
                query: _dbRef,
                itemBuilder: (BuildContext context, DataSnapshot snapshot,
                    Animation<double> animation, int index) {
                  if(tagCheck.hasMatch(_packs[index].tags)) {
                    if(_packs[index].rateCount == 0){
                      rating = 0.0;
                    }
                    else{
                      rating = _packs[index].rating/_packs[index].rateCount;
                    }
                    return new ListTile(
                      enabled: true,
                      leading: Icon(Icons.create),
                      title: Text(_packs[index].name),
                      subtitle: Text(_packs[index].tags),
                      trailing: SmoothStarRating(
                        allowHalfRating: true,
                        rating: rating,
                        starCount: 5,
                        size: 20.0,
                        color: Colors.yellow,
                        borderColor: Colors.black,
                      ),
                      onTap: () {
                        setState(() {
                          Navigator.push(context, new MaterialPageRoute(builder: (context) => new Trivia(chosenPack: _packs[index], chosenKey: keys[index])));
                        });
                      },
                    );
                  }
                  else{
                    return new Container();
                  }
                },
              ),
            ),
          ],
        ),
      );
    }
  }

}