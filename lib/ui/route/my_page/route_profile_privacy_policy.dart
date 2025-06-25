import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../component/main_app_bar.dart';

class RouteProfilePrivacyPolicy extends StatefulWidget {
  const RouteProfilePrivacyPolicy({super.key});

  @override
  State<RouteProfilePrivacyPolicy> createState() => _RouteProfilePrivacyPolicyState();
}

class _RouteProfilePrivacyPolicyState extends State<RouteProfilePrivacyPolicy> with AutomaticKeepAliveClientMixin {
  late final WebViewController controller1;
  late final WebViewController controller2;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer()),
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();


    controller1 = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(colorWhite)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {
            debugPrint("onPageFinished");
            await controller1.runJavaScript('caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            return NavigationDecision.navigate;
          },
        ),
      )
   /*   ..clearCache() // 캐시 지우기
      ..clearLocalStorage()*/
      ..loadRequest(Uri.parse('https://tennisreminder-ecf66.web.app/privacy_policy.html'));

    controller2 = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(colorWhite)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {
            await controller1.runJavaScript('caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            return NavigationDecision.navigate;
          },
        ),
      )
 /*     ..clearCache() // 캐시 지우기
      ..clearLocalStorage()*/
      ..loadRequest(Uri.parse('https://tennisreminder-ecf66.web.app/terms_of_service.html'));
    onInit();
  }

  Future<void> onInit() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('개인정보처리방침/약관'),
          bottom: TabBar(
            indicatorColor: colorMain900,
            indicatorWeight: 2.5,
            labelColor: colorMain900,
            unselectedLabelColor: colorGray500,
            labelStyle: TS.s18w600(colorMain900),
            unselectedLabelStyle: TS.s18w600(colorGray500),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            tabs: [
              Tab(text: '개인정보처리방침'),
              Tab(text: '이용약관'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              WebViewWidget(
                controller: controller1,
                gestureRecognizers: gestureRecognizers,
              ),
              WebViewWidget(
                controller: controller2,
                gestureRecognizers: gestureRecognizers,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
