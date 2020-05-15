import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Note.dart';

void main() => runApp(NoteApp());

class NoteApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
          title: Center(
            child: Text(
              "Note Hub",
              style: TextStyle(fontSize: 30),
            ),
          ),
          backgroundColor: Colors.yellow),
      body: Login(),
    ));
  }
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: FloatingActionButton(
          child: Text(
            'Get Started',
            style: TextStyle(fontSize: 10),
          ),
          //color: Colors.teal.shade100,
          onPressed: () {
            print('clicked');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondScreen()),
            );
          },
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(title: Text("Note Hub"), backgroundColor: Colors.yellow),
      body: UserNote(),
    ));
  }
}

class UserNote extends StatefulWidget {
  @override
  _UserNoteState createState() => _UserNoteState();
}

class _UserNoteState extends State<UserNote> {
  TextEditingController nameController = TextEditingController();
  TextEditingController noteBodyController = TextEditingController();
  bool _validateTitle = false;
  final CollectionReference noteCollection =
      Firestore.instance.collection('Note');

  void addItemToList() {
    print('called addItemToList');
    String title = nameController.text.trim();
    String noteBody = noteBodyController.text.trim();
    if (title.length == 0) {
      _validateTitle = true;
    } else {
      _validateTitle = false;
      var jsonString = '{"title": "$title", "note": "$noteBody"}';
      Map<String, dynamic> note = jsonDecode(jsonString);
      noteCollection.add(note);
    }
    print('finished addItemToList');
  }

  Widget _buidStream(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(10, 2, 10, 2),
      title: Text(document['title']) ?? '',
      subtitle: Text(document['note']) ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Note Title',
              errorText: _validateTitle ? 'Title Can\'t Be Empty' : null,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: noteBodyController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: 'Note'),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: RaisedButton(
                child: Text('Add'),
                padding: EdgeInsets.all(10),
                onPressed: () {
                  setState(() {
                    addItemToList();
                  });
                },
              ),
            ),
          ],
        ),
        Expanded(
            child: StreamBuilder(
                stream: noteCollection.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text('Loading');

                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.black,
                    ),
                    padding: const EdgeInsets.all(8),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, int index) {
                      return _buidStream(
                          context, snapshot.data.documents[index]);
                    },
                  );
                }))
      ],
    );
  }
}
