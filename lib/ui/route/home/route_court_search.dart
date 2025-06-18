import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tennisreminder_core/const/model/model_court.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/keys.dart';
import '../../component/card_court_inform.dart';
import '../../component/main_app_bar.dart';
import 'route_court_information.dart';

class RouteCourtSearch extends StatefulWidget {
  const RouteCourtSearch({super.key});

  @override
  State<RouteCourtSearch> createState() => _RouteCourtSearchState();
}

class _RouteCourtSearchState extends State<RouteCourtSearch> {
  final TextEditingController _tecSearch = TextEditingController();
  final ValueNotifier<List<ModelCourt>> _searchResults = ValueNotifier([]);
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  Future<void> _onSearch(String text) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(keyCourt)
        .get();

    final results = snapshot.docs
        .map((e) => ModelCourt.fromJson(e.data()))
        .where((court) => court.courtName.toLowerCase().contains(text.toLowerCase()))
        .toList();

    _searchResults.value = results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MainAppBar(title: '테코알'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorGray300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: colorGray300),
                  Gaps.h8,
                  Expanded(
                    child: TextField(
                      controller: _tecSearch,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: '',
                        isDense: true,
                        border: InputBorder.none,
                      ),
                      onChanged: _onSearch,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, color: colorGray300),
                    onPressed: () {
                      _tecSearch.clear();
                      _searchResults.value = [];
                    },
                  ),
                ],
              ),
            ),
            Gaps.v20,
            Expanded(
              child: ValueListenableBuilder<List<ModelCourt>>(
                valueListenable: _searchResults,
                builder: (context, courts, _) {
                  return ListView.builder(
                    itemCount: courts.length,
                    itemBuilder: (context, index) {
                      final court = courts[index];
                      return GestureDetector(
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) => RouteCourtInformation(court: court)));
                          },
                          child: CardCourtInform(court: court));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
