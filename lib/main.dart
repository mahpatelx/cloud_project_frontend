
import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON handling
import 'package:http/http.dart' as http; // For making API calls
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0), // Provide a default font size
        ),
      ),
      home: ChatGPTScreen(),
    );
  }
}

class ChatGPTScreen extends StatefulWidget {
  @override
  _ChatGPTScreenState createState() => _ChatGPTScreenState();
}

class _ChatGPTScreenState extends State<ChatGPTScreen> {
  final List<Map<String, dynamic>> _messages = []; // List to store chat messages
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false; // To show loading indicator while waiting for API response

  // Method to reset the chat
  void _newChat() {
    setState(() {
      _messages.clear(); // Clear all chat messages
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({"text": message, "isUser": true});
      _isLoading = true;
    });

    _controller.clear();

    try {
      // Example API call
      final response = await http.post(
        Uri.parse('https://example.com/api/chat'), // Replace with your API endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add({"text": data['response'], "isUser": false});
        });
      } else {
        setState(() {
          _messages.add({
            // "text": "An error occurred. Please try again.",
            "text": "# An error occurred. \n**Please try again.**",
            "isUser": false,
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "text": "Error: ${e.toString()}",
          "isUser": false,
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF202020),
      appBar: AppBar(
        backgroundColor: Color(0xFF202020),
        elevation: 0,
        title: Stack(
          children: [
            Align(
              alignment: Alignment.center, // Center the logo
              child: Image.asset("assets/logo/logo.png", height: 50.0),
            ),
            Align(
              alignment: Alignment.centerRight, // Align the refresh button to the right
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _newChat, // Call the _newChat method
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatMessage(
                  text: message['text'],
                  isUser: message['isUser'],
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF202020),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 60.0,
                    decoration: BoxDecoration(
                      color: Color(0xFF101010),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Send a message...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5.0),
                Container(
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: Color(0xFF101010),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 30.0,
            color: Color(0xFF202020),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isUser ? Color(0xFF202020) : Color(0xFF444654),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: isUser
                  ? const Color.fromARGB(0, 255, 255, 255)
                  : const Color.fromARGB(0, 255, 255, 255),
              child: isUser
                  ? Icon(Icons.person, color: Colors.white)
                  : SvgPicture.asset(
                      'assets/svg/ai.svg',
                      width: 24.0,
                      height: 24.0,
                    ),
            ),
          ),
          Expanded(
            child: MarkdownBody(
              data: text,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(color: Colors.white, fontSize: 16.0),
                h1: const TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
                h2: const TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
                h3: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                h4: const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                h5: const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                h6: const TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold),
                blockquote: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                code: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14.0),
                listBullet: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
