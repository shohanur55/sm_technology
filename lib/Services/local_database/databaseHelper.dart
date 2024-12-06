import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sm_technology/model/api_model/jsonPlacerListResponseModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sm_technology/model/api_model/weather_data_hourly_model.dart';
import 'package:sm_technology/model/api_model/weather_data_daily_model.dart';
import 'package:sm_technology/model/api_model/weather_data_hourly_model.dart'
    as hourly_model;
import 'package:sm_technology/model/api_model/weather_data_daily_model.dart'
    as daily_model;
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
    CREATE TABLE WeatherDataHourly (
        id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique identifier for each record
        dt INTEGER,                          -- Unix timestamp
        temp REAL                         -- Temperature (rounded)
    );
''');
    await db.execute('''
    CREATE TABLE Weather (
        id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique identifier for each record
        weather_data_hourly_id INTEGER,       -- Links to WeatherDataHourly.id
        weather_id INTEGER,                   -- ID from the weather API
        main TEXT,                            -- Weather main info (e.g., Clear, Rain)
    description TEXT,                     -- Weather description (e.g., light rain)
    icon TEXT,                            -- Icon code (e.g., 10d)
    FOREIGN KEY (weather_data_hourly_id) REFERENCES WeatherDataHourly(id)
    );
''');

    await db.execute('''
CREATE TABLE WeatherDataDaily(
  id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique identifier for each record
  dt INTEGER                          -- Unix timestamp
)
''');
    await db.execute('''
    CREATE TABLE Weatherdaily(
        id INTEGER PRIMARY KEY AUTOINCREMENT, -- Unique identifier for each record
        weather_data_daily_id INTEGER,       -- Links to WeatherDataHourly.id
        weather_id INTEGER,                   -- ID from the weather API
        main TEXT,                            -- Weather main info (e.g., Clear, Rain)
    description TEXT,                     -- Weather description (e.g., light rain)
    icon TEXT,                            -- Icon code (e.g., 10d)
    FOREIGN KEY (weather_data_daily_id) REFERENCES WeatherDataDaily(id)
    );
