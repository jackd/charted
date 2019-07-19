//
// Copyright 2014 Google Inc. All rights reserved.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd
//

library charted.core.time_intervals;

class TimeInterval {
  final DateTime Function(DateTime) _floor;
  final DateTime Function(DateTime, int) _step;
  final int Function(DateTime) _number;

  TimeInterval(this._floor, this._step, this._number);

  DateTime floor(dynamic date) {
    assert(date is int || date is DateTime);
    if (date is int) {
      date = new DateTime.fromMillisecondsSinceEpoch(date as int);
    }
    return _floor(date as DateTime);
  }

  DateTime round(dynamic date) {
    DateTime d0 = floor(date), d1 = offset(d0, 1);
    int ms = date is int ? date : date.millisecondsSinceEpoch as int;
    return (ms - d0.millisecondsSinceEpoch < d1.millisecondsSinceEpoch - ms)
        ? d0
        : d1;
  }

  DateTime ceil(dynamic date) => offset(floor(date), 1);

  DateTime offset(DateTime date, int k) => _step(date, k);

  Iterable<DateTime> range(dynamic t0, dynamic t1, int dt) {
    assert(t0 is int || t0 is DateTime);
    assert(t1 is int || t1 is DateTime);

    List<DateTime> values = [];
    DateTime t1Date = t1 is DateTime
        ? t1
        : new DateTime.fromMillisecondsSinceEpoch(t1 as int);

    DateTime time = ceil(t0);
    if (dt > 1) {
      while (time.isBefore(t1Date)) {
        if ((_number(time) % dt) == 0) {
          values.add(new DateTime.fromMillisecondsSinceEpoch(
              time.millisecondsSinceEpoch));
        }
        time = _step(time, 1);
      }
    } else {
      while (time.isBefore(t1Date)) {
        values.add(new DateTime.fromMillisecondsSinceEpoch(
            time.millisecondsSinceEpoch));
        time = _step(time, 1);
      }
    }
    return values;
  }

  static final TimeInterval second = new TimeInterval(
      (DateTime date) => new DateTime.fromMillisecondsSinceEpoch(
          (date.millisecondsSinceEpoch ~/ 1000) * 1000),
      (DateTime date, int offset) => date =
          new DateTime.fromMillisecondsSinceEpoch(
              date.millisecondsSinceEpoch + offset * 1000),
      (DateTime date) => date.second);

  static final TimeInterval minute = new TimeInterval(
      (DateTime date) => new DateTime.fromMillisecondsSinceEpoch(
          (date.millisecondsSinceEpoch ~/ 60000) * 60000),
      (DateTime date, int offset) => date =
          new DateTime.fromMillisecondsSinceEpoch(
              date.millisecondsSinceEpoch + offset * 60000),
      (DateTime date) => date.minute);

  static final TimeInterval hour = new TimeInterval(
      (DateTime date) => new DateTime.fromMillisecondsSinceEpoch(
          (date.millisecondsSinceEpoch ~/ 3600000) * 3600000),
      (DateTime date, int offset) => date =
          new DateTime.fromMillisecondsSinceEpoch(
              date.millisecondsSinceEpoch + offset * 3600000),
      (DateTime date) => date.hour);

  static final TimeInterval day = new TimeInterval(
      (DateTime date) => new DateTime(date.year, date.month, date.day),
      (DateTime date, int offset) => new DateTime(
          date.year,
          date.month,
          date.day + offset,
          date.hour,
          date.minute,
          date.second,
          date.millisecond),
      (DateTime date) => date.day - 1);

  static final TimeInterval week = new TimeInterval(
      (DateTime date) =>
          new DateTime(date.year, date.month, date.day - (date.weekday % 7)),
      (DateTime date, int offset) => new DateTime(
          date.year,
          date.month,
          date.day + offset * 7,
          date.hour,
          date.minute,
          date.second,
          date.millisecond), (DateTime date) {
    var day = year.floor(date).day;
    return (dayOfYear(date) + day % 7) ~/ 7;
  });

  static final TimeInterval month = new TimeInterval(
      (DateTime date) => new DateTime(date.year, date.month, 1),
      (DateTime date, int offset) => new DateTime(
          date.year,
          date.month + offset,
          date.day,
          date.hour,
          date.minute,
          date.second,
          date.millisecond),
      (DateTime date) => date.month - 1);

  static final TimeInterval year = new TimeInterval(
      (DateTime date) => new DateTime(date.year),
      (DateTime date, int offset) => new DateTime(
          date.year + offset,
          date.month,
          date.day,
          date.hour,
          date.minute,
          date.second,
          date.millisecond),
      (DateTime date) => date.year);

  static int dayOfYear(DateTime date) =>
      date.difference(year.floor(date)).inDays;
}
