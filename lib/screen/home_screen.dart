import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();

  bool connectionStatus = false;

  late StompClient stompClient;

  List<String> serverResponse = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(connectionStatus
                      ? Icons.close_rounded
                      : Icons.bolt_rounded),
                  label: Text(connectionStatus ? 'DISCONNECT' : 'CONNECT'),
                  onPressed: () {
                    connectionStatus ? stopSocket() : startSocket();
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: serverResponse.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text('Message: ${serverResponse[index]}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    color: Colors.blue,
                    onPressed: () => sendMessage(),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  sendMessage() {
    if (!connectionStatus) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Client Not Connected'),
          duration: Duration(milliseconds: 500),
        ),
      );
      return;
    }
    if (_messageController.text.isNotEmpty) {
      // configureMessageBroker
      // registry.setApplicationDestinationPrefixes("/app");
      // @MessageMapping("/message") of controller
      stompClient.send(
          destination: '/app/message', body: _messageController.text);
      _messageController.clear();
    }
  }

  startSocket() {
    // registerStompEndpoints
    // registry.addEndpoint("/socket").setAllowedOriginPatterns("*").withSockJS();
    String url = 'http://192.168.0.106:8080/socket';

    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: url,
        onConnect: connectCallback,
        onStompError: stompErrorCallback,
      ),
    );

    stompClient.activate();
  }

  stopSocket() {
    stompClient.deactivate();
    updateStatus(false);
    setState(() {
      serverResponse = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Client Disconnected'),
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  updateStatus(bool status) {
    setState(() {
      connectionStatus = status;
    });
  }

  void connectCallback(StompFrame frame) {
    // configureMessageBroker
    // registry.enableSimpleBroker("/watch");
    String destination = '/watch';
    updateStatus(true);
    stompClient.subscribe(
      destination: destination,
      callback: subscriptionCallback,
    );
  }

  void subscriptionCallback(StompFrame frame) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data Received: ${frame.body}'),
        duration: const Duration(milliseconds: 500),
      ),
    );
    if (frame.body != null) {
      setState(() {
        serverResponse.add(frame.body!);
      });
    }
  }

  void stompErrorCallback(StompFrame frame) {
    updateStatus(false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stomp Error: ${frame.body}'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }
}
