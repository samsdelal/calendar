import 'dart:async';
import 'package:calendar/passcode.dart';
import 'package:flutter/material.dart';
import 'package:calendar/calendar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';

class SecureStorage {
  final _storage = FlutterSecureStorage();
  final StreamController<bool> _verificationNotifier = StreamController<bool>.broadcast();
  onPasscodeEntered(String enteredPasscode) async {
    bool z = await secureStorage.checkData(enteredPasscode);
    _verificationNotifier.add(z);
  }

  Future<void> writeSecureData(String value) async {
    final writeData = await _storage.write(key: 'pass', value: value);
    return writeData;
  }

  Future<String?> readSecureData() async {
    final readData = await _storage.read(key: 'pass');
    return readData;
  }

  Future<void> deleteSecureDate() async {
    final deleteData = await _storage.write(key: 'bool', value: 'false');
    return deleteData;
  }

  Future checkData(String passCode) async {
    final state = passCode == await _storage.read(key: 'pass');
    if (state == true) {
      Get.offAll(() => Calendar());
    }
    return state;
  }

  Future makeBool(String stat) async {
    final writeData = await _storage.write(key: 'bool', value: stat);
    return writeData;
  }

  Future getbool() async {
    final getbool = await _storage.read(key: 'bool');
    if (getbool == null || getbool == 'flase') {
      await makeBool('false');
    } else {
      return getbool;
    }
  }

  Future<Widget> startApp() async {
    final bool = await getbool();
    //print(bool);
    if (bool == 'false') {
      return Scaffold(
          body: PasscodeScreen(
              title: Text('Создание passcode', style: TextStyle(color: Colors.white, fontSize: 25),),
              passwordEnteredCallback: PassCodeState().createPassCode,
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
          )
      );
    } else if (bool == 'true') {
      return Scaffold(
        body: PasscodeScreen(
          title: Text('Введите пароль', style: TextStyle(color: Colors.white, fontSize: 25),),
          passwordEnteredCallback: onPasscodeEntered,
          cancelButton: Text('', style: TextStyle(color: Colors.white, fontSize: 34),),
          deleteButton: Text('Удалить', style: TextStyle(color: Colors.white, fontSize: 20),),
          shouldTriggerVerification:_verificationNotifier.stream,
          backgroundColor: Color(0xff0A1128),
          keyboardUIConfig: const KeyboardUIConfig(
            digitBorderWidth: 1,
            digitTextStyle: TextStyle(color: Colors.white, fontSize: 34),
            deleteButtonTextStyle: TextStyle(color: Colors.white, fontSize: 34),
          ),
          ),
      );
      // return PasscodeScreen(
      //     title: Text('Введите passcode'),
      //     passwordEnteredCallback: PassCodeState().onPasscodeEntered,
      //     cancelButton: Text('Отмена'),
      //     deleteButton: Text('Удалить'),
      //     shouldTriggerVerification: PassCodeState().verificationNotifier
      //         .stream);
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Ошибка!'),
        ),
      );
    }
  }
}
