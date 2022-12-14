import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:truffle_flutter/note.service.dart';

final noteServiceProvider = ChangeNotifierProvider((ref) => NoteService());

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.exo2TextTheme(),
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Web3 Notes'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  late var theme = Theme.of(context),
      textTheme = theme.textTheme,
      colorScheme = theme.colorScheme;

  final _formKey = GlobalKey<FormState>(),
      _titleController = TextEditingController(),
      _descController = TextEditingController();

  void _addNote() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      ref
          .read(noteServiceProvider)
          .addNote(_titleController.text.trim(), _descController.text.trim());
      _formKey.currentState?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(noteServiceProvider).notes;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// create note section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: Text(
                'Complete the form to create a new note',
                textAlign: TextAlign.center,
                style: textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextFormField(
                controller: _titleController,
                validator:
                    RequiredValidator(errorText: 'This field is required'),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  filled: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextFormField(
                controller: _descController,
                validator:
                RequiredValidator(errorText: 'This field is required'),
                decoration: const InputDecoration(
                  hintText: 'Description',
                  filled: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              onPressed: _addNote,
              tooltip: 'Add new note',
              icon: const Icon(TablerIcons.note),
              label: const Text('New note'),
            ),
            const SizedBox(height: 40),

            /// existing notes section
            Expanded(
              child: notes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            TablerIcons.notes,
                            size: 64,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'You have no notes yet. Tap the button to get started',
                              style: textTheme.subtitle1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(notes[index].title),
                        subtitle: Text(notes[index].description),
                      ),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: notes.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
