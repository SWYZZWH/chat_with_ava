import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/chat_message.dart';

const String defaultModel = "gpt-3.5-turbo";
const Set<String> availableModels = {"gpt-3.5-turbo", "gpt-4"};

final List<ChatMessage> defaultMessages = [
  ChatMessage(
      role: "system",
      content: "作为人工智能，你会利用自己的知识为用户提供一切可能的帮助。"
          "同时，你需要扮演向晚，b站 id 是向晚大魔王，是隶属于 A-SOUL "
          "企划的，蠢萌可爱又有元气的虚拟主播，直播的目的是为了给大家带来快乐。"
          "你的队友包括嘉然，乃琳和贝拉。你的粉丝叫做顶碗人。")
];
const String errorInfo = "向晚在想自己的事情，好像没有听到...";

class ChatService {
  List<ChatMessage> _history = List.from(defaultMessages);
  String currentModel = defaultModel;

  List<ChatMessage> get history => _history;

  String get model => currentModel;
  String ipAddress = "localhost";

  ChatService(String ip) {
    ipAddress = ip;
  }

  void setModel(String model) {
    if (!availableModels.contains(model)) {
      print("invalid model setting $model");
      return;
    }
    currentModel = model;
  }

  void clearHistory() {
    _history = List.from(defaultMessages);
  }

  Future<String> getBotResponse(String userMessage) async {
    _history.add(ChatMessage(role: "user", content: userMessage));

    final Map<String, dynamic> requestBody = {
      "model": currentModel,
      "messages": _history,
    };
    print("sending request ${jsonEncode(requestBody)}");

    final http.Response response = await http.post(
      // for production
      Uri(scheme: "http", host: ipAddress, port: 5000),
      // for web & test
      // Uri(scheme: "http", host: "localhost", port: 5000),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print("response is ${utf8.decode(response.bodyBytes)}");
    if (response.statusCode == 200) {
      final String botMessage =
          jsonDecode(utf8.decode(response.bodyBytes))['choices'][0]['message']
                  ['content']
              .trim();
      _history.add(ChatMessage(role: 'assistant', content: botMessage));
      return botMessage;
    } else {
      _history.add(ChatMessage(role: 'assistant', content: errorInfo));
      return errorInfo;
    }
  }
}
