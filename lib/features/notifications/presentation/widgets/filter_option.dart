import 'package:flutter/material.dart';

class FilterOption extends StatelessWidget {
  final String filterName;
  final String selectedFilter;
  final Function(String) onChanged;

  const FilterOption({
    super.key,
    required this.filterName,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedFilter.toLowerCase() == filterName.toLowerCase();

    return InkWell(
      onTap: () => onChanged(filterName.toLowerCase()),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  filterName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: const Color(0xFF333333),
                      ),
                ),
                const SizedBox(width: 8),
               
              ],
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00838F),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF00838F) : Colors.white,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}