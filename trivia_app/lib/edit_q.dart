import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
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
  String chosenKey;
  Pack chosenPack;
  var pack_chosen = 0;

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
        'qs': chosenPack.qs
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    if(pack_chosen == 0) {
      return new Scaffold(
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
                          return new ListTile(
                            enabled: true,
                            leading: Icon(Icons.create),
                            title: Text(_packs[index].name),
                            subtitle: Text(_packs[index].tags),
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
        body: Column(
          children: <Widget>[
            Flexible(
              flex: 0,
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      new Text ('Edit relevant info, scroll down for all questions'),
                      ListTile(
                        title: TextFormField(
                          initialValue: chosenPack.name,
                          onSaved: (val) => chosenPack.name = val,
                          validator: (val) => val == "" ? val : null,
                          decoration: InputDecoration(
                              labelText: 'Enter Name'
                          ),
                        ),
                      ),
                      ListTile(
                        title: TextFormField(
                          initialValue: chosenPack.tags,
                          onSaved: (val) => chosenPack.tags = val,
                          validator: (val) => val == "" ? val : null,
                          decoration: InputDecoration(
                              labelText: 'Enter tags, separated by single spaces'
                          ),
                        ),
                      ),
                      /*AnimatedList(
                        itemBuilder: (BuildContext context, int index, Animation<double> animation) {
                          for (Map m in chosenPack.qs) {
                              ListTile(
                              title: TextFormField(
                                initialValue: m["prompt"],
                                onSaved: (val) => m["prompt"] = val,
                                validator: (val) => val == "" ? val : null,
                                decoration: InputDecoration(
                                    labelText: 'Enter Prompt'
                                ),
                              ),
                            );
                          }
                        },
                      ),*/
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
      );
    }
  }

}
