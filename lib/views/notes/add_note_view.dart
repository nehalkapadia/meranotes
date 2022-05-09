import 'package:flutter/material.dart';
import 'package:meranotes/constants/messages.dart';

class AddNewNoteView extends StatefulWidget {
  const AddNewNoteView({Key? key}) : super(key: key);

  @override
  State<AddNewNoteView> createState() => _AddNewNoteViewState();
}

class _AddNewNoteViewState extends State<AddNewNoteView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(addNewNoteTitle),
      ),
      body: const Text('Write your note here...!'),
    );
  }
}
