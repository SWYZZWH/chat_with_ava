import 'package:chat_with_ava/services//chat_service.dart'; // replace with your package name
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


Future<String> readTextFile(String filePath) async {
  return await rootBundle.loadString('assets/ip_address.txt');
}

String ipAddress="";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ipAddress = await readTextFile("ip_address.txt");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat with AVA!',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<ChatMessage> messages = [];
  final TextEditingController _textController = TextEditingController();
  final ChatService _chatService = ChatService(ipAddress);

  void _handleSubmitted(String text) async {
    _textController.clear();
    ChatMessage message = ChatMessage(
      text: text,
      isFromUser: true,
    );
    setState(() {
      messages.insert(0, message);
    });

    String botResponse = await _chatService.getBotResponse(text);
    ChatMessage botMessage = ChatMessage(
      text: botResponse,
      isFromUser: false,
    );
    setState(() {
      messages.insert(0, botMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        backgroundColor: _chatService.model == 'gpt-4'
            ? const Color.fromRGBO(111, 107, 213, 1.0)
            : const Color.fromRGBO(27, 195, 125, 1.0),
        title: Text(
            style: const TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
            _chatService.model == 'gpt-4' ? 'GPT-4' : 'GPT-3'),
        actions: <Widget>[
          Container(
            height: 20,
            margin: EdgeInsets.fromLTRB(10, 20, 20, 20),
            child: TextButton(
              onPressed: () {
                setState(() {
                  if (_chatService.model == 'gpt-4') {
                    _chatService.setModel('gpt-3.5-turbo');
                  } else {
                    _chatService.setModel('gpt-4');
                  }
                });
              },
              style: TextButton.styleFrom(
                primary: Colors.white,
                // This is the color of the text
                // backgroundColor: Colors.blue, // This is the background color of the button
                textStyle: TextStyle(fontSize: 14.0),
                // This changes the font
                // size
                shape: RoundedRectangleBorder(
                  // This makes the button have rounded corners
                  borderRadius: BorderRadius.circular(15.0),
                ),
                side: BorderSide(
                  // This is the border around the button
                  color: Colors.white,
                  width: 3,
                ),
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              ),
              child: Text('Switch'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (_, int index) => messages[index],
            ),
          ),
          const Divider(height: 1.0),
          Container(
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                style: const TextStyle(height: 1.2, fontSize: 16),
                maxLines: 5,
                minLines: 1,
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: "发条友善的弹幕记录当下",
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text)),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isFromUser;

  ChatMessage({required this.text, required this.isFromUser});

  Widget build(BuildContext context) {
    if (!isFromUser) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.only(right: 10.0),
              child: const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/ava.jpg')),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final maxWidth = MediaQuery.of(context).size.width * 0.7;
                    final textWidth = calculateTextWidth(
                        text,
                        const TextStyle(
                            height: 2,
                            fontSize: 16)); // Implement this function based on
                    // your needs

                    return Container(
                      width: textWidth > maxWidth ? maxWidth : null,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: SelectableText(
                          strutStyle: const StrutStyle(
                              forceStrutHeight: true, leading: 0.5),
                          text),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final maxWidth = MediaQuery.of(context).size.width * 0.7;
                    final textWidth = calculateTextWidth(
                        text, const TextStyle(height: 2, fontSize: 14));

                    return Container(
                      width: textWidth > maxWidth ? maxWidth : null,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: SelectableText(
                          strutStyle: const StrutStyle(
                              forceStrutHeight: true, leading: 0.5),
                          text),
                    );
                  },
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(left: 10.0),
              child: const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/diana.png')),
            ),
          ],
        ),
      );
    }
  }

  double calculateTextWidth(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.size.width;
  }
}
