class ChatRequest {
  final String message;

  ChatRequest({required this.message});

  Map<String, dynamic> toJson() => {
    'message': message,
  };
}

class ChatResponse {
  final String reply;

  ChatResponse({required this.reply});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(reply: json['reply']);
  }
}
