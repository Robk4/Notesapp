import 'package:flutter/material.dart';
import 'package:notesapp/services/cloud/cloud_note.dart';
//import 'package:notesapp/services/crud/notes_service.dart';
import 'package:notesapp/utilities/dialogs/delete_dialog.dart';

typedef NoteCallBack = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallBack onDeleteNote;
  final NoteCallBack whenPressed;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.whenPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return ListTile(
          onTap: () {
            whenPressed(note);
          },
          title: Text(
            note.text,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
