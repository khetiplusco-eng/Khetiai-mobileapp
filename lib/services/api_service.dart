import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://agriintel-worker.vishwajeetadkine705.workers.dev';

  // ── Chat (Streaming SSE) ──────────────────────────────────────────────────

  static Stream<String> chatStream(
    String message, {
    String? context,
    String? language,
    String? mode,
    String? district,
    String? state,
    String country = 'India',
  }) async* {
    final uri = Uri.parse('$baseUrl/api/chat');
    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'message': message,
        'context': context ?? '',
        'language': language ?? 'en',
        'mode': mode,
        'district': district,
        'state': state,
        'country': country,
      });

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Chat API error: ${response.statusCode}');
    }

    final stream = response.stream.transform(utf8.decoder);
    String buffer = '';

    await for (final chunk in stream) {
      buffer += chunk;
      final lines = buffer.split('\n');
      buffer = lines.removeLast();

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

  static Future<Map<String, dynamic>> analyzeImage({
    required String base64Image,
    required String mimeType,
    String? crop,
    String? district,
    String? state,
    String country = 'India',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'base64Image': base64Image,
        'mimeType': mimeType,
        'crop': crop,
        'district': district,
        'state': state,
        'country': country,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Analyze API error: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data;
  }

  // ── Market (with full analyst agent) ────────────────────────────────────

  static Future<MarketData> getMarketForecast(
    String crop, {
    String? district,
    String? state,
    String country = 'India',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/market'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'crop': crop,
        'district': district ?? 'Akola',
        'state': state ?? 'Maharashtra',
        'country': country,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Market API error: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return MarketData.fromJson(data);
  }

  // ── Multi-Agent Pipeline ──────────────────────────────────────────────────

  static Future<Map<String, dynamic>> runMultiAgent({
    required String crop,
    String? soil,
    String? district,
    String? state,
    String country = 'India',
    String? season,
    double? rainfall,
    double? temperature,
    String? objective,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/multiagent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'crop': crop,
        'soil': soil,
        'district': district ?? 'Akola',
        'state': state ?? 'Maharashtra',
        'country': country,
        'season': season,
        'rainfall': rainfall,
        'temperature': temperature,
        'objective': objective,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Multi-agent API error: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ── Recommendations ──────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getRecommendations({
    required String soilType,
    String? season,
    double? rainfall,
    String? district,
    String? state,
    String country = 'India',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/recommendations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'soilType': soilType,
        'season': season,
        'rainfall': rainfall,
        'district': district ?? 'Akola',
        'state': state ?? 'Maharashtra',
        'country': country,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Recommendations API error: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ── Soil Analysis ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> analyzeSoil({
    required Map<String, dynamic> soilData,
    String? crop,
    String? season,
    String? district,
    String? state,
    String country = 'India',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/soil'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'soilData': soilData,
        'crop': crop,
        'season': season,
        'district': district ?? 'Akola',
        'state': state ?? 'Maharashtra',
        'country': country,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Soil API error: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ── News Feed ─────────────────────────────────────────────────────────────

  static Future<List<NewsItem>> getAgriNews({
    String? crop,
    String? district,
    String? state,
    String country = 'India',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/serper/news'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'crop': crop,
        'topic': 'agriculture farming India',
        'district': district ?? 'Akola',
        'state': state ?? 'Maharashtra',
        'country': country,
      }),
    );
    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final news = (data['news'] as List<dynamic>? ?? []);
    return news.map((n) => NewsItem.fromJson(n as Map<String, dynamic>)).toList();
  }

  // ── Weather (Open-Meteo) ───────────────────────────────────────────────────

  static Future<WeatherData> getWeather({
    double lat = 20.7002,
    double lon = 77.0082,
    String location = 'Akola, MH',
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
    return WeatherData.fromJson(jsonDecode(response.body), location);
  }

  // ── Loan Eligibility ──────────────────────────────────────────────────────

  static Stream<String> loanEligibilityStream({
    required String farmerName,
    required double landArea,
    required String cropType,
    required double annualIncome,
    required String loanPurpose,
    required int loanAmount,
    required bool hasKCC,
    String district = 'Akola',
    String state = 'Maharashtra',
  }) {
    final message = '''
Assess agricultural loan eligibility for an Indian farmer with these details:
- Name: $farmerName
- Land Area: $landArea acres
- Main Crop: $cropType  
- Annual Farm Income: ₹$annualIncome
- Loan Purpose: $loanPurpose
- Loan Amount Required: ₹$loanAmount
- Has Kisan Credit Card: $hasKCC
- Location: $district, $state

Provide a clear, structured assessment:
1. **Eligibility Verdict** (Eligible / Partially Eligible / Not Eligible) with primary reason
2. **Best Matching Schemes** — KCC, PM-KISAN, NABARD, etc. with interest rates
3. **Loan Amount Feasibility** — against income and land
4. **Documents Required** — list all needed docs
5. **Tips to Improve Eligibility** — 2-3 specific actionable steps
6. **Expected Processing Time** — realistic timeline

Use ₹ for all amounts. Keep it practical and farmer-friendly.
''';
    return chatStream(
      message,
      district: district,
      state: state,
      country: 'India',
    );
  }

  // ── Plant Recommendations ─────────────────────────────────────────────────

  static Stream<String> plantRecommendationsStream({
    required String soilType,
    required String season,
    required double rainfall,
    required String region,
    required String currentCrops,
  }) {
    final message = '''
Provide expert crop recommendations for an Indian farmer:
- Soil Type: $soilType
- Season: $season
- Average Annual Rainfall: ${rainfall}mm
- Region: $region
- Currently Growing: $currentCrops

Give specific, ranked recommendations:
1. **Top 3 Crops This Season** — with expected yield (quintal/acre), price (₹/quintal), profit (₹/acre)
2. **Best High-Value Cash Crop** — with full profit calculation
3. **Intercropping Suggestion** — with combined profit estimate
4. **Seed Varieties** — specific varieties for this region
5. **Key Success Tips** — 3 practical tips for this season

Always show: Profit = (Yield × Price) − Cost, all in ₹/acre.
''';
    return chatStream(message, district: region, country: 'India');
  }
}

// ── Data Models ────────────────────────────────────────────────────────────────

class MarketData {
  final double currentPrice;
  final String trend;
  final String trendStrength;
  final List<MonthPrice> forecast;
  final String analysis;
  final String sellDecision;
  final String bestTimeToSell;
  final int opportunityScore;
  final List<String> nearbyMandis;

  MarketData({
    required this.currentPrice,
    required this.trend,
    required this.trendStrength,
    required this.forecast,
    required this.analysis,
    required this.sellDecision,
    required this.bestTimeToSell,
    required this.opportunityScore,
    required this.nearbyMandis,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0,
      trend: json['trend'] as String? ?? 'stable',
      trendStrength: json['trendStrength'] as String? ?? 'moderate',
      forecast: (json['forecast'] as List<dynamic>? ?? [])
          .map((e) => MonthPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
      analysis: json['analysis'] as String? ??
          json['sellReasoning'] as String? ?? '',
      sellDecision: json['sellDecision'] as String? ?? 'hold',
      bestTimeToSell: json['bestTimeToSell'] as String? ?? '',
      opportunityScore:
          (json['opportunityScore'] as num?)?.toInt() ?? 70,
      nearbyMandis: (json['nearbyMandis'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class MonthPrice {
  final String month;
  final double price;
  final String change;
  final double confidence;

  MonthPrice({
    required this.month,
    required this.price,
    required this.change,
    required this.confidence,
  });

  factory MonthPrice.fromJson(Map<String, dynamic> json) {
    return MonthPrice(
      month: json['month'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      change: json['change'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.7,
    );
  }
}

class NewsItem {
  final String title;
  final String snippet;
  final String link;
  final String source;
  final String date;

  const NewsItem({
    required this.title,
    required this.snippet,
    required this.link,
    required this.source,
    required this.date,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] as String? ?? '',
      snippet: json['snippet'] as String? ?? '',
      link: json['link'] as String? ?? '',
      source: json['source'] as String? ?? '',
      date: json['date'] as String? ?? '',
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
          maxTemp:
              (daily['temperature_2m_max'][i] as num?)?.toDouble() ?? 0,
          minTemp:
              (daily['temperature_2m_min'][i] as num?)?.toDouble() ?? 0,
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