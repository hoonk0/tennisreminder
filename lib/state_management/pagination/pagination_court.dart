import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tennisreminder_core/const/model/moderl_filter_all_courts.dart';

import '../../const/static/global.dart';
import '../../ui/component/retainable_scroll_controller.dart';
import '../future/future_fetch.dart';
import '../model_base/model_base_court.dart';
import '../providers/providers.dart';


class PaginationCourt extends ConsumerStatefulWidget {
  final ModelCourtFilter filter;

  const PaginationCourt({super.key, required this.filter});

  @override
  ConsumerState<PaginationCourt> createState() => _PaginationCourtState();
}

class _PaginationCourtState extends ConsumerState<PaginationCourt> {
  final RetainableScrollController rsc = RetainableScrollController();

  @override
  void initState() {
    super.initState();

    FutureFetch.fetchCourtAll(filter: widget.filter);

    rsc.addListener(() {
      if (rsc.position.maxScrollExtent - rsc.offset < 300) {
        Global.throttler.run(() {
          FutureFetch.fetchCourtAll(filter: widget.filter);
        });
      }
    });
  }

  @override
  void dispose() {
    rsc.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final courtState = ref.watch(providerCourtAll(widget.filter));

    if (courtState is CourtLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (courtState is CourtError) {
      return Center(child: Text(courtState.message));
    }

    final pState = courtState as CourtNormal;
    final courts = pState.listCourt;

    return ListView.builder(
      controller: rsc,
      itemCount: courts.length + 1,
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, index) {
        if (index == courts.length) {
          return pState is CourtFetchMore
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink();
        }

        final court = courts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                court.imageUrls?.isNotEmpty == true
                    ? court.imageUrls!.first
                    : 'assets/images/mainicon.png',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(court.courtName),
            subtitle: const Text('10km 이내 위치'),
          ),
        );
      },
    );
  }
}
