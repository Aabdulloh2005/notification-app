import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:practice/controllers/notes_controller.dart';
import 'package:practice/models/note.dart';
import 'package:practice/services/local_notification_services.dart';
import 'package:practice/services/user_auth_sevice.dart';
import 'package:practice/views/screens/pomodoro_page.dart';
import 'package:practice/views/screens/profile_screen.dart';
import 'package:practice/views/widgets/custom_bottom_sheet.dart';
import 'package:intl/intl.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});

  final _notesController = NotesController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          },
          icon: const Icon(Icons.person),
        ),
        title: const Text("HomePage"),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => const PomodoroPage(),
              ));
            },
            child: const CircleAvatar(
              radius: 15,
              backgroundImage: AssetImage("assets/images/tomato.png"),
            ),
          ),
          const Gap(20),
          IconButton(
            onPressed: () {
              UserAuthService().signOut();
            },
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder(
          stream: _notesController.getNotes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: Text("Apida Malumot yoq"),
              );
            }
            final data = snapshot.data!.docs;
            return data.isEmpty
                ? const Center(
                    child: Text("Apida Malumot yoq"),
                  )
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final note = Note.fromJson(data[index]);
                      DateTime dateTime = note.date.toDate();
                      String formattedDate =
                          DateFormat("dd-MMMM-yyyy hh:mm").format(dateTime);

                      // Schedule a notification for 5 minutes before the note's time
                      scheduleNotification(note, dateTime);

                      return Card(
                        child: ListTile(
                          trailing: IconButton(
                            onPressed: () {
                              _notesController.deleteNote(note.id);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                          leading: IconButton(
                            onPressed: () {
                              _notesController.upadteNote(
                                note.id,
                                !note.isDone,
                                date: note.date,
                                title: note.title,
                              );
                            },
                            icon: note.isDone
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : const Icon(
                                    Icons.circle_outlined,
                                    color: Colors.grey,
                                  ),
                          ),
                          title: Text(
                            note.title,
                            style: TextStyle(
                              color: note.isDone ? Colors.grey : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              decoration: note.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(formattedDate),
                        ),
                      );
                    },
                  );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (_) => AddNoteBottomSheet(
              onAddNote: (title, date) {
                _notesController.upadteNote(
                  UniqueKey().toString(),
                  false,
                  title: title,
                  date: date,
                );
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void scheduleNotification(Note note, DateTime dateTime) {
    // Calculate the time for the notification (5 minutes before the note's time)
    DateTime notificationTime = dateTime.subtract(const Duration(minutes: 5));
    if (notificationTime.isAfter(DateTime.now())) {
      LocalNotificationsService.showScheduledNotification(
        id: note.id.hashCode,
        title: "Reminder",
        body: "${note.title} - 5 minutes left",
        scheduledTime: notificationTime,
      );
    }
  }
}
