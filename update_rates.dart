import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  // 1. Setup your configuration
  final String apyToken = Platform.environment['APY_TOKEN'] ?? '';
  final List<String> jobs = [
    "Flutter Developer",
    "Graphic Designer",
    "Content Writer",
    "Social Media Manager",
  ];
  final List<Map<String, dynamic>> results = [];

  print("🚀 Starting Market Rates Update...");

  for (var job in jobs) {
    try {
      final response = await http.post(
        Uri.parse('https://api.apyhub.com/ai/salary-estimate'),
        headers: {'apy-token': apyToken, 'Content-Type': 'application/json'},
        body: jsonEncode({
          "job_title": job,
          "location": "Global", // You can customize this
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // ApyHub usually gives annual salary.
        // We divide by 2080 (standard work hours per year) to get hourly.
        double avgAnnual = (data['data']['min'] + data['data']['max']) / 2;
        double hourlyRate = avgAnnual / 2080;

        results.add({
          "job_title": job,
          "avg_hourly_rate": hourlyRate.toStringAsFixed(2),
          "currency": "USD",
          "last_updated": DateTime.now().toIso8601String(),
        });
        print("✅ Added $job at \$$hourlyRate/hr");
      }
    } catch (e) {
      print("❌ Error fetching $job: $e");
    }
  }

  // 2. Save to your JSON file
  final file = File('market_rates.json');
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(results));
  print("📂 market_rates.json updated successfully!");
}
