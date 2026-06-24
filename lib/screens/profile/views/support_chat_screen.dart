import 'dart:async';
import 'package:flutter/material.dart';
import 'package:petro_world/constants.dart';
import 'package:petro_world/services/api_service.dart';
import 'package:intl/intl.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key, required this.ticket});

  final Map<String, dynamic> ticket;

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _messages = [];

  // Poll every 5 seconds instead of Supabase Realtime
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _pollTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _loadMessages());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages =
          await ApiService.instance.getSupportMessages(widget.ticket['id']);
      if (mounted) {
        final prevCount = _messages.length;
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        // Auto-scroll only when new messages arrive
        if (messages.length > prevCount) {
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    try {
      await ApiService.instance.sendSupportMessage(widget.ticket['id'], text);
      _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.ticket['subject'] ?? 'Support Chat',
                style: const TextStyle(fontSize: 16)),
            Text(widget.ticket['status'] ?? 'Open',
                style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(widget.ticket['status']))),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(defaultPadding),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isAdmin = message['is_admin'] ?? false;
                      return _buildMessageBubble(
                        message['message']?.toString() ?? '',
                        isAdmin as bool,
                        message['created_at']?.toString() ?? '',
                      );
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isAdmin, String timestamp) {
    String time = '';
    try {
      time = DateFormat('MMM dd, hh:mm a').format(DateTime.parse(timestamp));
    } catch (_) {
      time = timestamp;
    }

    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isAdmin ? Colors.grey[200] : primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAdmin ? 0 : 16),
            bottomRight: Radius.circular(isAdmin ? 16 : 0),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(color: isAdmin ? Colors.black87 : Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                  color: isAdmin ? Colors.black54 : Colors.white70,
                  fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: primaryColor),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Closed':
        return Colors.green;
      case 'In Progress':
      case 'in_progress':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
