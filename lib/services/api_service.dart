import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart'; // adjust path if needed

Future<String> sendMessageToMitra(String userMessage) async {
  const String apiUrl = "https://your-api-url.com/chat"; // 🔁 Replace with your real API

  final request = ChatRequest(message: userMessage);
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(request.toJson()),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    final chatResponse = ChatResponse.fromJson(responseData);
    return chatResponse.reply;
  } else {
    print("❌ Failed to get response: ${response.body}");
    return "Something went wrong 😓";
  }
}
