import 'package:flutter/material.dart';
import 'features/scroll/scroll_position.dart';
import 'features/sealed_example/sealed_status.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example Collection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Example Collection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Wrap(
          spacing: 15,
          children: [
            SizedBox(
              width: double.maxFinite,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SealedStatusExPage(),),);
                },
                child: const Text('Sealed class example'),
              ),
            ),
            SizedBox(
              width: double.maxFinite,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyScrollPosition(),),);
                },
                child: const Text('Scroll Position example'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
