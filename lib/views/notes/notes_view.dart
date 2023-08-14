import 'package:flutter/material.dart';
import 'package:learning/services/auth/auth_service.dart';
import '../../constants/routes.dart';
import '../../enum/menu_action.dart';
import '../../services/crud/notes_service.dart';

//use stf shorthand
class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {

  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService=NotesService();
    _notesService.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
                  break;
                case MenuAction.settings:
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
                PopupMenuItem<MenuAction>(
                  value: MenuAction.settings,
                  child: Text('Settings'),
                ),
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context,snapshot) {
           switch (snapshot.connectionState){
            case ConnectionState.done :
                return StreamBuilder(
                  stream: _notesService.allNote,
                  builder:(context, snapshot) {
                    switch (snapshot.connectionState){
                      case ConnectionState.waiting :
                      case ConnectionState.active :
                          if(snapshot.hasData){
                            final allNotes=snapshot.data as List<DatabaseNote>;
                            // print(allNotes);
                            // return const Text('Got all the notes.')
                            return ListView.builder(
                              itemCount: allNotes.length,
                              itemBuilder: (context, index) {
                                final note=allNotes[index];
                                return ListTile(
                                  title: Text(note.note,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              } ,
                            );
                          }else{
                            return const CircularProgressIndicator();
                          }
                      default:
                        return const CircularProgressIndicator();
                    }
                    
                  },
                );
            default:
              return const CircularProgressIndicator();
          }
        },
        ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            IconButton(
                  onPressed:() {
                  Navigator.of(context).pushNamed(newNoteRoute);
                }, 
                icon: const Icon(Icons.add),
                ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancle')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Logout'))
          ],
        );
      }).then((value) => value ?? false);
}
