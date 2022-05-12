import 'package:flutter/material.dart';
import 'package:meranotes/constants/messages.dart';
import 'package:meranotes/constants/routes.dart';
import 'package:meranotes/enums/menu_action.dart';
import 'package:meranotes/services/auth/auth_service.dart';
import 'package:meranotes/services/cloud/cloud_note.dart';
import 'package:meranotes/services/cloud/firebase_cloud_storage.dart';
import 'package:meranotes/utilities/dialog/logout_dialog.dart';
import 'package:meranotes/views/notes/notes_list_view.dart';

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
        title: const Text(appBarTitle),
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
                    await AuthService.firebase().logOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(logoutButtonText),
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
                return const Text('Notes are loading...');
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
