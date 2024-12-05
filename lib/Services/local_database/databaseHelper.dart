import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sm_technology/model/api_model/jsonPlacerListResponseModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sm_technology/model/api_model/weather_data_hourly_model.dart' as hourly_model;

import '../../model/api_model/weather_data_current_model.dart';
import '../../model/api_model/weather_data_daily_model.dart';
import '../../model/api_model/weather_data_hourly_model.dart';
import '../../model/api_model/weather_data_model.dart';
import '../user_message/devMode.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE JsonPlacerList(
    userId INTEGER,
    id INTEGER PRIMARY KEY,
    title TEXT,
    body TEXT
)
  ''');
    DevMode.devPrint("json data base create");

    await db.execute('''
CREATE TABLE IF NOT EXISTS WeatherDataCurrent(
  id INTEGER PRIMARY KEY,
  temp INTEGER,
  feels_like REAL,
  humidity INTEGER,
  uvi REAL,  -- Add this line for the uvIndex
  clouds INTEGER,
  wind_speed REAL,
  weather TEXT
)
''');

    await db.execute('''
CREATE TABLE WeatherDataHourly(
  id INTEGER PRIMARY KEY,
  dt INTEGER,
  temp INTEGER,
  weather TEXT
)
''');

    await db.execute('''
CREATE TABLE WeatherDataDaily(
  id INTEGER PRIMARY KEY,
  dt INTEGER,
  temp_day REAL,
  temp_min INTEGER,
  temp_max INTEGER,
  temp_night REAL,
  temp_eve REAL,
  temp_morn REAL,
  weather TEXT
)
''');

    DevMode.devPrint("Weather Database created");
  }

  Future close() async => _database!.close();

  // Import for JSON encoding/decoding

  Future<void> insertWeatherData(WeatherDataModel model) async {
    final db = await database;

    // Serialize the 'weather' field to a JSON string before insertion
    String weatherJson = jsonEncode(model.current!.current.weather);

    // Insert current weather data
    await db.insert(
      'WeatherDataCurrent',
      {
        'temp': model.current!.current.temp,
        'feels_like': model.current!.current.feelsLike,
        'uvi': model.current!.current.uvIndex,
        'humidity': model.current!.current.humidity,
        'clouds': model.current!.current.clouds,
        'wind_speed': model.current!.current.windSpeed,
        'weather': weatherJson, // Store the serialized JSON string
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert hourly weather data
    for (var hourlyData in model.hourly!.hourly) {
      await db.insert(
        'WeatherDataHourly',
        {
          'dt': hourlyData.dt,
          'temp': hourlyData.temp,
          'weather':
              jsonEncode(hourlyData.weather), // Serialize hourly weather data
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Insert daily weather data
    for (var dailyData in model.daily!.daily) {
      await db.insert(
        'WeatherDataDaily',
        {
          'dt': dailyData.dt,
          'temp_day': dailyData.temp?.day,
          'temp_min': dailyData.temp?.min,
          'temp_max': dailyData.temp?.max,
          'temp_night': dailyData.temp?.night,
          'temp_eve': dailyData.temp?.eve,
          'temp_morn': dailyData.temp?.morn,
          'weather':
              jsonEncode(dailyData.weather), // Serialize daily weather data
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

//   Future<WeatherDataModel> getWeatherData() async {
//     try {
//       final db = await database;
//
//       // Retrieve current weather data
//       final List<Map<String, dynamic>> currentWeatherData =
//           await db.query('WeatherDataCurrent');
//
//       if (currentWeatherData.isEmpty || currentWeatherData.first == null) {
//         throw Exception('No current weather data found.');
//       }
//
//       // Make a mutable copy of the first item
//       Map<String, dynamic> mutableData =
//           Map<String, dynamic>.from(currentWeatherData.first);
//
//       // Debug: Print mutableData to inspect its structure
//       print('Mutable Data: $mutableData');
//
//       // Add a 'current' key to match the expected JSON structure
//       Map<String, dynamic> wrappedData = {
//         'current': mutableData,
//       };
//
//       // Decode the 'weather' field if it's a string
//       if (wrappedData['current']['weather'] is String) {
//         wrappedData['current']['weather'] =
//             jsonDecode(wrappedData['current']['weather']);
//       }
//
//       // Debug: Ensure weather is parsed correctly
//       print('Decoded Weather: ${wrappedData['current']['weather']}');
//
//       // Create the model from the modified data
//       var currentModel = WeatherDataCurrentModel.fromJson(wrappedData);
//
//      // Make sure to import the required libraries
// // Assuming you're using a SQLite database for the query
//       final List<Map<String, dynamic>> hourlyWeatherData = await db.query('WeatherDataHourly');
//
//       if (hourlyWeatherData.isEmpty || hourlyWeatherData.first == null) {
//         throw Exception('No hourly weather data found.');
//       }
//
// // Create a mutable copy of the list and modify it if needed
//       List<Map<String, dynamic>> mutableHourlyData = hourlyWeatherData.map((e) => Map<String, dynamic>.from(e)).toList();
//
//       List<hourly_model.Hourly> hourlyList = [];
//
//       for (var data in mutableHourlyData) {
//         hourly_model.Hourly hourly = hourly_model.Hourly(
//           dt: data['dt'] as int?,
//           temp: data['temp'] as int?,
//           weather: data['weather'] != null
//               ? List<hourly_model.Weather>.from(
//               (json.decode(data['weather'] as String) as List)
//                   .map((e) => hourly_model.Weather.fromJson(e as Map<String, dynamic>)))
//               : null,
//         );
//
//         hourlyList.add(hourly);
//       }
//       hourly_model.WeatherDataHourlyModel hourlyModel = hourly_model.WeatherDataHourlyModel(hourlyData: hourlyList);
//       final List<Map<String, dynamic>> dailyWeatherData =
//           await db.query('WeatherDataDaily');
//       if (dailyWeatherData.isEmpty || dailyWeatherData.first == null) {
//         throw Exception('No daily weather data found.');
//       }
//       var dailyModel = WeatherDataDailyModel.fromJson(
//           {'daily': dailyWeatherData.map((e) => Daily.fromJson(e)).toList()});
//
//       // Return the weather data model
//       return WeatherDataModel(currentModel, hourlyList, dailyModel);
//     } catch (e) {
//       // Handle any errors during the data fetching process
//       throw Exception('Error fetching weather data: $e');
//     }
//   }

  // Insert function for SalesPipeLineCategoryTypeModel
  Future<int> insertJsonPlacerList(JsonPlacerListModel model) async {
    final db = await database;

    return await db.insert(
      'JsonPlacerList',
      model.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve data from local
  Future<List<JsonPlacerListModel>> getJsonPlacerLocalDatabaseData() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('JsonPlacerList');

    return List.generate(maps.length, (i) {
      return JsonPlacerListModel.fromJson(maps[i]);
    });
  }

  Future<int> deleteLocalData() async {
    final db = await database;

    final tableCheck = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='JsonPlacerList'");

    if (tableCheck.isNotEmpty) {
      return await db.delete('JsonPlacerList');
    } else {
      return 0;
    }
  }
}
