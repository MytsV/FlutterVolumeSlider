import 'dart:async';

class StreamSlider {

  final _valuesStreamController = StreamController.broadcast();

  Stream get getStream => _valuesStreamController.stream;

  double _value = 0;

  double get value => _value;
  
  void dispose() {
    _valuesStreamController.close();
  }
  
  void setValue(double value) {
    _value = value;
    _valuesStreamController.sink.add(_value);
  }

}

final blocSlider = StreamSlider();