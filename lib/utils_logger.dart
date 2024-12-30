import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class MyPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    final tm = DateFormat('yy-MM-dd kk:mm:ss').format(event.time);
    final lvl = {
      Level.all: "ALL",
      Level.verbose: "VERBOSE", // ignore: deprecated_member_use
      Level.trace: "TRACE",
      Level.debug: "DEBUG",
      Level.info: "INFO",
      Level.warning: "WARN",
      Level.error: "ERROR",
      Level.wtf: "WTF", // ignore: deprecated_member_use
      Level.fatal: "FATAL",
      Level.nothing: "NOTHING", // ignore: deprecated_member_use
      Level.off: "OFF",
    }[event.level];
    final message = _stringifyMessage(event.message);
    final err = event.error;
    final trace = event.stackTrace;
    String msg = '$tm [$lvl] $message';
    if (err != null) {
      msg += ": $err";
    }
    List<String> resp = [msg];
    if (trace != null && trace != StackTrace.empty) {
      resp.add(trace.toString());
    }
    return resp;
  }

  String _stringifyMessage(dynamic message) {
    final finalMessage = message is Function ? message() : message;
    if (finalMessage is Map || finalMessage is Iterable) {
      var encoder = const JsonEncoder.withIndent(null);
      return encoder.convert(finalMessage);
    } else {
      return finalMessage.toString();
    }
  }
}

Logger getLogger() => Logger(
      level: Level.all,
      printer: MyPrinter(),
    );
