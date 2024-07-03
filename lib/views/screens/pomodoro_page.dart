import 'package:flutter/material.dart';
import 'package:flutter_flip_clock/flutter_flip_clock.dart';
import 'package:practice/services/local_notification_services.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  @override
  void initState() {
    super.initState();
    _scheduleNotification();
  }

  void _scheduleNotification() async {
    await Future.delayed(const Duration(seconds: 1));

    await Future.delayed(const Duration(minutes: 1));
    await LocalNotificationsService.showNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: OrientationBuilder(
        builder: (context, orientation) {
          final height = MediaQuery.of(context).size.height;
          final width = MediaQuery.of(context).size.width;
          final isPortrait = orientation == Orientation.portrait;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlipClock.countdown(
                  duration: const Duration(minutes: 1),
                  height: isPortrait ? 120.0 : height - 10,
                  onDone: () {},
                  width: isPortrait ? 80.0 : width / 5 + 10,
                  digitColor: Colors.white,
                  backgroundColor: Colors.black,
                  digitSize: isPortrait ? 80.0 : height / 2,
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  startTime: DateTime.now(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
