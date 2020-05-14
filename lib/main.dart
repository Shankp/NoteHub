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
  List<Note> noteList = [];
  var document;
  final CollectionReference noteCollection =
      Firestore.instance.collection('Note');

  void addItemToList() {
    print('called addItemToList');
    //noteCollection.add(data)
    String title=nameController.text;
    String noteBody=noteBodyController.text;
    var jsonString = '{"title": "$title", "note": "$noteBody"}';
    Map<String, dynamic> note = jsonDecode(jsonString);
    noteCollection.add(note);
    print('finished addItemToList');
  }

  Widget _buidStream(BuildContext context, DocumentSnapshot document) {
    return ListTile(
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
              labelText: 'Note Name',
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            controller: noteBodyController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Note',
            ),
          ),
        ),
        Row(
          children: <Widget>[
            RaisedButton(
              child: Text('Add'),
              onPressed: () {
                setState(() {
                  addItemToList();
                });
              },
            ),
          ],
        ),
        Expanded(
            child: StreamBuilder(
                stream: noteCollection.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text('Loading');

                  document = snapshot;
                  return ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, int index) {
                        return _buidStream(
                            context, snapshot.data.documents[index]);
                      });
                }))
      ],
    );
  }
}
