// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "package:flare_flutter/flare_actor.dart";

enum _Element {
  background,
  text,
  shadow,
  border,
  borderinner,
  innerbox,
  woodcolor1,
  woodcolor2
}

final _lightTheme = {
  _Element.background: Color(0xFFD7D7CD),
  _Element.text: Colors.black87.withOpacity(0.5),
  _Element.shadow: Colors.black,
  _Element.border: Colors.brown,
  _Element.borderinner: Colors.grey,
  _Element.innerbox: Colors.blueGrey[500],
  _Element.woodcolor1: Colors.brown[400],
  _Element.woodcolor2: Colors.brown[600]
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white.withOpacity(0.5),
  _Element.shadow: Color(0xFF174EA6),
  _Element.border: Colors.brown,
  _Element.borderinner: Colors.grey,
  _Element.innerbox: Colors.grey[500].withOpacity(0.1),
  _Element.woodcolor1: Colors.brown[400],
  _Element.woodcolor2: Colors.brown[600]
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);
  final ClockModel model;
  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  var _temperature = '';
  var _unitstring = '';
  var _weatherCondition = '';

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperature.toString();
      _unitstring = widget.model.unitString;
      _weatherCondition = widget.model.weatherString;

      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaquerydata = MediaQuery.of(context);
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final day = DateFormat('EEEE').format(_dateTime).substring(0, 3);
    final timeStr = '$hour:$minute';
  
    final screenHeight = mediaquerydata.size.height;
    final screenWidth = mediaquerydata.size.width;

    final paddingval = mediaquerydata.orientation == Orientation.landscape
        ? screenHeight / 22
        : screenWidth / 28;

    final fontSize = mediaquerydata.size.width / 14;
    final fontSizeTemp = mediaquerydata.size.width / 24;

    final timeBoxDim = screenWidth / 3.2;
    final tempBoxDim = screenWidth / 4.8;

    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Wallpoet',
      fontSize: fontSize,
    );

    final tempTextStyle = TextStyle(
        color: colors[_Element.text],
        fontFamily: 'Wallpoet',
        fontSize: fontSizeTemp,
        fontWeight: FontWeight.bold);

    final woodGradientVertical = LinearGradient(
        colors: [colors[_Element.woodcolor2], colors[_Element.woodcolor1]],
        begin: Alignment.centerRight,
        end: new Alignment(0.7, 0),
        tileMode: TileMode.repeated);

    final woodGradientHorizontal = LinearGradient(
        colors: [colors[_Element.woodcolor2], colors[_Element.woodcolor1]],
        begin: Alignment.center,
        end: new Alignment(0, 0.6),
        tileMode: TileMode.repeated);

    final tempGradient = LinearGradient(
        colors: [Colors.white10, Colors.blueGrey.withOpacity(0.9)],
        begin: Alignment.topRight,
        end: new Alignment(0.8, 0),
        tileMode: TileMode.mirror);

    final timeGradient = LinearGradient(
        colors: [Colors.white10, Colors.blueGrey],
        begin: Alignment.bottomRight,
        end: new Alignment(0.7, 0.1),
        tileMode: TileMode.mirror);

    return Container(
      decoration: BoxDecoration(
        color: colors[_Element.border],
        gradient: woodGradientHorizontal,
      ),
      child: Container(
        padding: EdgeInsets.only(top: paddingval, bottom: paddingval),
        margin: EdgeInsets.only(left: paddingval, right: paddingval),
        decoration: BoxDecoration(
          color: colors[_Element.border],
          gradient: woodGradientVertical,
        ),
        child: Container(
          color: colors[_Element.background],
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      colors[_Element.innerbox].withOpacity(0.5),
                      colors[_Element.background].withOpacity(0.5)
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment(0.5, 0.1),
                    tileMode: TileMode.mirror),
                color: colors[_Element.background],
                border:
                    Border.all(color: colors[_Element.borderinner], width: 2)),
            padding: EdgeInsets.all(5),
            child: Stack(
              children: <Widget>[
                Positioned(
                    top: tempBoxDim + 10,
                    left: 25,
                    child: Opacity(
                      opacity: 0.9,
                      child: Container(
                        height: tempBoxDim,
                        width: tempBoxDim,
                        child: FlareActor(
                          'animations/$_weatherCondition.flr',
                          animation: "occli",
                        ),
                      ),
                    )),

                Positioned(
                  // top: 5,
                  left: 5,                  
                  child: buildInnerBox(
                    _temperature,
                    Text(_unitstring),
                    tempBoxDim,
                    tempBoxDim,
                    colors[_Element.innerbox],
                    tempTextStyle,
                    tempGradient,
                  ),
                ),
                
                Positioned(
                  right: 5,
                  child: buildInnerBox(
                      timeStr,
                      Text(day),
                      timeBoxDim,
                      timeBoxDim,
                      colors[_Element.innerbox],
                      defaultStyle,
                      timeGradient),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInnerBox(
      String text,
      Widget belowWidget,
      double innerBoxWidth,
      double innerBoxHeight,
      Color innerboxcolor,
      TextStyle txtstyle,
      LinearGradient custgradient) {
    return DefaultTextStyle(
      style: txtstyle,
      child: Container(
        padding: EdgeInsets.all(innerBoxWidth / 11.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(innerBoxWidth),
          border: Border.all(
            width: 6,
            color: Colors.grey[400],
          ),
          gradient: custgradient,
        ),
        child: Container(
            width: innerBoxWidth,
            height: innerBoxHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(innerBoxWidth),
              color: innerboxcolor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.8),
                  spreadRadius: (innerBoxWidth / 20),
                  blurRadius: (innerBoxWidth / 20),
                  offset: Offset(4, 3),
                ),
              ],
              border: Border.all(
                width: 2,
                color: Colors.black38.withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Text(text), Divider(), belowWidget],
            )),
      ),
    );
  }
}
