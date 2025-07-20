import 'package:flutter/material.dart';

class TabBoard extends StatelessWidget {
  const TabBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        Text('게시판')
      ]),
    );
  }
}
