import 'dart:convert';

//import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class RunPersistenceHandler {
  FileManager manager;
  List<Map<String, dynamic>> runs;
  bool loaded = false;
  RunPersistenceHandler({filename: "runs.json"}) {
    manager = FileManager(filename);
  }

  Future<List<Map<String, dynamic>>> getStoredRuns() async {
    return Future.delayed(Duration(seconds: 1), () async {
      if (!loaded) {
        await manager.init();
        loaded = true;
      }
      String json = await manager.read();
      if (json == null || json == "") return [];
      Map<String, dynamic> jsonMap = jsonDecode(json);
      runs = RunPersistenceHandler.fromJson(jsonMap);
      return runs;
    });
  }

  Future<File> storeRuns(List<Map<String, dynamic>> runs) async {
    if (!loaded) {
      await manager.init();
      loaded = true;
    }
    this.runs = runs;
    return manager.write(await toJson());
  }

  static List<Map<String, dynamic>> fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    int length = json["length"];
    List<Map<String, dynamic>> res = new List<Map<String, dynamic>>();
    for (var i = 0; i < length; ++i) {
      res.add({
        "time": Duration(microseconds: json["run$i"]["time"]),
        "distance": json["run$i"]["distance"],
        "aqis": ((json["run$i"]["aqis"] ?? []) as List).cast<double>().toList(),
        "measurementsDistances":
            ((json["run$i"]["measurementsDistances"] ?? []) as List)
                .cast<double>()
                .toList(),
        "waitingLastPosition": Future.value(null),
        "lastPosition": json["run$i"]["lastPosition"] ?? "",
        "waitingStartPosition": Future.value(null),
        "startPosition": json["run$i"]["startPosition"] ?? "",
        "startTime": (json["run$i"]["startTime"] as String) ?? "",
      });
    }
    return res;
  }

  dynamic toJson() async {
    Map<String, dynamic> jsonMap = {};
    jsonMap["length"] = runs.length;
    for (var i = 0; i < runs.length; ++i) {
      await Future.wait([
        runs[i]["waitingStartPosition"] as Future<dynamic> ??
            Future.value(null),
        runs[i]["waitingLastPosition"] as Future<dynamic> ?? Future.value(null)
      ]);
      jsonMap["run$i"] = {
        "time": runs[i]["time"]?.inMicroseconds ?? 0,
        "aqis": runs[i]["aqis"] ?? [],
        "distance": runs[i]["distance"] ?? 0.0,
        "lastPosition": runs[i]["lastPosition"] ?? "",
        "measurementsDistances": runs[i]["measurementsDistances"] ?? [],
        "startPosition": runs[i]["startPosition"] ?? "",
        "startTime": runs[i]["startTime"] ?? "",
      };
    }
    //print(jsonMap);
    return jsonMap;
  }
}

class FileManager {
  Future<Directory> directory;
  String filename;
  Future<File> file;
  FileManager(this.filename) {
    directory = getApplicationDocumentsDirectory();
  }

  init() async {
    Directory path = await directory;
    file = loadFile(path);
    return file;
  }

  Future<File> loadFile(Directory path) async {
    //print('$path/'.replaceAll("'", "").split(" ")[1] + filename);
    return file ?? File('$path/'.replaceAll("'", "").split(" ")[1] + filename);
  }

  Future<File> write(Map<String, dynamic> json) async {
    file = _writeJson(json);
    //file.then((value) => print(value.readAsStringSync()));
    return file;
  }

  Future<File> _writeJson(Map<String, dynamic> json) async {
    File currentFile = await this.file;
    return currentFile.writeAsString(jsonEncode(json));
  }

  Future<String> read() async {
    try {
      File currentFile = await this.file;
      Future<String> content =
          (await currentFile.exists()) ? currentFile?.readAsString() : null;
      return content;
    } catch (e) {
      print("exception caught:$e");
      return null;
    }
  }
}
