import 'package:flutter/material.dart';
import 'package:grad_ease/Features/student/group_chat_widget.dart';
import '../../AI/check_palagrism.dart';
import '../../AI/check_eval.dart';

// -----------------------AI CHAT----------------------
class AICHAT extends StatefulWidget {
  const AICHAT({super.key});

  @override
  _AICHATState createState() => _AICHATState();
}

class _AICHATState extends State<AICHAT> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  String? _currentAction; // 'plagiarism' or 'evaluation'
  bool _showQuickActions = true;

  @override
  void initState() {
    super.initState();
    _messages.add({
      "text":
          "Hello! 😊 Welcome! I'm here to assist you with your graduation project. I'm ready to support you every step of the way.\n\nHow can I help you today? You can:",
      "isUser": false,
      "timestamp": DateTime.now().toIso8601String(),
    });
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add({
          "text": message,
          "isUser": true,
          "timestamp": DateTime.now().toIso8601String(),
        });
        _showQuickActions = false;
      });
      _messageController.clear();
      _scrollToBottom();

      // Handle the user's response based on current action
      if (_currentAction == 'plagiarism') {
        _handlePlagiarismCheck(message);
      } else if (_currentAction == 'evaluation') {
        _handleEvaluation(message);
      }
    }
  }

  void _handleQuickAction(String action) {
    setState(() {
      _currentAction = action;
      _showQuickActions = false;
    });

    String botMessage;
    if (action == 'plagiarism') {
      botMessage = "🔍 **Plagiarism Checker**\n\nI'll help you check your project description for originality. Please paste your project description below, and I'll analyze it for potential plagiarism and provide suggestions for improvement.";
    } else {
      botMessage = "📊 **Project Evaluator**\n\nI'll evaluate your graduation project proposal. Please provide your project description including objectives, methodology, and expected outcomes. I'll give you detailed feedback and scoring.";
    }

    setState(() {
      _messages.add({
        "text": botMessage,
        "isUser": false,
        "timestamp": DateTime.now().toIso8601String(),
      });
    });
    _scrollToBottom();
  }

  Future<void> _handlePlagiarismCheck(String description) async {
    _showTypingIndicator();
    
    try {
      final result = await PlagiarismChecker.checkPlagiarism(description);
      _hideTypingIndicator();
      
      setState(() {
        _messages.add({
          "text": result,
          "isUser": false,
          "timestamp": DateTime.now().toIso8601String(),
        });
        _messages.add({
          "text": "Would you like me to check another description for plagiarism or evaluate a project? 😊",
          "isUser": false,
          "timestamp": DateTime.now().toIso8601String(),
        });
        _currentAction = null;
        _showQuickActions = true;
      });
    } catch (e) {
      _hideTypingIndicator();
      setState(() {
        _messages.add({
          "text": "Sorry, I encountered an error while checking for plagiarism. Please try again later.",
          "isUser": false,
          "timestamp": DateTime.now().toIso8601String(),
        });
        _currentAction = null;
        _showQuickActions = true;
      });
    }
    _scrollToBottom();
  }

  Future<void> _handleEvaluation(String description) async {
    _showTypingIndicator();
    
    try {
      final result = await ProjectEvaluator.evaluateProject(description);
      _hideTypingIndicator();
      
      setState(() {
        _messages.add({
          "text": result,
          "isUser": false,
          "timestamp": DateTime.now().toIso8601String(),
        });
        _messages.add({
          "text": "Would you like me to evaluate another project or check for plagiarism? 😊",
          "isUser": false,
          "timestamp": DateTime.now().toIso8601String(),
        });
        _currentAction = null;
        _showQuickActions = true;
      });
    } catch (e) {
      _hideTypingIndicator();
      setState(() {
        _messages.add({
          "text": "Sorry, I encountered an error while evaluating the project. Please try again later.",
          "isUser": false,
          "timestamp": DateTime.now().toIso8601String(),
        });
        _currentAction = null;
        _showQuickActions = true;
      });
    }
    _scrollToBottom();
  }

  void _showTypingIndicator() {
    setState(() {
      _isTyping = true;
      _messages.add({
        "text": "AI is typing...",
        "isUser": false,
        "timestamp": DateTime.now().toIso8601String(),
        "isTyping": true,
      });
    });
    _scrollToBottom();
  }

  void _hideTypingIndicator() {
    setState(() {
      _isTyping = false;
      _messages.removeWhere((message) => message["isTyping"] == true);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Build header section
  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: [
          Image.asset(
            'assets/head2.png',
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 70,
            left: 2,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Positioned(
            top: 135,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "AI Conversation",
                style: TextStyle(
                  fontFamily: "Source Serif 4",
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    if (!_showQuickActions) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const Text(
            "Quick Actions:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleQuickAction('plagiarism'),
                  icon: const Icon(Icons.search, size: 20),
                  label: const Text("Check Plagiarism"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF011226),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleQuickAction('evaluation'),
                  icon: const Icon(Icons.assessment, size: 20),
                  label: const Text("Evaluate Project"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF011226),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return GroupChat(
                  text: message["text"],
                  isMe: message["isUser"],
                  senderName: message["isUser"] ? "You" : "AI Assistant",
                  senderId: "", // AI doesn't have a real senderId
                  showSenderName: false,
                  showTimestamp: false,
                  timestamp: message["timestamp"],
                );
              },
            ),
          ),
          _buildQuickActions(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: _currentAction != null 
                          ? 'Enter your project description...'
                          : 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF011226)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
