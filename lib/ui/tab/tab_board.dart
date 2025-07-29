import 'package:flutter/material.dart';
import 'package:tennisreminder_app/ui/route/board/court_transfer_exchange/route_board_court.dart';
import 'package:tennisreminder_app/ui/route/board/racket_opinion/route_racekt_opinion.dart';
import 'package:tennisreminder_core/const/value/colors.dart';

class TabBoard extends StatelessWidget {
  const TabBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const TabBar(
              indicatorColor: colorMain900,
              labelColor: colorMain900,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              tabs: [
                Tab(icon: Icon(Icons.sports_tennis), text: '코트 양도'),
                Tab(icon: Icon(Icons.comment), text: '라켓 후기'),
                Tab(icon: Icon(Icons.shopping_bag), text: '라켓 거래'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  RouteBoardCourt(),
                  RouteRacketOpinion(),
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
