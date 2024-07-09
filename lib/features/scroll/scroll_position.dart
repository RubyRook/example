import 'package:flutter/material.dart';

class MyScrollPosition extends StatefulWidget {
  const MyScrollPosition({super.key});

  @override
  State<MyScrollPosition> createState() => MyScrollPositionState();
}

class MyScrollPositionState extends State<MyScrollPosition> {
  final items = [
    (key: GlobalKey(), height: 200.0),
    (key: GlobalKey(), height: 150.0),
    (key: GlobalKey(), height: 300.0),
    (key: GlobalKey(), height: 400.0),
    (key: GlobalKey(), height: 100.0),
    (key: GlobalKey(), height: 500.0),
  ];

  void scrollTo (int index){
    final currentContext = items[index].key.currentContext;
    if (currentContext != null) {
      Scrollable.ensureVisible(
        currentContext,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Scroll Position'),
        bottom: PreferredSize(
          preferredSize: const Size(double.maxFinite, kTextTabBarHeight,),
          child: SizedBox(
            height: kTextTabBarHeight,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 15,
                children: List.generate(items.length, (index) {
                  return FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      scrollTo(index);
                    },
                    child: SizedBox(
                      height: kToolbarHeight-30,
                      child: Text('Index: $index'),
                    ),
                  );
                },),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Wrap(
          runSpacing: 15,
          children: List.generate(items.length, (index) {
            final item = items[index];

            return SizedBox(
              key: item.key,
              width: double.maxFinite,
              height: item.height,
              child: Card(
                color: Colors.grey,
                margin: EdgeInsets.zero,
                child: Center(
                  child: Text(index.toString()),
                ),
              ),
            );
          },),
        ),
      ),
    );
  }
}