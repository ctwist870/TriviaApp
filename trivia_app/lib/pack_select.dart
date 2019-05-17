import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'pack.dart';
import 'dart:math';
import 'dart:core';

class Trivia extends StatefulWidget {
  final Pack chosenPack;
  final String chosenKey;

  Trivia({Key key, @required this.chosenPack, @required this.chosenKey}) : super(key: key);

  @override
  TriviaPage createState() => new TriviaPage(chosenPack: chosenPack, chosenKey: chosenKey);
}

class TriviaPage extends State<Trivia> {
  final Pack chosenPack;
  final String chosenKey;
  DatabaseReference _dbRef;
  Random rand;
  int index;
  String ans;
  int correct;
  int len;
  int flagCount;
  var submit;
  var styleCheck;
  var rated;
  var flagged;
  var tstyle;
  var ansstyle;
  double rating;
  List<String> answers;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TriviaPage({Key key, @required this.chosenPack, this.chosenKey});

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    _dbRef = database.reference().child('Packs');
    index = 0;
    ans = '';
    correct = 0;
    flagCount = 0;
    len  = chosenPack.qs.length;
    submit = (String value) { setState(() { ans = value; }); };
    styleCheck = (String answer) { if(answer == "answer"){return ansstyle;} else{return tstyle;} };
    rated = false;
    if(chosenKey == "random"){
      flagged = true;
    }
    else {
      flagged = false;
    }
    rating = 0;
    tstyle = TextStyle(fontSize: 18, color: Colors.white70);
    ansstyle = TextStyle(fontSize: 18, color: Colors.white70);
    answers = ["answer", "false1", "false2", "false3"];
    answers.shuffle();
  }

  void addRating() {
    setState(() {
      _dbRef.child('$chosenKey').set({
        'name': chosenPack.name,
        'tags': chosenPack.tags,
        'user': chosenPack.user,
        'qs': chosenPack.qs,
        'rating': chosenPack.rating += rating,
        'rateCount': chosenPack.rateCount += 1
      });
      rated = true;
    });
  }

  void initFlag() {
    setState(() {
      chosenPack.qs[index]["flagCount"] += 1;
      _dbRef.child('$chosenKey').set({
        'name': chosenPack.name,
        'tags': chosenPack.tags,
        'user': chosenPack.user,
        'qs': chosenPack.qs,
        'rating': chosenPack.rating,
        'rateCount': chosenPack.rateCount
      });
      flagged = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(index+1 <= len){
      flagCount = chosenPack.qs[index]["flagCount"];
      return new Scaffold(
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
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Center(
          heightFactor: 5.0,
          widthFactor: 1.0,
          child: new Text (chosenPack.name,
            style: TextStyle(fontSize: 25, color: Colors.white70),
          ),
        ),
        Center(
          widthFactor: 1.0,
          child: new Text (chosenPack.qs[index]["prompt"],
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ),
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
                  RadioListTile<String>(
                    title: Text(chosenPack.qs[index][answers[0]],
                      style: styleCheck(answers[0]),
                    ),
                    value: chosenPack.qs[index][answers[0]],
                    groupValue: ans,
                    onChanged: submit,
                  ),
                  RadioListTile<String>(
                    title: Text(chosenPack.qs[index][answers[1]],
                      style: styleCheck(answers[1]),
                    ),
                    value: chosenPack.qs[index][answers[1]],
                    groupValue: ans,
                    onChanged: submit,
                  ),
                  RadioListTile<String>(
                    title: Text(chosenPack.qs[index][answers[2]],
                      style: styleCheck(answers[2]),
                    ),
                    value: chosenPack.qs[index][answers[2]],
                    groupValue: ans,
                    onChanged: submit,
                  ),
                  RadioListTile<String>(
                    title: Text(chosenPack.qs[index][answers[3]],
                      style: styleCheck(answers[3]),
                    ),
                    value: chosenPack.qs[index][answers[3]],
                    groupValue: ans,
                    onChanged: submit,
                  ),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        submit = null;
                        if(ans == chosenPack.qs[index]["answer"]){
                          correct += 1;
                        }
                        ansstyle = TextStyle(fontSize: 20, color: Colors.green);
                      });
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
                  new Text ("Questions Correct: $correct/$len",
                    style: TextStyle(fontSize: 15),
                  ),
                  new Text ("This question has been flagged $flagCount times"),
                  RaisedButton(
                      onPressed: flagged ? null : initFlag,
                      child: Text('Flag')
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: <Widget>[
            new Expanded(
              child: new Align(
                alignment: FractionalOffset.bottomLeft,
                child: RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Quit')
                ),
              ),
            ),
            new Expanded(
              child: new Align(
                alignment: FractionalOffset.bottomRight,
                child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        if(index < chosenPack.qs.length){
                          answers.shuffle();
                          index += 1;
                          submit = (String value) { setState(() { ans = value; }); };
                          flagged = false;
                          ansstyle = tstyle;
                        }
                      });
                    },
                    child: Text('Next')
                ),
              ),
            ),
          ],
        ),
      ],
    ),
    ),
    ),
        )
      );
    }
    else{
      if(chosenKey == "random"){
        return new Scaffold(
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
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Center(
                        heightFactor: 5.0,
                        child: new Text (chosenPack.name,
                            style: TextStyle(fontSize: 25, color: Colors.white70),
                        ),
                      ),
                      Center(
                        heightFactor: 5.0,
                        child: new Text ("Final Score: $correct/$len",
                            style: TextStyle(fontSize: 25, color: Colors.white70),
                        ),
                      ),
                      RaisedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Return')
                      ),
                    ],
                  ),
              ),
            ),
          )
        );
      }
      else{
        return new Scaffold(
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
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Center(
                          heightFactor: 5.0,
                          child: new Text (chosenPack.name,
                              style: TextStyle(fontSize: 25, color: Colors.white70),
                          ),
                        ),
                        Center(
                          heightFactor: 5.0,
                          child: new Text ("Final Score: $correct/$len",
                              style: TextStyle(fontSize: 25, color: Colors.white70),
                          ),
                        ),
                        new Text("Give a rating (if you want)",
                          style: TextStyle(fontSize: 15),
                        ),
                        SmoothStarRating(
                          allowHalfRating: true,
                          onRatingChanged: (v) {
                            setState(() {
                              rating = v;
                            });
                          },
                          starCount: 5,
                          rating: rating,
                          size: 40.0,
                          color: Colors.yellow,
                          borderColor: Colors.yellow,
                        ),
                        RaisedButton(
                            onPressed: rated ? null : addRating,
                            child: Text('Submit Rating')
                        ),
                        RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Return')
                        ),
                      ],
                    ),
                ),
              ),
          ),
        );
      }
    }
  }
}