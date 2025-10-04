class DateRange {
  const DateRange({required this.startEpochMs, required this.endEpochMs})
      : assert(startEpochMs <= endEpochMs, 'Start must be before end');

  final int startEpochMs;
  final int endEpochMs;
}
