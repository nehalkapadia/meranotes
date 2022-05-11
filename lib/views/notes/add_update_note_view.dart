import 'package:flutter/material.dart';
import 'package:meranotes/constants/messages.dart';
import 'package:meranotes/services/auth/auth_service.dart';
import 'package:meranotes/services/crud/notes_service.dart';
import 'package:meranotes/utilities/generic/get_arguments.dart';

class AddUpdateNoteView extends StatefulWidget {
  const AddUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<AddUpdateNoteView> createState() => _AddUpdateNoteViewState();
}

class _AddUpdateNoteViewState extends State<AddUpdateNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _notesService = NotesService();
    _textEditingController = TextEditingController();
    super.initState();
  }

  void _textEditingControllerListener() async {
    final note = _note;

    if (note == null) {
      return;
    }

    final text = _textEditingController.text;

    await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  void _setupTextEditingControllerListener() {
    _textEditingController.removeListener(_textEditingControllerListener);
    _textEditingController.addListener(_textEditingControllerListener);
  }

  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textEditingController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final userEmail = currentUser.email!;
    final owner = await _notesService.getUser(email: userEmail);

    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textEditingController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextIsNoteEmpty() async {
    final note = _note;

    if (_textEditingController.text.isNotEmpty && note != null) {
      await _notesService.updateNote(
        note: note,
        text: note.text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNoteEmpty();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(addNewNoteTitle),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextEditingControllerListener();
              return TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: hintTypeText,
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
