import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info.dart';
import 'package:weather_app/forecast_info.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  // API CALL
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?lat=40.40&lon=49.86&appid=$weatherApiKey'),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'There is an error!!!';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  // InitState
  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

// Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar (name & refresh button)
      appBar: AppBar(
        title: const Text(
          'WeatherApp',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => {
              setState(
                () {
                  weather = getCurrentWeather();
                },
              ),
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      //Body (3 cards - current weather, forecast, additional)
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          // Loading Indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          // Error Message
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 32,
                ),
              ),
            );
          }

          // Data
          final data = snapshot.data!;
          final currentTemp = (data['list'][0]['main']['temp'] - 273 as double)
              .toStringAsFixed(1);
          final currentWeatherType = data['list'][0]['weather'][0]['main'];
          final currentPressure = data['list'][0]['main']['pressure'];
          final currentHumidity = data['list'][0]['main']['humidity'];
          final currentWind = data['list'][0]['wind']['speed'];

          return Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upper Card (degree, icon, description)
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Degree
                              Text(
                                '$currentTemp°C',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 25),

                              // Icon
                              Icon(
                                currentWeatherType == 'Clouds' ||
                                        currentWeatherType == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              const SizedBox(height: 25),

                              // Description
                              Text(
                                '$currentWeatherType',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Weather forecast Card - (Middle Card)

                // Text Part
                const Text(
                  'Weather Forecast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Scroll Part

                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 1; i <= 10; i++)
                //         HourlyForecastItem(
                //           hour: data['list'][i]['dt_txt'],
                //           icon: data['list'][i]['weather'][0]['main'] ==
                //                       'Clouds' ||
                //                   data['list'][i]['weather'][0]['main'] ==
                //                       'Rain'
                //               ? Icons.cloud
                //               : Icons.sunny,
                //           degree: data['list'][i]['main']['temp'].toString(),
                //         ),
                //     ],
                //   ),
                // ),

                SizedBox(
                  height: 130,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    separatorBuilder: (context, index) {
                      return VerticalDivider();
                    },
                    itemBuilder: (context, index) {
                      final hourlyWeather = data['list'][index + 1];
                      final dateTime = DateTime.parse(hourlyWeather['dt_txt']);
                      final hourlySky =
                          data['list'][index + 1]['weather'][0]['main'];
                      return HourlyForecastItem(
                        icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny,
                        hour: DateFormat.Hm().format(dateTime),
                        degree: hourlyWeather['main']['temp'].toString(),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Lover card

                // Text Part
                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Additional Part
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfo(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      num: '$currentHumidity',
                    ),
                    AdditionalInfo(
                      icon: Icons.air,
                      label: 'Wind Spped',
                      num: '$currentWind',
                    ),
                    AdditionalInfo(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      num: '$currentPressure',
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
