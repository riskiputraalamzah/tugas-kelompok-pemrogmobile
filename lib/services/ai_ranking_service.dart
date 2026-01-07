import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/application.dart';

class AIRankingService {
  static const String _apiKey = 'AIzaSyAtwP1kvRa_9Ud9aVOiOw7PnH7dyKkOSoI';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Analyzes an application using Gemini AI and returns a score (0-100) with a label
  static Future<Map<String, dynamic>> analyzeApplication(Application application) async {
    try {
      final prompt = '''
Kamu adalah seorang HR recruiter profesional. Analisis data pelamar berikut dan berikan penilaian objektif.

DATA PELAMAR:
- Nama: ${application.fullName}
- Pendidikan: ${application.education}
- Pengalaman Kerja: ${application.experience}
- Keahlian: ${application.skills}
- Surat Motivasi: ${application.coverLetter}

INSTRUKSI:
1. Berikan skor 0-100 berdasarkan kualifikasi kandidat
2. Pertimbangkan: pendidikan, pengalaman relevan, keahlian teknis, dan motivasi
3. Berikan label: "Sangat Bagus" (70-100), "Bagus" (50-69), "Cukup" (30-49), atau "Kurang" (0-29)

PENTING: Balas HANYA dalam format JSON seperti ini, tanpa teks lain:
{"score": 75, "label": "Sangat Bagus", "reason": "Alasan singkat"}
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 256,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final textResponse = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        
        // Extract JSON from response
        final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(textResponse);
        if (jsonMatch != null) {
          final result = jsonDecode(jsonMatch.group(0)!);
          return {
            'score': (result['score'] as num).toDouble(),
            'label': result['label'] as String,
            'reason': result['reason'] as String?,
          };
        }
      }
      
      // Fallback to rule-based scoring if API fails
      return _fallbackAnalysis(application);
    } catch (e) {
      // Fallback to rule-based scoring if API fails
      return _fallbackAnalysis(application);
    }
  }

  /// Fallback rule-based analysis when API is unavailable
  static Map<String, dynamic> _fallbackAnalysis(Application application) {
    double totalScore = 0;

    // Skills analysis (max 35 points)
    final skillKeywords = [
      'flutter', 'dart', 'java', 'python', 'javascript', 'react',
      'sql', 'database', 'api', 'git', 'figma', 'ui', 'ux',
      'machine learning', 'data analysis', 'leadership', 'communication'
    ];
    
    final lowerSkills = application.skills.toLowerCase();
    int skillMatches = 0;
    for (final keyword in skillKeywords) {
      if (lowerSkills.contains(keyword)) {
        skillMatches++;
      }
    }
    totalScore += (skillMatches * 3).clamp(0, 35);

    // Education analysis (max 25 points)
    final lowerEducation = application.education.toLowerCase();
    if (lowerEducation.contains('s2') || lowerEducation.contains('master')) {
      totalScore += 25;
    } else if (lowerEducation.contains('s1') || lowerEducation.contains('sarjana')) {
      totalScore += 20;
    } else if (lowerEducation.contains('d3') || lowerEducation.contains('diploma')) {
      totalScore += 12;
    } else {
      totalScore += 5;
    }

    // Experience analysis (max 25 points)
    final lowerExp = application.experience.toLowerCase();
    final yearMatch = RegExp(r'(\d+)\s*(tahun|year)').firstMatch(lowerExp);
    if (yearMatch != null) {
      final years = int.tryParse(yearMatch.group(1) ?? '0') ?? 0;
      totalScore += (years * 3).clamp(0, 25);
    } else if (!lowerExp.contains('fresh graduate')) {
      totalScore += 10;
    }

    // Cover letter quality (max 15 points)
    final wordCount = application.coverLetter.split(RegExp(r'\s+')).length;
    if (wordCount >= 100) {
      totalScore += 15;
    } else if (wordCount >= 50) {
      totalScore += 10;
    } else {
      totalScore += 5;
    }

    final score = totalScore.clamp(0, 100);
    String label;
    if (score >= 70) {
      label = 'Sangat Bagus';
    } else if (score >= 50) {
      label = 'Bagus';
    } else if (score >= 30) {
      label = 'Cukup';
    } else {
      label = 'Kurang';
    }

    return {
      'score': score,
      'label': label,
      'reason': 'Analisis berdasarkan aturan standar',
    };
  }

  /// Ranks multiple applications and returns them sorted by score
  static Future<List<Application>> rankApplications(List<Application> applications) async {
    final rankedApps = <Application>[];

    for (final app in applications) {
      final result = await analyzeApplication(app);
      rankedApps.add(app.copyWith(
        aiScore: result['score'] as double,
        aiLabel: result['label'] as String,
      ));
    }

    // Sort by score descending
    rankedApps.sort((a, b) => (b.aiScore ?? 0).compareTo(a.aiScore ?? 0));

    return rankedApps;
  }
}