''');
    await db.execute('''
      CREATE TABLE Tempdaily(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day REAL,
        min INTEGER,
        max INTEGER,
        night REAL,
        eve REAL,
        morn REAL,
        daily_dt INTEGER,
        FOREIGN KEY (daily_dt) REFERENCES WeatherDataDaily(id)
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

// Insert WeatherDataHourly
    for (var hourlyData in model.hourly!.hourly) {
      final weatherDataHourlyId = await db.insert(
        'WeatherDataHourly',
        {
          'dt': hourlyData.dt,
          'temp': hourlyData.temp,
        },
      );

      // Insert Weather details
      if (hourlyData.weather != null) {
        for (final weather in hourlyData.weather!) {
          await db.insert(
            'Weather',
            {
              'weather_data_hourly_id': weatherDataHourlyId,
              'weather_id': weather.id,
              'main': weather.main,
              'description': weather.description,
              'icon': weather.icon,
            },
          );
        }
      }
    }

    // Insert WeatherDataDaily
    for (var dailyData in model.daily!.daily) {
      final weatherDataDailyId = await db.insert(
        'WeatherDataDaily',
        {
          'dt': dailyData.dt,
        },
      );

      // Insert Weather details
      if (dailyData.weather != null) {
        for (final weather in dailyData.weather!) {
          await db.insert(
            'Weatherdaily',
            {
              'weather_data_daily_id': weatherDataDailyId,
              'weather_id': weather.id,
              'main': weather.main,
              'description': weather.description,
              'icon': weather.icon,
            },
          );
        }
      }
      if (dailyData.temp != null) {
        await db.insert(
          'Tempdaily',
          {
            'day': dailyData.temp!.day,
            'min': dailyData.temp!.min,
            'max': dailyData.temp!.max,
            'night': dailyData.temp!.night,
            'eve': dailyData.temp!.eve,
            'morn': dailyData.temp!.morn,
          },
        );
      }
    }
  }

  Future<WeatherDataModel> getWeatherData() async {
    try {
      final db = await database;

      // Retrieve current weather data
      final List<Map<String, dynamic>> currentWeatherData =
          await db.query('WeatherDataCurrent');

      if (currentWeatherData.isEmpty || currentWeatherData.first == null) {
        throw Exception('No current weather data found.');
      }

      // Make a mutable copy of the first item
      Map<String, dynamic> mutableData =
          Map<String, dynamic>.from(currentWeatherData.first);

      // Debug: Print mutableData to inspect its structure
      print('Mutable Data: $mutableData');

      // Add a 'current' key to match the expected JSON structure
      Map<String, dynamic> wrappedData = {
        'current': mutableData,
      };

      // Decode the 'weather' field if it's a string
      if (wrappedData['current']['weather'] is String) {
        wrappedData['current']['weather'] =
            jsonDecode(wrappedData['current']['weather']);
      }

      // Debug: Ensure weather is parsed correctly
      print('Decoded Weather: ${wrappedData['current']['weather']}');

      // Create the model from the modified data
      var currentModel = WeatherDataCurrentModel.fromJson(wrappedData);

      WeatherDataHourlyModel? hourlyModel = await fetchHourlyWeatherData();
      WeatherDataDailyModel? dailyModel = await fetchDailyWeatherData();

      // Return the weather data model
      return WeatherDataModel(currentModel, hourlyModel, dailyModel);
    } catch (e) {
      // Handle any errors during the data fetching process
      throw Exception('Error fetching weather data: $e');
    }
  }

  Future<WeatherDataHourlyModel?> fetchHourlyWeatherData() async {
    final db = await database;
// Fetch WeatherDataHourly data
    final weatherDataHourlyList = await db.query('WeatherDataHourly');

    // Map the results to a list of `Hourly` models
    List<Hourly> hourlyList = [];
    for (var hourlyData in weatherDataHourlyList) {
      // Fetch the weather details for each hourly data
      final weatherDetails = await db.query(
        'Weather',
        where: 'weather_data_hourly_id = ?',
        whereArgs: [hourlyData['id']],
      );

      // Map weather data into `Weather` objects
      List<hourly_model.Weather> weatherList =
          weatherDetails.map((weatherData) {
        return hourly_model.Weather(
          id: weatherData['weather_id'] as int?,
          main: weatherData['main'] as String?,
          description: weatherData['description'] as String?,
          icon: weatherData['icon'] as String?,
        );
      }).toList();

      // Create `Hourly` objects and add them to the list
      hourlyList.add(Hourly(
        dt: hourlyData['dt'] as int,
        temp: hourlyData['temp'] as double,
        weather: weatherList,
      ));
    }
    // Return the `WeatherDataHourlyModel` with the list of hourly data
    return WeatherDataHourlyModel(hourly: hourlyList);
  }

  Future<WeatherDataDailyModel?> fetchDailyWeatherData() async {
    final db = await database;
// Fetch WeatherDataHourly data
    final weatherDataDailyList = await db.query('WeatherDataDaily');

    // Map the results to a list of `Hourly` models
    List<Daily> dailyList = [];
    for (var dailyData in weatherDataDailyList) {
      // Fetch the weather details for each hourly data
      final weatherDetails = await db.query(
        'Weatherdaily',
        where: 'weather_data_daily_id = ?',
        whereArgs: [dailyData['id']],
      );

      final tempDetails = await db.query(
        'Tempdaily',
        where: 'daily_dt = ?',
        whereArgs: [dailyData['id']],
      );

      // Map weather data into `Weather` objects
      List<daily_model.Weather> weatherList = weatherDetails.map((weatherData) {
        return daily_model.Weather(
          id: weatherData['weather_id'] as int?,
          main: weatherData['main'] as String?,
          description: weatherData['description'] as String?,
          icon: weatherData['icon'] as String?,
        );
      }).toList();

      daily_model.Temp? temp;
      if (tempDetails.isNotEmpty) {
        final tempData =
            tempDetails.first; // Get the first row from the query result
        temp = daily_model.Temp(
          day: (tempData['day'] as num).toDouble(),
          min: (tempData['min'] as num).round(),
          max: (tempData['max'] as num).round(),
          night: (tempData['night'] as num).toDouble(),
          eve: (tempData['eve'] as num).toDouble(),
          morn: (tempData['morn'] as num).toDouble(),
        );
      } else {
        temp = null; // Handle cases where no temperature data exists
      }

      // Create `Hourly` objects and add them to the list
      dailyList.add(Daily(
        dt: dailyData['dt'] as int,
        temp: temp,
        weather: weatherList,
      ));
    }
    // Return the `WeatherDataHourlyModel` with the list of hourly data
    return WeatherDataDailyModel(daily: dailyList);
  }

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

  Future<void> deleteWeatherLocalData() async {
    final db = await database;

    final tableCheck1 = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='JsonPlacerList'");

    if (tableCheck1.isNotEmpty) {
      await db.delete('JsonPlacerList');
      DevMode.devPrint("tableCheck1 are deleted from database");
    }

    final tableCheck2 = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='Tempdaily'");

    if (tableCheck2.isNotEmpty) {
      await db.delete('Tempdaily');
      DevMode.devPrint("tableCheck2 are deleted from database");
    }
    final tableCheck3 = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='Weather'");

    if (tableCheck3.isNotEmpty) {
      await db.delete('Weather');
      DevMode.devPrint("tableCheck3 are deleted from database");
    }
    final tableCheck4 = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='WeatherDataCurrent'");

    if (tableCheck4.isNotEmpty) {
      await db.delete('WeatherDataCurrent');
      DevMode.devPrint("tableCheck4 are deleted from database");
    }
    final tableCheck5 = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='WeatherDataDaily'");

    if (tableCheck5.isNotEmpty) {
      await db.delete('WeatherDataDaily');
      DevMode.devPrint("tableCheck5 are deleted from database");
    }
    final tableCheck6 = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='WeatherDataHourly'");

    if (tableCheck6.isNotEmpty) {
      await db.delete('WeatherDataHourly');
      DevMode.devPrint("tableCheck6 are deleted from database");
    }
    final tableCheck7 = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='Weatherdaily'");

    if (tableCheck7.isNotEmpty) {
      await db.delete('Weatherdaily');
      DevMode.devPrint("tableCheck7 are deleted from database");
    }
  }
}
