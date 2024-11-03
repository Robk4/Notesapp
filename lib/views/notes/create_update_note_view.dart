import 'package:flutter/material.dart';
import 'package:notesapp/services/auth/auth_service.dart';
import 'package:notesapp/services/cloud/cloud_note.dart';
import 'package:notesapp/services/cloud/firebase_cloud_storage.dart';
import 'package:notesapp/utilities/dialogs/empty_note_dialog.dart';
//import 'package:notesapp/services/crud/notes_service.dart';
import 'package:notesapp/utilities/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    //final email = currentUser.email;
    // final owner = await _notesService.getUser(email: email); Local database
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

//Method for deleting the new note if no text was entered
  void _deleteNoteIfTextEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

//Method for saving the new note if any text was entered
  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (text.isNotEmpty && note != null) {
      await _notesService.updateNote(
        documentId: note.documentId,
        text: text,
      );
    }
  }

  void _setupTextControllerListener() async {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      documentId: note.documentId,
      text: text,
    );
  }

//Initializing the methods on exiting the screen(dispose())
  @override
  void dispose() {
    _deleteNoteIfTextEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 66, 123, 228),
        actions: [
          IconButton(
              onPressed: () async {
                final text = _textController.text;
                if (_note == null || text.isEmpty) {
                  await showEmptyNoteDialog(context);
                } else {
                  Share.share(text); //SharPlus plugin
                }
              },
              icon: const Icon(Icons.share)),
        ],
        title: const Text("Adding a new note.."),
      ),
      backgroundColor: const Color(0xFFDCCCBB),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration:
                    const InputDecoration(hintText: "your notes go here?.."),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
