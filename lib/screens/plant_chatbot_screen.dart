import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/sensor_service.dart';
import '../services/plant_service.dart';

class _ChatMessage {
  final String role; // 'user' | 'assistant'
  final String text;
  _ChatMessage({required this.role, required this.text});
}

class PlantChatbotScreen extends StatefulWidget {
  final String plantId;
  const PlantChatbotScreen({required this.plantId, super.key});
  @override
  State<PlantChatbotScreen> createState() => _PlantChatbotScreenState();
}

class _PlantChatbotScreenState extends State<PlantChatbotScreen> {
  final PlantService _plantService = PlantService();
  final SensorService _sensorService = SensorService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;
  bool _includeHistory = true;

  // Moisture value mapping from 0-4095 to 0-100
  double mapMoistureValue(double rawValue) {
    // Map 0-4095 to 0-100
    // 0 = very dry (0%), 4095 = very wet (100%)
    return (rawValue / 4095) * 100;
  }

  @override
  void initState() {
    super.initState();
    // Add initial system message
    _messages.add(_ChatMessage(
      role: 'assistant', 
      text: 'Hello! I\'m your plant care assistant. I can help you with plant care advice, monitor your plant\'s health, and answer questions about gardening. How can I help you today?'
    ));
  }

  Future<void> _askChatbot() async {
    final input = _controller.text.trim();
    if (input.isEmpty || _loading) return;
    
    // Token limiti kontrolü (yaklaşık 100 karakter)
    if (input.length > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message too long. Please write shorter.')),
      );
      return;
    }
    
    setState(() {
      _loading = true;
      _messages.add(_ChatMessage(role: 'user', text: input));
      _controller.clear();
    });
    await Future.delayed(const Duration(milliseconds: 50));
    _scrollToBottom();

    try {
      final jwt = Supabase.instance.client.auth.currentSession?.accessToken ?? '';
      
      // Bitki bilgilerini al
      final plantData = await _plantService.getPlant(widget.plantId);
      
      // Sensör verilerini al
      final latestData = await _sensorService.fetchLatestReading(widget.plantId);
      List<Map<String, dynamic>>? history;
      if (_includeHistory) {
        history = await _sensorService.fetchHistory(widget.plantId, const Duration(hours: 24));
      }
      
      final answer = await ChatbotService.getChatbotResponse(
        plantId: widget.plantId,
        message: input,
        jwt: jwt,
        history: history,
        plantInfo: {
          'name': plantData?['name'] ?? '',
          'species': plantData?['species'] ?? '',
          'current_moisture': latestData?['soil_moisture'] != null ? mapMoistureValue((latestData!['soil_moisture'] as num).toDouble()) : 0,
          'current_light': latestData?['light_level'] ?? 0,
        },
      );
      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', text: answer));
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', text: 'Sorry, an error occurred: $e'));
      });
    } finally {
      setState(() { _loading = false; });
      await Future.delayed(const Duration(milliseconds: 50));
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Widget _buildPlaceholder() {
    if (_messages.length > 1) return const SizedBox.shrink();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Ask me anything about your plants!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'I can help with care tips, health monitoring, and gardening advice.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Care Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(_ChatMessage(
                  role: 'assistant', 
                  text: 'Hello! I\'m your plant care assistant. I can help you with plant care advice, monitor your plant\'s health, and answer questions about gardening. How can I help you today?'
                ));
              });
            },
            tooltip: 'Reset Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Include history checkbox
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _includeHistory,
                  onChanged: (value) => setState(() => _includeHistory = value ?? false),
                ),
                const Expanded(
                  child: Text(
                    'Include last 24 hours of sensor data',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? _buildPlaceholder()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message.role == 'user';
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: const Icon(Icons.eco, size: 16, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(20).copyWith(
                                    bottomLeft: isUser ? const Radius.circular(4) : null,
                                    bottomRight: !isUser ? const Radius.circular(4) : null,
                                  ),
                                ),
                                child: Text(
                                  message.text,
                                  style: TextStyle(
                                    color: isUser
                                        ? Theme.of(context).colorScheme.onPrimary
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            if (isUser) ...[
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                child: const Icon(Icons.person, size: 16, color: Colors.white),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about your plants...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _askChatbot(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _loading ? null : _askChatbot,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}