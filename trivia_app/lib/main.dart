import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

import 'question_create.dart';
import 'edit_q.dart';
import 'users.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Trivia App',
      home: HomePage(),
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
            ListTile(
              leading: GoogleUserCircleAvatar(
                identity: _currentUser,
              ),
              title: Text(_currentUser.displayName),
              subtitle: Text(_currentUser.email),
            ),
            const Text("Signed in as USER."),
            RaisedButton(
              child: const Text('SIGN OUT'),
              onPressed: _signOut,
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
                color: Colors.red
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
            title: const Text('It\'s a Trivia App'),
          ),
          body: ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: _buildBody(),
          ));
    }
}