import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

class CustomDropdown<T> extends DropdownButtonHideUnderline {
  CustomDropdown({
    super.key,
    T? value,
    Widget? hint,
    List<DropdownMenuItem<T>>? items,
    void Function(T?)? onChanged,
    Color colorBg = colorWhite,
    double radius = 8,
  }) : super(
          child: DropdownButton2(
            isExpanded: true,
            value: value,
            hint: hint,
            items: items,
            onChanged: onChanged,
            underline: SizedBox(),
            style: const TS.s16w400(colorBlack),
            buttonStyleData: ButtonStyleData(
              padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
              height: 48,
              decoration: BoxDecoration(
                color: colorBg,
                borderRadius: BorderRadius.all(Radius.circular(radius)),
                border: Border.all(color: colorGray300),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              elevation: 0,
              maxHeight: 400,
              openInterval: const Interval(0.1, 0.4),
              offset: const Offset(0, -5),
              decoration: BoxDecoration(
                color: colorBg,
                borderRadius: BorderRadius.all(Radius.circular(radius)),
                border: Border.all(color: colorGray300),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 48,
              padding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        );
}
