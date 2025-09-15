import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/dimensions.dart';

enum BonusFilter { disponibili, scaduti, senzaDeposito, completati }

class FiltersBar extends StatelessWidget {
  final String searchText;
  final ValueChanged<String> onSearchChanged;
  final Set<BonusFilter> selected;
  final ValueChanged<Set<BonusFilter>> onSelectedChanged;

  const FiltersBar({
    super.key,
    required this.searchText,
    required this.onSearchChanged,
    required this.selected,
    required this.onSelectedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search
        TextField(
          decoration: const InputDecoration(
            hintText: 'Cerca bonus...',
            prefixIcon: Icon(Icons.search, color: AppColors.subtleGray),
          ),
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        // Filters (single-select, left-aligned)
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip('Disponibili', BonusFilter.disponibili),
              _chip('Scaduti', BonusFilter.scaduti),
              _chip('Senza deposito', BonusFilter.senzaDeposito),
              _chip('Completati', BonusFilter.completati),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, BonusFilter f) {
    final isSel = selected.contains(f);
    return ChoiceChip(
      selected: isSel,
      label: Text(label),
      onSelected: (_) {
        // Single-select: selecting any filter deselects all others
        onSelectedChanged({f});
      },
      selectedColor: AppColors.brandBlue.withOpacity(0.3),
      backgroundColor: Colors.white.withOpacity(0.06),
      labelStyle: TextStyle(
        color: isSel ? Colors.white : AppColors.subtleGray,
        fontWeight: FontWeight.w700,
      ),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.white.withOpacity(0.14)),
      ),
    );
  }
}