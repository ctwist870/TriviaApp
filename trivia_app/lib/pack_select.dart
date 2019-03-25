import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'pack.dart';
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
  int index;
  String ans;
  int correct;
  int len;
  var submit;
  var rated;
  double rating;

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
    len  = chosenPack.qs.length;
    submit = (String value) { setState(() { ans = value; }); };
    rated = false;
    rating = 0;
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

  @override
  Widget build(BuildContext context) {
    if(index+1 <= len){
      return new Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              heightFactor: 5.0,
              widthFactor: 1.0,
              child: new Text (chosenPack.name,
                style: TextStyle(fontSize: 20),
              ),
            ),
            Center(
              heightFactor: 5.0,
              widthFactor: 1.0,
              child: new Text (chosenPack.qs[index]["prompt"],
                  style: TextStyle(fontSize: 15)
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
                        title: Text(chosenPack.qs[index]["answer"]),
                        value: 'answer',
                        groupValue: ans,
                        onChanged: submit,
                      ),
                      RadioListTile<String>(
                        title: Text(chosenPack.qs[index]["false1"]),
                        value: 'false1',
                        groupValue: ans,
                        onChanged: submit,
                      ),
                      RadioListTile<String>(
                        title: Text(chosenPack.qs[index]["false2"]),
                        value: 'false2',
                        groupValue: ans,
                        onChanged: submit,
                      ),
                      RadioListTile<String>(
                        title: Text(chosenPack.qs[index]["false3"]),
                        value: 'false3',
                        groupValue: ans,
                        onChanged: submit,
                      ),
                      RaisedButton(
                        onPressed: () {
                          setState(() {
                            submit = null;
                            if(ans == 'answer'){
                              correct += 1;
                            }
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
                              index += 1;
                              submit = (String value) { setState(() { ans = value; }); };
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
      );
    }
    else{
      if(chosenKey == "random"){
        return new Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                heightFactor: 5.0,
                child: new Text (chosenPack.name,
                    style: TextStyle(fontSize: 15)
                ),
              ),
              Center(
                heightFactor: 5.0,
                child: new Text ("Final Score: $correct/$len",
                    style: TextStyle(fontSize: 15)
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
        );
      }
      else{
        return new Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                heightFactor: 5.0,
                child: new Text (chosenPack.name,
                    style: TextStyle(fontSize: 15)
                ),
              ),
              Center(
                heightFactor: 5.0,
                child: new Text ("Final Score: $correct/$len",
                    style: TextStyle(fontSize: 15)
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
                borderColor: Colors.black,
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
        );
      }
    }
  }
}