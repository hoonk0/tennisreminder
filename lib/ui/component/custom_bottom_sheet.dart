import 'package:flutter/material.dart';
import 'package:tennisreminder_core/const/value/colors.dart';
import 'package:tennisreminder_core/const/value/gaps.dart';
import 'package:tennisreminder_core/const/value/sizes.dart';
import 'package:tennisreminder_core/const/value/text_style.dart';

class CustomBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final T selected;
  final String Function(T) displayText;
  final void Function(T) onSelect;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.displayText,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
       borderRadius: BorderRadius.circular(6.0),
          color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gaps.v16,
            // 회색 상단 핸들
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: colorGray200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        
            Gaps.v20,
            
            // 타이틀
            Text(
              title,
              style: const TS.s18w600(colorGray900),
            ),
            Gaps.v30,
            // 항목 리스트
            ...options.map((option) {
              final isSelected = option == selected;
              return ListTile(
                title: Text(
                  displayText(option),
                  style: TextStyle(
                    fontSize: Sizes.size16,
                    color: isSelected ? colorMain900 : Colors.black,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: colorMain900)
                    : null,
                onTap: () {
                  onSelect(option);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
