enum AnalyticsPeriod {
  month('month'),
  year('year'),
  all('all');

  const AnalyticsPeriod(this.queryValue);

  final String queryValue;
}
