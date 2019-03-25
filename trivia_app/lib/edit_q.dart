import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pack.dart';
import 'dart:core';


String UID;

class PackEdit extends StatefulWidget {
  @override
  PackEditForm createState() => new PackEditForm();
}

class PackEditForm extends State<PackEdit> {

  List<Pack> _packs = List();
  List<String> keys = List();
  DatabaseReference _dbRef;
  double rating;
  String chosenKey;
  Pack chosenPack;
  var pack_chosen = 0;
  ScrollController scroll = new ScrollController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  void handleSubmit() {
    final FormState form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      _dbRef.child('$chosenKey').set({
        'name': chosenPack.name,
        'tags': chosenPack.tags,
        'user': chosenPack.user,
        'qs': chosenPack.qs,
        'rating': chosenPack.rating,
        'rateCount': chosenPack.rateCount
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if(pack_chosen == 0) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Available Packs"),
          backgroundColor: Colors.blueAccent,
        ),
        body: Column(
          children: <Widget>[
            Flexible(
              flex: 0,
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Center(
                    heightFactor: 5.0,
                    widthFactor: 1.0,
                    child: Text("Tap a pack to get started!"),
                  ),
                ),
              ),
            ),
            Flexible(
              child: new FutureBuilder<FirebaseUser>(
                future: FirebaseAuth.instance.currentUser(),
                builder: (BuildContext context,
                    AsyncSnapshot<FirebaseUser> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    UID = snapshot.data.uid;
                    return new FirebaseAnimatedList(
                      query: _dbRef,
                      itemBuilder: (BuildContext context, DataSnapshot snapshot,
                          Animation<double> animation, int index) {
                        if (UID == _packs[index].user) {
                          if(_packs[index].rateCount == 0){
                            rating = 0.0;
                          }
                          else{
                            rating = _packs[index].rating/_packs[index].rateCount;
                          }
                          return new ListTile(
                            isThreeLine: true,
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
                            onTap:(){
                              setState(() {
                                chosenPack = _packs[index];
                                chosenKey = keys[index];
                                pack_chosen = 1;
                              });
                            },
                          );
                        }
                        else {
                          return new Text('');
                        }
                      },
                    );
                  }
                  else {
                    return new Text('Loading...');
                  }
                },
              ),
            ),
          ],
        ),
      );
    }
    else{
      return new Scaffold(
          appBar: new AppBar(
            title: new Text("Edit This Pack..."),
            backgroundColor: Colors.blueAccent,
          ),
        body: SingleChildScrollView(
          controller: scroll,
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              flex: 0,
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Flex(
                    mainAxisSize: MainAxisSize.min,
                    verticalDirection: VerticalDirection.down,
                    direction: Axis.vertical,
                    children: <Widget>[
                      new Text ('Edit relevant info, scroll down for all questions'),
                      new ListTile(
                        title: TextFormField(
                          initialValue: chosenPack.name,
                          onSaved: (val) => chosenPack.name = val,
                          validator: (val) => val == "" ? val : null,
                          decoration: InputDecoration(
                              labelText: 'Enter Name'
                          ),
                        ),
                      ),
                      new ListTile(
                        title: TextFormField(
                          initialValue: chosenPack.tags,
                          onSaved: (val) => chosenPack.tags = val,
                          validator: (val) => val == "" ? val : null,
                          decoration: InputDecoration(
                              labelText: 'Enter tags, separated by single spaces'
                          ),
                        ),
                      ),
                      new ListView.builder(
                        shrinkWrap: true,
                        itemCount: chosenPack.qs.length,
                        itemBuilder: (BuildContext context, int index){
                          return new Column(
                              children: <Widget>[
                                Text("Question ${index+1}",
                                  style: TextStyle(fontSize: 15),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: new ListTile(
                                    title: TextFormField(
                                      initialValue: chosenPack.qs[index]["prompt"],
                                      onSaved: (val) => chosenPack.qs[index]["prompt"] = val,
                                      validator: (val) => val == "" ? val : null,
                                      decoration: InputDecoration(
                                          labelText: 'Enter prompt'
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: new ListTile(
                                    title: TextFormField(
                                      initialValue: chosenPack.qs[index]["answer"],
                                      onSaved: (val) => chosenPack.qs[index]["answer"] = val,
                                      validator: (val) => val == "" ? val : null,
                                      decoration: InputDecoration(
                                          labelText: 'Enter answer'
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: new ListTile(
                                    title: TextFormField(
                                      initialValue: chosenPack.qs[index]["false1"],
                                      onSaved: (val) => chosenPack.qs[index]["false1"] = val,
                                      validator: (val) => val == "" ? val : null,
                                      decoration: InputDecoration(
                                          labelText: 'Enter a false answer'
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: new ListTile(
                                    title: TextFormField(
                                      initialValue: chosenPack.qs[index]["false2"],
                                      onSaved: (val) => chosenPack.qs[index]["false2"] = val,
                                      validator: (val) => val == "" ? val : null,
                                      decoration: InputDecoration(
                                          labelText: 'Enter a false answer'
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: new ListTile(
                                    title: TextFormField(
                                      initialValue: chosenPack.qs[index]["false3"],
                                      onSaved: (val) => chosenPack.qs[index]["false3"] = val,
                                      validator: (val) => val == "" ? val : null,
                                      decoration: InputDecoration(
                                          labelText: 'Enter a false answer'
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                        },
                      ),
                      RaisedButton(
                        onPressed: () {
                          return showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: new Text("Are you sure you want to commit these changes?"),
                                actions: <Widget>[
                                  new FlatButton(
                                    child: const Text('YES'),
                                    onPressed: () {
                                      setState(() {
                                        handleSubmit();
                                      });
                                      Navigator.pop(context, true);
                                      Navigator.pop(context, true);
                                    },
                                  ),
                                  new FlatButton(
                                    child: const Text('NO'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        color: Colors.lightBlue,
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.report),
                            Text("Submit"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                  },
                child: Text('Back')
              ),
            ],
          ),
        ),
      );
    }
  }
}
