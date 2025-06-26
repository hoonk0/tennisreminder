import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

import '../../../component/basic_button.dart';
import '../../route_splash.dart';

class RouteAuthSignUpDetail extends StatelessWidget {
  const RouteAuthSignUpDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              SvgPicture.asset(
                'assets/images/greencheck.svg',
                width: 115,
                height: 111,
              ),
              Gaps.v20,
              const Text('가입 완료', style: TS.s16w500(colorGray600)),
              Gaps.v6,
              const Text(
                '환영합니다!',
                style: TS.s24w600(colorGray900),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: BasicButton(title: '시작하기', onTap: (){Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const RouteSplash()));}),
              ),
              Gaps.v16
            ],
          ),
        ),
      ),
    );
  }
}
