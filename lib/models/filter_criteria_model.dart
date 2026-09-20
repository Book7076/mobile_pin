class FilterCriteriaModel {
  final List<String> selectedCategories;
  final List<int> selectedPriceTiers; // 1, 2, 3
  final double? maxBudget; // Flow 4: specific budget in THB (e.g. 50, 100, 300...)
  final double radiusKm;
  final double minRating;
  final bool openNowOnly;
  final String scope; // 'all' (ร้านทั้งหมด), 'favorites' (ร้านโปรด), 'visited' (ร้านที่เคยไป)
  final bool matchAllCategories; // false = OR match, true = AND match

  FilterCriteriaModel({
    this.selectedCategories = const [],
    this.selectedPriceTiers = const [1, 2, 3],
    this.maxBudget,
    this.radiusKm = 10.0,
    this.minRating = 0.0,
    this.openNowOnly = false,
    this.scope = 'all',
    this.matchAllCategories = false,
  });

  FilterCriteriaModel copyWith({
    List<String>? selectedCategories,
    List<int>? selectedPriceTiers,
    double? maxBudget,
    bool clearBudget = false,
    double? radiusKm,
    double? minRating,
    bool? openNowOnly,
    String? scope,
    bool? matchAllCategories,
  }) {
    return FilterCriteriaModel(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedPriceTiers: selectedPriceTiers ?? this.selectedPriceTiers,
      maxBudget: clearBudget ? null : (maxBudget ?? this.maxBudget),
      radiusKm: radiusKm ?? this.radiusKm,
      minRating: minRating ?? this.minRating,
      openNowOnly: openNowOnly ?? this.openNowOnly,
      scope: scope ?? this.scope,
      matchAllCategories: matchAllCategories ?? this.matchAllCategories,
    );
  }
}

