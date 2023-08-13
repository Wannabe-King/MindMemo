import 'package:flutter/material.dart';

class  NewNoteView extends StatefulWidget {
  const  NewNoteView({super.key});

  @override
  State< NewNoteView> createState() => _ NewNoteViewState();
}

class _ NewNoteViewState extends State< NewNoteView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: const Text('Write your new note here ...'),
    );
  }
}