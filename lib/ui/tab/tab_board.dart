import 'package:flutter/material.dart';

class TabBoard extends StatelessWidget {
  const TabBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const TabBar(
              indicatorColor: Colors.pink,
              labelColor: Colors.pink,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              tabs: [
                Tab(icon: Icon(Icons.sports_tennis), text: '코트 양도'),
                Tab(icon: Icon(Icons.shopping_bag), text: '라켓 거래'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text('코트 양도 게시판 내용')),
                  Center(child: Text('라켓 중고거래 게시판 내용')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
