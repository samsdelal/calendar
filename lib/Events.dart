import 'package:calendar/event.dart';
import 'package:hive/hive.dart';


class EventStorage{
  putData(DateTime date, String event){
      List ?events = Hive.box('events').get(date.toString());
      if (events != null){
        events.add(event);
        Hive.box('events').put(date.toString(), events);
      }else{
        Hive.box('events').put(date.toString(), [event]);
      }
  }
  getData(){
    var returnData = Map();
    var evetns =  Hive.box('events').toMap();
    for(var i in evetns.keys){
      var d = DateTime.parse(i);
      List <Event> eventsa = [];
      for(var q in evetns[i]){
        eventsa.add(Event(title: q));
      }
      returnData[d] = eventsa;
    }
    return returnData;
  }
  deleteAll(){
    Hive.box('events').clear();
  }
}