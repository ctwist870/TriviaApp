import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

import 'question_create.dart';
import 'edit_q.dart';
import 'users.dart';
import 'search.dart';
import 'rand_pack.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Trivia Time',
      home: HomePage(),
      theme: new ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey,
        accentColor: Colors.white30,
        //primarySwatch: Colors.blue,
      ),
    ),
  );
}

class HomePage extends StatefulWidget {
  @override
  State createState() => SignInState();
}

class SignInState extends State<HomePage> {
  GoogleSignInAccount _currentUser;
  UserInformation nUser;
  DatabaseReference dRef;
  FirebaseUser curr;
  String userID;

  @override
  void initState() {
    super.initState();
    nUser = UserInformation("", "", "");
    final FirebaseDatabase database = FirebaseDatabase.instance;
    dRef = database.reference().child('users');

    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });
    googleSignIn.signInSilently();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<FirebaseUser> _signIn() async {
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    userID = user.uid;
    print("User Name: ${user.displayName}");
    print("UID: $userID");

    getUserInfo(
        _currentUser.displayName,
        _currentUser.email,
        user.uid,
        nUser
    );

    handleSubmit(dRef, userID, nUser);

    return user;
  }

  void _signOut() {
      googleSignIn.signOut();
      print("User signed out");
  }

    Widget _buildBody() {
      if (_currentUser != null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: FractionalOffset.topLeft,
                    child: Center(
                      child: ListTile(
                        title: Text("Signed in as " + _currentUser.displayName),
                        subtitle: Text(_currentUser.email),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: FractionalOffset.topRight,
                    child: RaisedButton(
                      child: const Text('SIGN OUT'),
                      onPressed: _signOut,
                    ),
                  ),
                )
              ],
            ),
            RaisedButton(
                child: const Text('Create Trivia Pack'),
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QPage()),
                  );
                },
                color: Colors.blue
            ),
            RaisedButton(
                child: const Text('Edit My Packs'),
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PackEdit()),
                  );
                },
                color: Colors.blue
            ),
            RaisedButton(
                child: const Text('Search for Packs'),
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Search()),
                  );
                },
                color: Colors.blue
            ),
            RaisedButton(
                child: const Text('Generate Pack'),
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RandomPack()),
                  );
                },
                color: Colors.blue
            ),
          ],
        );
      }
      else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const Text("Sign in with a Google account"),
            RaisedButton(
              onPressed: () => _signIn(),
              child: const Text('SIGN IN'),
            ),
          ],
        );
      }
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Welcome to Trivia Time!"),
          ),
          body: Center(
            child: Container(
              //color: Theme.of(context).accentColor,
              decoration: new BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/ambient.gif"),
                  fit: BoxFit.cover,
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: _buildBody(),
              ),
            ),
          ),
      );
    }
}
