// selected_model.dart
class SelectedModel {
  static String baseUrl = "https://chat-api-g1zt.onrender.com/chatgpt"; // default to GPT

  static void setModelUrl(String url) {
    baseUrl = url;
  }

  static String get url => baseUrl;
}
