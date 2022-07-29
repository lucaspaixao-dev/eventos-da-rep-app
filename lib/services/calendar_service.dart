import 'package:device_calendar/device_calendar.dart';
import 'package:eventos_da_rep/helpers/string_helper.dart';
// ignore: library_prefixes
import 'package:eventos_da_rep/models/event.dart' as appEvent;
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

class CalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  final String _calendar = 'Eventos da REP';

  Future<void> createCalendarOnAppCalendar(appEvent.Event event) async {
    try {
      bool isPermissionsGranted = await _isPermissionsGranted();

      if (!isPermissionsGranted) {
        return;
      }

      Calendar? appCalendar = await _getAppCalendar();
      late Event? calendarEvent;
      late String calendarId;

      if (appCalendar == null) {
        final Result<String> resultCalendarId =
            await _deviceCalendarPlugin.createCalendar(_calendar);

        if (!resultCalendarId.isSuccess) {
          return;
        }

        calendarId = resultCalendarId.data!;
      } else {
        calendarId = appCalendar.id!;
      }

      calendarEvent = await _createEvent(calendarId, event);

      if (calendarEvent != null) {
        _createEventOnAppCalendar(calendarEvent);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> deleteEventOnAppCalendar(appEvent.Event event) async {
    bool isPermissionsGranted = await _isPermissionsGranted();

    if (!isPermissionsGranted) {
      return;
    }

    Calendar? appCalendar = await _getAppCalendar();

    if (appCalendar != null) {
      var start = DateTime(event.date.year, event.date.month, event.date.day);

      var events = await _deviceCalendarPlugin.retrieveEvents(
        appCalendar.id,
        RetrieveEventsParams(
          startDate: start,
          endDate: start.add(
            const Duration(days: 1),
          ),
        ),
      );

      Event? calendarEvent;

      if (events.isSuccess && events.data != null) {
        for (var e in events.data!) {
          if (e.title == event.title) {
            calendarEvent = e;
            break;
          }
        }
      }

      if (calendarEvent != null) {
        await _deviceCalendarPlugin.deleteEvent(
          calendarEvent.calendarId,
          calendarEvent.eventId,
        );
      }
    }
  }

  Future<bool> _isPermissionsGranted() async {
    bool granted = true;

    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();

    if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        granted = false;
      }
    }

    return granted;
  }

  void _createEventOnAppCalendar(Event event) async {
    final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);

    debugPrint(result.toString());
  }

  Future<Event?> _createEvent(
    String calendarId,
    appEvent.Event event,
  ) async {
    var start = DateTime(event.date.year, event.date.month, event.date.day);

    var events = await _deviceCalendarPlugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(
        startDate: start,
        endDate: start.add(
          const Duration(days: 30),
        ),
      ),
    );

    Event? calendarEvent;

    if (!events.isSuccess) {
      throw Exception("Error to find event on calendar");
    }

    if (events.data != null) {
      for (var e in events.data!) {
        final String eventTitle = _buildStringComparatorFormat(e.title ?? "");
        final String eTitle = _buildStringComparatorFormat(event.title);

        if (eventTitle == eTitle) {
          calendarEvent = e;
          break;
        }
      }
    }

    if (calendarEvent == null) {
      var beginDate = await _getTimeZone(event.date, event.begin);
      var endDate = await _getTimeZone(event.date, event.end);

      var newCalendarEvent = Event(calendarId);
      newCalendarEvent.title = event.title;
      newCalendarEvent.description = event.description;
      newCalendarEvent.start = beginDate;
      newCalendarEvent.end = endDate;
      newCalendarEvent.location = buildAddressResume(event);
      newCalendarEvent.availability = Availability.Busy;
      newCalendarEvent.reminders = [
        Reminder(
          minutes: 60,
        ),
      ];
      return newCalendarEvent;
    }

    return null;
  }

  Future<Calendar?> _getAppCalendar() async {
    var calendars = await _deviceCalendarPlugin.retrieveCalendars();

    if (!calendars.isSuccess) {
      throw Exception("Error retrieving calendars");
    }

    if (calendars.data == null) {
      return null;
    }

    for (var calendar in calendars.data!) {
      final String appCalendarName = _buildStringComparatorFormat(_calendar);

      final String calendarName =
          _buildStringComparatorFormat(calendar.name ?? "");

      if (calendarName == appCalendarName) {
        return calendar;
      }
    }

    return null;
  }

  Future<tz.TZDateTime> _getTimeZone(DateTime date, DateTime time) async {
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();

    var zone = tz.getLocation(currentTimeZone);

    var newDay = _checkIsMidnightAndGetNewDay(date, time);

    var newDate = DateTime(
      date.year,
      date.month,
      newDay,
      time.hour,
      time.minute,
      time.second,
    );

    return tz.TZDateTime.from(newDate, zone);
  }

  int _checkIsMidnightAndGetNewDay(DateTime date, DateTime time) {
    late int newDay;

    if (time.hour == 00 || time.hour == 0) {
      var t = date.add(const Duration(days: 1));
      newDay = t.day;
    } else {
      newDay = date.day;
    }

    return newDay;
  }

  String _buildStringComparatorFormat(String stringToFormat) =>
      stringToFormat.trim().toUpperCase();
}
