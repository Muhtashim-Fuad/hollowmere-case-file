import 'package:assistant/repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assistant/providers/chat_provider.dart';
import 'package:assistant/widgets/buttons/refresh_button.dart';
import 'package:assistant/widgets/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Repository.chunkFiles();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: ChangeNotifierProvider(
        create: (context) => ChatProvider(),
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 4.0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0, right:0.0, top: 4.0, bottom: 4.0),
              child: const Icon(
                Icons.chat,
                size: 32.0,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                const Text(
                  'Your favourite chat assistant',
                    style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            actions: [
              RefreshButton(),
            ],
          ),
          body: ChatScreen(),
        ),
      ),
    );
  }
}
