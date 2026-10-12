class FilterCriteriaModel {
  final List<String> selectedCategories;
  final List<int> selectedPriceTiers; // 1, 2, 3
  final double minBudget; // Flow 4: min budget in THB (default 50.0)
  final double? maxBudget; // Flow 4: specific budget in THB (e.g. 50, 100, 300, 570...)
  final int? cuisineTypeId; // Flow 3: mapped cuisine_type_id for swipe_sessions
  final double radiusKm;
  final double minRating;
  final bool openNowOnly;
  final String scope; // 'all' (ร้านทั้งหมด), 'favorites' (ร้านโปรด), 'visited' (ร้านที่เคยไป)
  final bool matchAllCategories; // false = OR match, true = AND match

  FilterCriteriaModel({
    this.selectedCategories = const [],
    this.selectedPriceTiers = const [1, 2, 3],
    this.minBudget = 50.0,
    this.maxBudget,
    this.cuisineTypeId,
    this.radiusKm = 10.0,
    this.minRating = 0.0,
    this.openNowOnly = false,
    this.scope = 'all',
    this.matchAllCategories = false,
  });

  FilterCriteriaModel copyWith({
    List<String>? selectedCategories,
    List<int>? selectedPriceTiers,
    double? minBudget,
    double? maxBudget,
    bool clearBudget = false,
    int? cuisineTypeId,
    double? radiusKm,
    double? minRating,
    bool? openNowOnly,
    String? scope,
    bool? matchAllCategories,
  }) {
    return FilterCriteriaModel(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedPriceTiers: selectedPriceTiers ?? this.selectedPriceTiers,
      minBudget: clearBudget ? 50.0 : (minBudget ?? this.minBudget),
      maxBudget: clearBudget ? null : (maxBudget ?? this.maxBudget),
      cuisineTypeId: cuisineTypeId ?? this.cuisineTypeId,
      radiusKm: radiusKm ?? this.radiusKm,
      minRating: minRating ?? this.minRating,
      openNowOnly: openNowOnly ?? this.openNowOnly,
      scope: scope ?? this.scope,
      matchAllCategories: matchAllCategories ?? this.matchAllCategories,
    );
  }
}

