import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import '../../const/static/global.dart';
import '../../service/stream/stream_me.dart';
import '../tab/tab_favorite.dart';
import '../tab/tab_home.dart';
import '../tab/tab_notification.dart';
import '../tab/tab_profile.dart';
import '../ui/component/main_app_bar.dart';

class RouteMain extends StatefulWidget {
  const RouteMain({super.key});

  @override
  State<RouteMain> createState() => _RouteMainState();
}

class _RouteMainState extends State<RouteMain> {
  late final PageController pc;

  @override
  void initState() {
    super.initState();
    Global.tabIndexNotifier.value = 0;
    pc = PageController(initialPage: 0);
    Global.tabIndexNotifier.addListener(_onTabIndexChanged);
  }

  void _onTabIndexChanged() {
    final newIndex = Global.tabIndexNotifier.value;
    final currentPage = pc.page ?? 0;

    ///1넘으면 즉시이동, 1칸이면 부드러운이동
    if ((newIndex - currentPage).abs() > 1) {
      pc.jumpToPage(newIndex);
    } else {
      pc.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  void dispose() {
    Global.tabIndexNotifier.removeListener(_onTabIndexChanged);
    pc.dispose();
    StreamMe.streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MainAppBar(title: '테코알'),
      ),
      backgroundColor: colorWhite,
      body: SafeArea(
        child: PageView(
          controller: pc,
          //physics: const NeverScrollableScrollPhysics(), // 사용자 스크롤 비활성
          children: const [
            TabHome(), // 0
            TabFavorite(), // 2
            TabNotification(), //3
            TabProfile(), // 4
          ],
          onPageChanged: (index) {
            Global.tabIndexNotifier.value = index; // 내비게이션 → notifier 동기화
          },
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: Global.tabIndexNotifier,
        builder: (context, currentIndex, child) {
          return Row(
            children: List.generate(
              4,
                  (index) =>
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Global.tabIndexNotifier.value =
                            index; // 내비게이션 클릭 → notifier 변경
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: colorGray200)),
                          color: Colors.transparent,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            index == 0
                                ? Icon(
                              Icons.home_outlined,
                              size: 24,
                              color: currentIndex == index
                                  ? colorMain900
                                  : colorGray500,
                            )
                                : index == 1 ? Icon(
                              size: 24,
                              Icons.favorite_border,
                              color: currentIndex == index
                              ? colorMain900
                              : colorGray500,) : index == 2 ? Icon(
                              size: 24,
                              Icons.notifications_none,
                              color: currentIndex == index
                                  ? colorMain900
                                  : colorGray500,)
                                : Icon(
                              size: 24,
                              Icons.person_2_outlined,
                              color: currentIndex == index
                                  ? colorMain900
                                  : colorGray500,),

                            Gaps.v5,
                            Text(
                              index == 0
                                  ? '홈'
                                  : index == 1
                                  ? '선호코트'
                                  : index == 2
                                  ? '알람신청'
                                  : '마이페이지',
                              style: TextStyle(
                                color:
                                currentIndex == index
                                    ? colorMain900
                                    : colorGray500,
                                fontWeight:
                                currentIndex == index
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }
}
