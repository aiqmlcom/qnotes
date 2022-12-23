import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qnotes/constants/routes.dart';
import 'package:qnotes/enums/menu_action.dart';
import 'package:qnotes/extensions/list/buildcontext/loc.dart';
import 'package:qnotes/services/auth/auth_service.dart';
import 'package:qnotes/services/auth/bloc/auth_bloc.dart';
import 'package:qnotes/services/auth/bloc/auth_event.dart';
import 'package:qnotes/services/cloud/cloud_note.dart';
import 'package:qnotes/services/cloud/firebase_cloud_storage.dart';
import 'package:qnotes/utilities/dialogs/logout_dialog.dart';
import 'package:qnotes/views/notes/notes_list_view.dart';

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map(
        (event) => event.length,
      );
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

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
            stream: _notesService.allNotes(ownerUserId: userId).getLength,
            builder: (context, AsyncSnapshot<int> snapshot) {
              if (snapshot.hasData) {
                final noteCount = snapshot.data ?? 0;
                return Text(context.loc.notes_title(noteCount));
              } else {
                return const Text('');
              }
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<MenuAction>(
              itemBuilder: (context) {
                return [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Text(context.loc.logout_button),
                  )
                ];
              },
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      if (!mounted) return;
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    }
                    break;
                }
              },
            )
          ],
        ),
        body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: ((note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    }),
                    onTap: (note) async {
                      Navigator.of(context)
                          .pushNamed(createOrUpdateNoteRoute, arguments: note);
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              default:
                return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}
