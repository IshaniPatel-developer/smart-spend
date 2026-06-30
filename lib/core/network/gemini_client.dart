import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../database/database_helper.dart';

class GeminiClient {
  final Dio _dio;
  final DatabaseHelper _dbHelper;

  GeminiClient({
    Dio? dio,
    DatabaseHelper? dbHelper,
  })  : _dio = dio ?? Dio(),
        _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<String> _getApiKey() async {
    // Return hardcoded API Key directly
    return 'AIzaSyCf-8a4CZ4LnJNgGlVD72hQNVwULF5yEkg';
  }

  /// Sends a post request with automatic model fallback in case of deprecations or high demand limits.
  Future<Response> _postWithFallback({
    required String pathSegment,
    required Map<String, dynamic> requestBody,
  }) async {
    final apiKey = await _getApiKey();
    
    // Ordered list of models that we know are supported on this key
    final candidateModels = [
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-3.5-flash',
      'gemini-3.1-flash-lite'
    ];

    DioException? lastDioException;
    Object? lastException;

    for (final model in candidateModels) {
      final url = 'https://generativelanguage.googleapis.com/v1/models/$model:$pathSegment?key=$apiKey';
      try {
        final response = await _dio.post(
          url,
          data: requestBody,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );
        if (response.statusCode == 200) {
          return response;
        }
      } on DioException catch (e) {
        lastDioException = e;
        final statusCode = e.response?.statusCode;
        // Fallback on rate-limiting (429), model overloaded (503), bad requests (400) or not found (404)
        if (statusCode == 404 || statusCode == 429 || statusCode == 503 || statusCode == 400) {
          continue;
        }
        rethrow;
      } catch (e) {
        lastException = e;
        continue;
      }
    }

    // If all models failed, throw the detailed error of the last response
    if (lastDioException != null) {
      String errorMessage = 'Gemini API call failed after trying fallback models';
      if (lastDioException.response != null) {
        final responseData = lastDioException.response?.data;
        if (responseData is Map && responseData.containsKey('error')) {
          errorMessage = responseData['error']['message'] ?? errorMessage;
        } else {
          errorMessage = 'HTTP ${lastDioException.response?.statusCode}: ${lastDioException.response?.statusMessage}';
        }
      } else {
        errorMessage = lastDioException.message ?? errorMessage;
      }
      throw Exception(errorMessage);
    }

    throw lastException ?? Exception('Failed to connect to any Gemini models');
  }

