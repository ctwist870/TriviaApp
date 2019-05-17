import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pack.dart';

String UID;

class QPage extends StatefulWidget {
  @override
  CreateQuestion createState() => new CreateQuestion();
}

void getUID() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUser user = await _auth.currentUser();
  UID = user.uid;
}

class CreateQuestion extends State<QPage> {
  List<Pack> packs = List();
  Pack newPack;
  ScrollController scroll = new ScrollController();
  List<dynamic> mapList = List();
  var qMap = {
    'prompt' : '',
    'answer' : '',
    'false1' : '',
    'false2' : '',
    'false3' : '',
    'flagCount' : 0,
  };
  DatabaseReference dbRef;
  var addQuestions = 0;
  final GlobalKey<FormState> packKey = GlobalKey<FormState>();
  final GlobalKey<FormState> questKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    newPack = Pack("", "", mapList, UID, 0.5, 0);
    final FirebaseDatabase database = FirebaseDatabase.instance;
    dbRef = database.reference().child('Packs');
    dbRef.onChildAdded.listen(_onPackAdded);
  }

  _onPackAdded(Event event) {
    setState(() {
      packs.add(Pack.fromSnapshot(event.snapshot));
    });
  }

  void handleInitialSubmit() {
    final FormState form = packKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
    }
  }

  void handleQuestionSubmit() {
    final FormState form = questKey.currentState;

    if (form.validate()) {
      form.save();
      form.reset();
      newPack.qs.add(new Map.from(qMap));
    }
  }

  void handleFinalSubmit() {
    print(newPack.user);
      dbRef.push().set(newPack.toJson());
  }

  @override
  Widget build(BuildContext context) {
    if(addQuestions == 0){
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Enter new pack information"),
        ),
        body: Center(
          child: Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("images/ambient3.gif"),
                fit: BoxFit.cover,
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Flexible(
                    flex: 0,
                    child: Center(
                      child: Form(
                        key: packKey,
                        child: Flex(
                          direction: Axis.vertical,
                          children: <Widget>[
                            new FutureBuilder<FirebaseUser>(
                              future: FirebaseAuth.instance.currentUser(),
                              builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
                                if (snapshot.connectionState == ConnectionState.done) {
                                  UID = snapshot.data.uid;
                                  newPack.user = UID;
                                  return new Text (
                                      'Enter a name for the pack, and relevant tags',
                                      style: TextStyle(fontSize: 20, color: Colors.white70),
                                  );
                                }
                                else {
                                  return new Text('Loading...');
                                }
                              },
                            ),
                            Container(
                              alignment: Alignment(0.0, 0.0),
                              color: Theme.of(context).accentColor,
                              child: ListTile(
                                title: TextFormField(
                                  initialValue: "",
                                  onSaved: (val) => newPack.name = val,
                                  validator: (val) => val == "" ? val : null,
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context).accentColor,
                                      labelStyle: TextStyle(color: Colors.black),
                                      labelText: 'Enter Name'
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment(0.0, 0.0),
                              color: Theme.of(context).accentColor,
                              child: ListTile(
                                title: TextFormField(
                                  initialValue: "",
                                  onSaved: (val) => newPack.tags = val,
                                  validator: (val) => val == "" ? val : null,
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context).accentColor,
                                      labelStyle: TextStyle(color: Colors.black),
                                      labelText: 'Enter tags, separated by single spaces'
                                  ),
                                ),
                              ),
                            ),
                            RaisedButton(
                              onPressed: () {
                                return showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: new Text("Pack created! Add questions now?"),
                                      actions: <Widget>[
                                        new FlatButton(
                                          child: const Text('YES'),
                                          onPressed: () {
                                            handleInitialSubmit();
                                            setState(() {
                                              addQuestions = 1;
                                            });
                                            Navigator.pop(context, false);
                                          },
                                        ),
                                        new FlatButton(
                                          child: const Text('NO'),
                                          onPressed: () {
                                            handleInitialSubmit();
                                            handleFinalSubmit();
                                            Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
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
                            RaisedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel')
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    else{
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Create a new question!"),
        ),
        body: Center(
          child: Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("images/ambient3.gif"),
                fit: BoxFit.cover,
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: SingleChildScrollView(
                controller: scroll,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Flexible(
                      flex: 0,
                      child: Center(
                        child: Form(
                          key: questKey,
                          child: Flex(
                            direction: Axis.vertical,
                            children: <Widget>[
                              new Text (
                                  'Enter prompt, answer, and 3 false answers',
                                  style: TextStyle(fontSize: 20, color: Colors.white70),
                              ),
                              Container(
                                color: Theme.of(context).accentColor,
                                child: ListTile(
                                  title: TextFormField(
                                    initialValue: "",
                                    onSaved: (val) => qMap["prompt"] = val,
                                    validator: (val) => val == "" ? val : null,
                                    decoration: InputDecoration(
                                        labelText: 'Enter Prompt'
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                color: Theme.of(context).accentColor,
                                child: ListTile(
                                  title: TextFormField(
                                    initialValue: "",
                                    onSaved: (val) => qMap["answer"] = val,
                                    validator: (val) => val == "" ? val : null,
                                    decoration: InputDecoration(
                                        labelText: 'Enter Correct Answer'
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                color: Theme.of(context).accentColor,
                                child: ListTile(
                                  title: TextFormField(
                                    initialValue: "",
                                    onSaved: (val) => qMap["false1"] = val,
                                    validator: (val) => val == "" ? val : null,
                                    decoration: InputDecoration(
                                        labelText: 'Enter a False Answer'
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                color: Theme.of(context).accentColor,
                                child: ListTile(
                                  title: TextFormField(
                                    initialValue: "",
                                    onSaved: (val) => qMap["false2"] = val,
                                    validator: (val) => val == "" ? val : null,
                                    decoration: InputDecoration(
                                        labelText: 'Enter a False Answer'
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                color: Theme.of(context).accentColor,
                                child: ListTile(
                                  title: TextFormField(
                                    initialValue: "",
                                    onSaved: (val) => qMap["false3"] = val,
                                    validator: (val) => val == "" ? val : null,
                                    decoration: InputDecoration(
                                        labelText: 'Enter a False Answer'
                                    ),
                                  ),
                                ),
                              ),
                              RaisedButton(
                                onPressed: () {
                                  showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: new Text("Question added! Add another?"),
                                        actions: <Widget>[
                                          new FlatButton(
                                            child: const Text('YES'),
                                            onPressed: () {
                                              handleQuestionSubmit();
                                              Navigator.pop(context);
                                            },
                                          ),
                                          new FlatButton(
                                            child: const Text('NO'),
                                            onPressed: () {
                                              handleQuestionSubmit();
                                              handleFinalSubmit();
                                              Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                color: Colors.lightGreenAccent,
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
                        child: Text('Cancel')
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

