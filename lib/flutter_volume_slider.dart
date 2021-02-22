import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'stream_slider.dart';

class FlutterVolumeSlider extends StatefulWidget {
  final Display display;
  final Color sliderActiveColor;
  final Color sliderInActiveColor;
  final Color iconColor;
  final double width;

  FlutterVolumeSlider(
      {this.sliderActiveColor, this.sliderInActiveColor, @required this.display, this.iconColor = Colors.black, this.width = 175});

  @override
  _FlutterVolumeSliderState createState() => _FlutterVolumeSliderState();
}

class _FlutterVolumeSliderState extends State<FlutterVolumeSlider> {

  _FlutterVolumeSliderState() {
    initVal = blocSlider.value;
  }

  double initVal;
  MethodChannel _channel = MethodChannel('freekit.fr/volume');

  Future<void> changeVolume(double volume) async {
    try {
      return _channel.invokeMethod('changeVolume', <String, dynamic>{
        'volume': volume,
      });
    } on PlatformException catch (e) {
      throw 'Unable to change volume : ${e.message}';
    }
  }

  Future<MaxVolume> getMaxVolume() async {
    try {
      var val = await _channel.invokeMethod('getMaxVolume');
      return MaxVolume(val.toDouble());
    } on PlatformException catch (e) {
      throw 'Unable to get max volume : ${e.message}';
    }
  }

  Future<MinVolume> getMinVolume() async {
    try {
      var val = await _channel.invokeMethod('getMinVolume');
      return MinVolume(val.toDouble());
    } on PlatformException catch (e) {
      throw 'Unable to get max volume e : ${e.message}';
    }
  }

  _buildSlider(maxVol, minVol) {

    return Container(
      width: widget.width - 50,
      child: Slider(
        activeColor: widget.sliderActiveColor != null
            ? widget.sliderActiveColor
            : Colors.black,
        inactiveColor: widget.sliderInActiveColor != null
            ? widget.sliderInActiveColor
            : Colors.grey,
        value: initVal > maxVol.value ? 0 : initVal,
        divisions: 50,
        max: maxVol.value,
        min: minVol.value,
        onChanged: (value) {
          changeVolume(value);
          blocSlider.setValue(value);
          setState(() => initVal = value);
        },
      ),
    );

  }

  _buildVerticalContainer(maxVol, minVol) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          CupertinoIcons.volume_mute,
          size: 25.0,
          color: Colors.black,
        ),
        Container(
          height: 175,
          child: new Transform(
            alignment: FractionalOffset.center,
            // Rotate sliders by 90 degrees
            transform: new Matrix4.identity()..rotateZ(90 * 3.1415927 / 180),
            child: _buildSlider(maxVol, minVol),
          ),
        ),
        Icon(
          CupertinoIcons.volume_up,
          size: 25.0,
          color: Colors.black,
        ),
      ],
    );
  }

  _buildHorizontalContainer(maxVol, minVol) {
    return Container( child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          CupertinoIcons.volume_mute,
          size: 25.0,
          color: widget.iconColor,
        ),
        _buildSlider(maxVol, minVol),
        Icon(
          CupertinoIcons.volume_up,
          size: 25.0,
          color: widget.iconColor,
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider<MaxVolume>(
            create: (_) async => getMaxVolume(), initialData: MaxVolume(1.0)),
        FutureProvider<MinVolume>(
            create: (_) async => getMinVolume(), initialData: MinVolume(0.0)),
      ],
      child: Consumer2<MaxVolume, MinVolume>(
          builder: (context, maxVol, minVol, child) {
        if (widget.display == Display.HORIZONTAL) {
          return _buildHorizontalContainer(maxVol, minVol);
        } else {
          return _buildVerticalContainer(maxVol, minVol);
        }
      }),
    );
  }
}

enum Display { HORIZONTAL, VERTICAL }

class MinVolume {
  double value;
  MinVolume(this.value);
}

class MaxVolume {
  double value;
  MaxVolume(this.value);
}
