import 'package:dio/dio.dart';
import 'package:example/utils/sealed/status.dart';
import 'package:flutter/material.dart';

final dio = Dio(BaseOptions(
  connectTimeout: const Duration(seconds: 30),
),);

class SealedStatusExPage extends StatefulWidget {
  const SealedStatusExPage({super.key});

  @override
  State<SealedStatusExPage> createState() => SealedStatusExPageState();
}

class SealedStatusExPageState extends State<SealedStatusExPage> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, get);
  }

  @override
  Widget build(BuildContext context) {
    final status = this.status;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Sealed Status'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          this.status = null;
          get();
        },
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              physics: const AlwaysScrollableScrollPhysics(),
              child: ListBody(
                children: [
                  if (status case LoadingState())
                    status.loadingWidget()
                  else if(status case CompletedState())
                    ... List.generate(status.value.length, (index) {
                      final data = status.value.entries.toList()[index];
                      return Text('${data.key}: ${data.value}', textAlign: TextAlign.start,);
                    },)
                  else if(status case ErrorState())
                      Text(status.content, textAlign: TextAlign.center,),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Status<Map<String, dynamic>>? status;
  Future<void> get() async {
    if (status is! LoadingState || status is! CompletedState) {
      setState(() {
        status = LoadingState();
      });

      await Future.delayed(const Duration(seconds: 1));

      try {
        // throw const FormatException('Json Convert Failed');
        final response = await dio.get('https://jsonplaceholder.typicode.com/todos/1');

        if (response.statusCode == 200) {
          final json = response.tryDecodeAsMap;

          if (json is Map<String, dynamic>) {
            setState(() {
              status = CompletedState(Map.of(json));
            });
          }
          else {
            throw const FormatException('Json convert failed!');
          }
        }
        else {
          throw response;
        }
      }
      catch (e,s) {
        setState(() {
          status = ErrorState(e,s);
        });
      }
    }
  }
}