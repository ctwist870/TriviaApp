import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'pack.dart';
import 'dart:core';
import 'dart:math';
import 'pack_select.dart';

class RandomPack extends StatefulWidget {
  @override
  RandomForm createState() => new RandomForm();
}

class RandomForm extends State<RandomPack> {
  List<Pack> _packs = List();
  List<Pack> matchPacks = List();
  List<Map> qList = List();
  Pack randPack;
  DatabaseReference _dbRef;
  int searched = 0;
  String searchTags;

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

  void randSearch(){
    Random rng = new Random();
    Pack curPack;
    for(Pack P in _packs){
      if(tagCheck.hasMatch(P.tags)) {
        matchPacks.add(P);
      }
    }
    for(int i=0; i<10; i++){
      curPack = matchPacks[rng.nextInt(matchPacks.length)];
      qList.add(curPack.qs[rng.nextInt(curPack.qs.length)]);
    }

    randPack = new Pack("Your Random Pack", searchTags, qList, "irrelevant", 0.0, 0);
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
                  randSearch();
                  Navigator.push(context, new MaterialPageRoute(builder: (context) => new Trivia(chosenPack : randPack, chosenKey: "random")));
                });
              },
              color: Colors.yellow
          ),
        ],
      ),
    );
  }
}