enum CustomFieldType {
  text('TEXT'),
  email('EMAIL'),
  number('NUMBER'),
  description('DESCRIPTION'),
  date('DATE'),
  dateTime('DATE_TIME'),
  time('TIME'),
  timeRange('TIME_RANGE'),
  select('SELECT');

  final String apiValue;

  const CustomFieldType(this.apiValue);

  static CustomFieldType fromApi(String value) {
    final normalized = value.trim().toUpperCase();
    for (final t in CustomFieldType.values) {
      if (t.apiValue == normalized) return t;
    }
    return CustomFieldType.text;
  }
}
