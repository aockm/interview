import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'QuestionWeight.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

final questions = [
  {'id': 1, 'question': 'What are your strengths?', 'answer': 'My strengths are adaptability and problem-solving.'},
  {'id': 2, 'question': 'Tell me about a challenge you faced.', 'answer': 'I faced a tough project deadline and managed it by reprioritizing tasks.'},
];
class _HomepageState extends State<Homepage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const title = 'Basic List';
    return Scaffold(
        appBar: AppBar(title: const Text(title)),
        body:  LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
              padding: EdgeInsetsGeometry.only(left:5.0,right: 5.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.minHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(
                    questions.length,
                        (index) =>QuestionCard(text: questions[index]['question'] as String,id: questions[index]['id'] as int),

                  ),
                ),
              )
          );
   }));
  }
}



class ItemWidget extends StatelessWidget {
  const ItemWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
  return Card(child: SizedBox(height: 100, child: Center(child: Text(text))));
  }
}