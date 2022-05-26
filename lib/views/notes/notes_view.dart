import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meranotes/constants/routes.dart';
import 'package:meranotes/enums/menu_action.dart';
import 'package:meranotes/extenions/buildcontext/loc.dart';
import 'package:meranotes/services/cloud/cloud_note.dart';
import 'package:meranotes/services/auth/auth_service.dart';
import 'package:meranotes/views/notes/notes_list_view.dart';
import 'package:meranotes/services/auth/bloc/auth_bloc.dart';
import 'package:meranotes/services/auth/bloc/auth_event.dart';
import 'package:meranotes/utilities/dialog/logout_dialog.dart';
import 'package:meranotes/services/cloud/firebase_cloud_storage.dart';

extension Count<T extends Iterable> on Stream {
  Stream<int> get getLength => map((event) => event.length);
}

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
            stream: _notesService
                .getAllNotes(
                  ownerUserId: userId,
                )
                .getLength,
            builder: (context, AsyncSnapshot<int> snapshot) {
              if (snapshot.hasData) {
                final noteCount = snapshot.data ?? 0;
                final text = context.loc.notes_title(
                  noteCount,
                );
                return Text(text);
              } else {
                return const Text('');
              }
            }),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(addUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(
                          const AuthEventLogout(),
                        );
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(
                    context.loc.logout_button,
                  ),
                )
              ];
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.getAllNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: allNotes,
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(documentId: note.documentId);
                  },
                  onTap: (note) async {
                    Navigator.of(context).pushNamed(
                      addUpdateNoteRoute,
                      arguments: note,
                    );
                  },
                );
              } else {
                return Text(context.loc.notes_are_loading);
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
