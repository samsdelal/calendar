import 'package:calendar/Events.dart';
import 'package:calendar/event.dart';
import 'package:calendar/hive_db.dart';
import 'package:calendar/passcode.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedTime = DateTime.now();
  final DateTime _firstDay = DateTime(1983);
  final DateTime _lastDay = DateTime(2100);
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late Map<DateTime, List<Event>> selectedEvents;
  var storageEvents = EventStorage();
  final TextEditingController  _eventController = TextEditingController();

  @override
  initState() {
    selectedEvents = {};
    super.initState();
  }

  List<Event> _getEventsFomDay(DateTime date) {
    return storageEvents.getData()[date] ?? [];
  }

  @override
  void dispose() {
    PassCodeState().verificationNotifier.close();
    _eventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Календарь',
          style: GoogleFonts.getFont('Montserrat'),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff001F54),
        actions: <Widget>[
          IconButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('Настройки'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Get.offAll(PassCode());
                              },
                              child: const Text('Заблокировать приложение', style: TextStyle(color: Colors.white)),
                              style: TextButton.styleFrom(
                                backgroundColor: Color(0xff001F54),
                                minimumSize: Size(1200, 10),
                              ),
                          ),
                        TextButton(onPressed: ()async{
                          await SecureStorage().deleteSecureDate();
                          Get.offAll(PassCode());
                        }, child: const Text('Сбросить пароль', style: TextStyle(color: Colors.white)),
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xff001F54),
                            minimumSize: Size(1200, 10),

                          ),),
                        TextButton(onPressed: ()async{
                          await storageEvents.deleteAll();
                          Get.offAll(Calendar());
                        }, child: const Text('Очистить напоминания', style: TextStyle(color: Colors.white)),
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xff001F54),
                            minimumSize: Size(1200, 10),

                          ),)],
                      )),
              icon: const Icon(Icons.settings_rounded))
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedTime,
            firstDay: _firstDay,
            lastDay: _lastDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedTime = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedTime = focusedDay;
            },
            headerStyle:
                const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            eventLoader: _getEventsFomDay,
            // calendarStyle: const CalendarStyle(
            //   todayTextStyle: TextStyle(backgroundColor: Color(0xff1282A2), ),
            //   selectedTextStyle: TextStyle(color: Color(0xff034078))
          ),
          ..._getEventsFomDay(_selectedDay)
              .map((Event event) {
                return Card(
                  child: ListTile(title: Text(event.title, style: TextStyle(color: Colors.white),), trailing: Icon(Icons.event),)
                  ,
                color: Color(0xff034078),);
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Добавить напоминание',),
                  content: TextFormField(
                    controller: _eventController,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Отменить', style: TextStyle(color: Color(0xff001F54)))
                    ),
                    TextButton(
                        onPressed: () async {
                          storageEvents.putData(_selectedDay, Event(title: _eventController.text).toString());
                          // print('Текущее состяния; $status');
                          // if (_eventController.text.isEmpty) {
                          // } else if (selectedEvents[_selectedDay] != null) {
                          //   print(_eventController.text);
                          //   selectedEvents[_selectedDay]!
                          //       .add(Event(title: _eventController.text));
                          // } else {
                          //   selectedEvents[_selectedDay] = [
                          //     Event(title: _eventController.text)
                          //   ];
                          // }
                          Navigator.pop(context);
                          _eventController.clear();
                          setState(() {});
                          return;
                        },
                        child: const Text('Сохранить', style: TextStyle(color: Color(0xff001F54)))),
                  ],
                )),
        icon: const Icon(Icons.add_box),
        label: const Text('Добавить'),
        backgroundColor: const Color(0xff001F54),
      ),
    );
  }
}
