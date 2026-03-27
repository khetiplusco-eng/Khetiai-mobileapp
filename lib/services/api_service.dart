import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://agriintel-worker.vishwajeetadkine705.workers.dev';

  // ── Chat (Streaming SSE) ──────────────────────────────────────────────────

  /// Returns a Stream of text chunks from the AI assistant.
  static Stream<String> chatStream(String message, {String? context}) async* {
    final uri = Uri.parse('$baseUrl/api/chat');
    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({'message': message, 'context': context ?? ''});

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Chat API error: ${response.statusCode}');
    }

    final stream = response.stream.transform(utf8.decoder);
    String buffer = '';

    await for (final chunk in stream) {
      buffer += chunk;
      final lines = buffer.split('\n');
      buffer = lines.removeLast(); // keep incomplete line

      for (final line in lines) {
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6).trim();
        if (data == '[DONE]') return;
        try {
          final parsed = jsonDecode(data);
          final content =
              parsed['choices']?[0]?['delta']?['content'] as String?;
          if (content != null && content.isNotEmpty) yield content;
        } catch (_) {}
      }
    }
  }

  // ── Analyze (Disease Detection) ───────────────────────────────────────────

  static Future<String> analyzeImage({
    required String base64Image,
    required String mimeType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'base64Image': base64Image, 'mimeType': mimeType}),
    );
    if (response.statusCode != 200) {
      throw Exception('Analyze API error: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    return data['result'] as String? ?? 'No result';
  }

  // ── Market Forecast ───────────────────────────────────────────────────────

  static Future<MarketData> getMarketForecast(String crop) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/market'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'crop': crop}),
    );
    if (response.statusCode != 200) {
      throw Exception('Market API error: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    return MarketData.fromJson(data);
  }

  // ── Weather (Open-Meteo — free, no key) ──────────────────────────────────

  static Future<WeatherData> getWeather({
    double lat = 19.2666,
    double lon = 76.5750,
    String location = 'Parbhani, MH',
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,precipitation_probability,weather_code'
      '&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,weather_code'
      '&timezone=Asia/Kolkata&forecast_days=7',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Weather API error: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    return WeatherData.fromJson(data, location);
  }

  // ── Loan Eligibility (AI) ─────────────────────────────────────────────────

  static Stream<String> loanEligibilityStream({
    required String farmerName,
    required double landArea,
    required String cropType,
    required double annualIncome,
    required String loanPurpose,
    required int loanAmount,
    required bool hasKCC,
  }) {
    final message = '''
Assess loan eligibility for Indian farmer with these details:
- Name: $farmerName
- Land Area: $landArea acres
- Crop: $cropType
- Annual Income: ₹$annualIncome
- Loan Purpose: $loanPurpose
- Loan Amount Requested: ₹$loanAmount
- Has Kisan Credit Card: $hasKCC

Provide:
1. Eligibility assessment (Eligible/Partially Eligible/Not Eligible)
2. Recommended loan schemes (PM-KISAN, KCC, NABARD, etc.)
3. Interest rate range expected
4. Documents required
5. Tips to improve eligibility
Format clearly with sections.
''';
    return chatStream(message);
  }

  // ── Plant Recommendations (AI) ────────────────────────────────────────────

  static Stream<String> plantRecommendationsStream({
    required String soilType,
    required String season,
    required double rainfall,
    required String region,
    required String currentCrops,
  }) {
    final message = '''
Provide expert crop/plant recommendations for an Indian farmer:
- Soil Type: $soilType
- Season: $season
- Average Annual Rainfall: ${rainfall}mm
- Region: $region
- Currently Growing: $currentCrops

Give specific recommendations for:
1. Best crops to grow this season
2. High-value cash crops suitable
3. Intercropping suggestions
4. Seed variety recommendations
5. Expected yield and profit estimate per acre
Be practical and specific to Indian conditions.
''';
    return chatStream(message);
  }
}

// ── Data Models ───────────────────────────────────────────────────────────────

class MarketData {
  final double currentPrice;
  final String trend; // up | down | stable
  final List<MonthPrice> forecast;
  final String analysis;

  MarketData({
    required this.currentPrice,
    required this.trend,
    required this.forecast,
    required this.analysis,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0,
      trend: json['trend'] as String? ?? 'stable',
      forecast: (json['forecast'] as List<dynamic>? ?? [])
          .map((e) => MonthPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
      analysis: json['analysis'] as String? ?? '',
    );
  }
}

class MonthPrice {
  final String month;
  final double price;

  MonthPrice({required this.month, required this.price});

  factory MonthPrice.fromJson(Map<String, dynamic> json) {
    return MonthPrice(
      month: json['month'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}

class WeatherData {
  final String location;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final int precipitationProbability;
  final int weatherCode;
  final List<DailyWeather> daily;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.precipitationProbability,
    required this.weatherCode,
    required this.daily,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String location) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    return WeatherData(
      location: location,
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
      humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      precipitationProbability:
          (current['precipitation_probability'] as num?)?.toInt() ?? 0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      daily: List.generate(
        (daily['time'] as List).length,
        (i) => DailyWeather(
          date: daily['time'][i] as String,
          maxTemp: (daily['temperature_2m_max'][i] as num?)?.toDouble() ?? 0,
          minTemp: (daily['temperature_2m_min'][i] as num?)?.toDouble() ?? 0,
          precipitation:
              (daily['precipitation_sum'][i] as num?)?.toDouble() ?? 0,
          weatherCode: (daily['weather_code'][i] as num?)?.toInt() ?? 0,
        ),
      ),
    );
  }

  String get conditionText {
    if (weatherCode == 0) return 'Clear Sky';
    if (weatherCode <= 3) return 'Partly Cloudy';
    if (weatherCode <= 49) return 'Foggy';
    if (weatherCode <= 67) return 'Rainy';
    if (weatherCode <= 77) return 'Snow';
    if (weatherCode <= 82) return 'Rain Showers';
    if (weatherCode <= 99) return 'Thunderstorm';
    return 'Cloudy';
  }

  String get weatherIcon {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 49) return '🌫️';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 77) return '❄️';
    if (weatherCode <= 82) return '🌦️';
    if (weatherCode <= 99) return '⛈️';
    return '☁️';
  }
}

class DailyWeather {
  final String date;
  final double maxTemp;
  final double minTemp;
  final double precipitation;
  final int weatherCode;

  DailyWeather({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitation,
    required this.weatherCode,
  });

  String get icon {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 49) return '🌫️';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 82) return '🌦️';
    if (weatherCode <= 99) return '⛈️';
    return '☁️';
  }

  String get dayName {
    final parts = date.split('-');
    final dt = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  }
}
