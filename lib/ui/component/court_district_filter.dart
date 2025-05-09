import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/value/enum.dart';
import 'package:tennisreminder_core/utils_enum/utils_enum.dart';

import 'custom_dropdown.dart';

class CourtDistrictFilter extends StatefulWidget {
  final SeoulDistrict? selected;
  final void Function(SeoulDistrict?) onChanged;

  const CourtDistrictFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<CourtDistrictFilter> createState() => _CourtDistrictFilterState();
}

class _CourtDistrictFilterState extends State<CourtDistrictFilter> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: CustomDropdown<SeoulDistrict>(
        value: widget.selected,
        hint: const Text('구 선택'),
        items: SeoulDistrict.values.map((district) {
          return DropdownMenuItem<SeoulDistrict>(
            value: district,
            child: Text(UtilsEnum.getNameFromSeoulDistrict(district)),
          );
        }).toList(),
        onChanged: widget.onChanged,
      ),
    );
  }
}