import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/services.dart';
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
  int qCount;

  RegExp tagCheck;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    _dbRef = database.reference().child('Packs');
    _dbRef.onChildAdded.listen(_onEntryAdded);
    qCount = 10;
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
    int rand;
    List<dynamic> qMatch = List();
    for(Pack P in _packs){
      if(tagCheck.hasMatch(P.tags)) {
        for(int i=0; i<P.qs.length; i++){
          if(P.qs[i]["flagCount"] < 5){
            qMatch.add(P.qs[i]);
          }
        }
      }
    }

    if(qMatch.length < qCount){
      qCount  = qMatch.length;
    }

    for(int i=0; i<qCount; i++){
      rand = rng.nextInt(qMatch.length);
      qList.add(qMatch[rand]);
      qMatch.removeAt(rand);
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
      ),
      body: Center(
          child: Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("images/ambient3.gif"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: <Widget>[
                Text("Search for packs by tags",
                  style: TextStyle(fontSize: 20, color: Colors.white70),
                ),
                Flexible(
                  flex: 0,
                  child: Center(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment(0.0, 0.0),
                            color: Theme.of(context).accentColor,
                            child: ListTile(
                              title: TextFormField(
                                initialValue: "",
                                onSaved: (val) => searchTags = val,
                                validator: (val) => val == "" ? val : null,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Theme.of(context).accentColor,
                                    labelStyle: TextStyle(color: Colors.black),
                                    labelText: 'Enter tag(s)'
                                ),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment(0.0, 0.0),
                            color: Theme.of(context).accentColor,
                            child: ListTile(
                              title: TextFormField(
                                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                initialValue: "",
                                onSaved: (val) => qCount = int.parse(val),
                                validator: (val) => val == "" ? val : null,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Theme.of(context).accentColor,
                                    labelStyle: TextStyle(color: Colors.black),
                                    labelText: 'Enter number of questions desired'
                                ),
                              ),
                            ),
                          ),
                        ],
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
                ),
              ],
            ),
          ),
      ),
    );
  }
}