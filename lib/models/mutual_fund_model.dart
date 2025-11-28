class MutualFundScheme {
  final int schemeCode;
  final String schemeName;

  MutualFundScheme({
    required this.schemeCode,
    required this.schemeName,
  });

  factory MutualFundScheme.fromJson(Map<String, dynamic> json) {
    return MutualFundScheme(
      schemeCode: json['schemeCode'] as int,
      schemeName: json['schemeName'] as String,
    );
  }
}

class NavData {
  final String date;
  final double nav;

  NavData({
    required this.date,
    required this.nav,
  });

  factory NavData.fromJson(Map<String, dynamic> json) {
    return NavData(
      date: json['date'] as String,
      nav: double.tryParse(json['nav'].toString()) ?? 0.0,
    );
  }
}

class MutualFundDetails {
  final MutualFundScheme meta;
  final List<NavData> data;

  MutualFundDetails({
    required this.meta,
    required this.data,
  });

  factory MutualFundDetails.fromJson(Map<String, dynamic> json) {
    return MutualFundDetails(
      meta: MutualFundScheme(
        schemeCode: json['meta']['scheme_code'] as int,
        schemeName: json['meta']['scheme_name'] as String,
      ),
      data: (json['data'] as List)
          .map((e) => NavData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
