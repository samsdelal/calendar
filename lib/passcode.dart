import 'dart:async';
import 'package:calendar/calendar.dart';
import 'package:calendar/hive_db.dart';
import 'package:flutter/material.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:get/get.dart';

final SecureStorage secureStorage = SecureStorage();
bool _isregistered = false;

class CompleteCode extends StatefulWidget {
  String pass = '';

  CompleteCode(String pass) {
    this.pass = pass;
  }

  @override
  _PassCodeComplete createState() => _PassCodeComplete(pass);
}

class _PassCodeComplete extends State<CompleteCode> {
  String storedPasscode = '';

  _PassCodeComplete(String storedPasscode) {
    this.storedPasscode = storedPasscode;
  }

  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  completePassCode(String enteredPasscode) async {
    if (storedPasscode == enteredPasscode) {
      Get.offAll(() => Calendar());
      await secureStorage.writeSecureData(storedPasscode);
      await secureStorage.makeBool('true');
    } else {
      Get.offAll(() => PassCode());
    }
  }
  // title: Text('Повторите еще раз'),
  // passwordEnteredCallback: completePassCode,
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PasscodeScreen(
        title: Text('Повторите еще раз', style: TextStyle(color: Colors.white, fontSize: 25),),
        passwordEnteredCallback: completePassCode,
        cancelButton: Text('', style: TextStyle(color: Colors.white, fontSize: 34),),
        deleteButton: Text('Удалить', style: TextStyle(color: Colors.white, fontSize: 20),),
        shouldTriggerVerification:
        PassCodeState().verificationNotifier.stream,
        backgroundColor: Color(0xff0A1128),
        keyboardUIConfig: const KeyboardUIConfig(
          digitBorderWidth: 1,
          digitTextStyle: TextStyle(color: Colors.white, fontSize: 34),
          deleteButtonTextStyle: TextStyle(color: Colors.white, fontSize: 34),
        ),
      ),
    );
  }
}

class PassCode extends StatefulWidget {
  @override
  PassCodeState createState() => PassCodeState();
}

class PassCodeState extends State<PassCode> {
  final StreamController<bool> verificationNotifier =
      StreamController<bool>.broadcast();


  //final Future _start = Future.delayed(const Duration(seconds: 1), ()=> secureStorage.startApp());

  createPassCode(String enteredPasscode) {
    Get.offAll(() => CompleteCode(enteredPasscode));
  }

  @override
  void dispose() {
    verificationNotifier.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future<Widget>.delayed(
            Duration(seconds: 1), () => secureStorage.startApp()),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data;
          }
          return const Scaffold(
            backgroundColor: Color(0xff0A1128),
            body: Center(
                child: Text(
              'Загрузка',
              style: TextStyle(color: Colors.white, fontSize: 34),
            )),
          );
        },
      ),
    );
  }
}