  /// Sends receipt image to Gemini and extracts structured JSON.
  Future<Map<String, dynamic>> scanReceipt(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Receipt image file not found at path: $imagePath');
    }

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);
    
    // Simple MIME type detection based on extension
    String mimeType = 'image/jpeg';
    if (imagePath.toLowerCase().endsWith('.png')) {
      mimeType = 'image/png';
    } else if (imagePath.toLowerCase().endsWith('.webp')) {
      mimeType = 'image/webp';
    }

    final requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text": "You are a receipt scanning assistant. Extract the following fields from the receipt image: merchantName, date, amount, category.\n"
                  "Return ONLY a valid JSON object matching this schema:\n"
                  "{\n"
                  "  \"merchantName\": \"string\",\n"
                  "  \"amount\": 0.0,\n"
                  "  \"date\": \"YYYY-MM-DD\",\n"
                  "  \"category\": \"Food\" | \"Shopping\" | \"Travel\" | \"Utilities\" | \"Entertainment\" | \"Others\"\n"
                  "}\n"
                  "Notes on extraction:\n"
                  "1. date: Use format YYYY-MM-DD. If year is missing, assume current year 2026. If date is not found, use current date: 2026-06-30.\n"
                  "2. category: Choose exactly one matching the item type: Food, Shopping, Travel, Utilities, Entertainment, Others. If not identifiable, default to Others.\n"
                  "3. merchantName: The vendor/store name.\n"
                  "4. amount: The total amount paid as a float number. If not found, use 0.0.\n"
                  "Do not wrap JSON in code blocks. Just return the raw JSON object string."
            },
            {
              "inlineData": {
                "mimeType": mimeType,
                "data": base64Image
              }
            }
          ]
        }
      ]
    };

    final response = await _postWithFallback(
      pathSegment: 'generateContent',
      requestBody: requestBody,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No candidates returned from Gemini API.');
      }

      final content = candidates.first['content'];
      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('No text parts returned from Gemini API.');
      }

      final rawText = parts.first['text'] as String?;
      if (rawText == null || rawText.trim().isEmpty) {
        throw Exception('Empty response from Gemini model.');
      }

      // Parse extracted JSON content
      try {
        return _cleanAndParseJson(rawText);
      } catch (e) {
        throw Exception('Failed to parse Gemini response as JSON. Response was: $rawText');
      }
    } else {
      throw Exception('Gemini API request failed with status: ${response.statusCode}');
    }
  }

  /// Sends formatted transaction history to Gemini to generate insights report.
  Future<Map<String, dynamic>> generateSpendingInsights(List<Map<String, dynamic>> expenses) async {
    final buffer = StringBuffer();
    buffer.writeln("Analyze the following list of saved user expenses:");
    buffer.writeln("ID | Date | Merchant | Amount | Category | Notes");
    for (final exp in expenses) {
      buffer.writeln("${exp['id']} | ${exp['date']} | ${exp['merchant_name']} | \$${exp['amount']} | ${exp['category']} | ${exp['notes'] ?? ''}");
    }
    buffer.writeln("\nPlease generate a spending analysis report.");
    buffer.writeln("You must respond ONLY with a JSON object matching this schema:");
    buffer.writeln("{");
    buffer.writeln("  \"reportMarkdown\": \"A comprehensive, natural-language spending report in beautiful markdown format. Summarize the spending, call out key areas, and use rich formatting like bullet points, tables, and headers.\",");
    buffer.writeln("  \"spendingTrends\": \"A short description summarizing the key spending trends (e.g. food delivery dominance, spikes on weekends).\",");
    buffer.writeln("  \"recommendation\": \"Provide exactly one actionable recommendation matching this exact style and structure: 'You spent 35% more on food delivery this month compared to last month. Consider setting a monthly dining budget.' (calculate the actual category name and percentage differences from the transaction data, or construct a sensible recommendation in this exact phrasing pattern).\"");
    buffer.writeln("}");
    buffer.writeln("\nDo not wrap the JSON response in code blocks. Just return the raw JSON object.");

    final requestBody = {
      "contents": [
        {
          "parts": [
            {
              "text": buffer.toString()
            }
          ]
        }
      ]
    };

    final response = await _postWithFallback(
      pathSegment: 'generateContent',
      requestBody: requestBody,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No candidates returned from Gemini API.');
      }

      final content = candidates.first['content'];
      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('No text parts returned from Gemini API.');
      }

      final rawText = parts.first['text'] as String?;
      if (rawText == null || rawText.trim().isEmpty) {
        throw Exception('Gemini generated null or empty response.');
      }

      try {
        return _cleanAndParseJson(rawText);
      } catch (e) {
        throw Exception('Failed to parse Gemini spending insights as JSON. Response was: $rawText');
      }
    } else {
      throw Exception('Gemini API request failed with status: ${response.statusCode}');
    }
  }

  /// Clean Markdown wrapping format and parse JSON safely
  Map<String, dynamic> _cleanAndParseJson(String rawText) {
    String cleanJson = rawText.trim();
    
    // Strip markdown code block wrapping if present (e.g. ```json ... ``` or ``` ... ```)
    if (cleanJson.startsWith('```')) {
      final firstNewLine = cleanJson.indexOf('\n');
      final lastBackticks = cleanJson.lastIndexOf('```');
      if (firstNewLine != -1 && lastBackticks != -1 && lastBackticks > firstNewLine) {
        cleanJson = cleanJson.substring(firstNewLine + 1, lastBackticks).trim();
      }
    }
    
    return jsonDecode(cleanJson) as Map<String, dynamic>;
  }
}
