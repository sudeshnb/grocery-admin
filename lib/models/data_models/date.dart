class Date {
  final String title;
  final String firstDay;
  final String lastDay;

  Date({required this.title, required this.firstDay, required this.lastDay});

  @override
  bool operator ==(Object other) {
    if (other is Date) {
      return (firstDay == other.firstDay) && (lastDay == other.lastDay);
    } else {
      return false;
    }
  }

  @override
  int get hashCode => super.hashCode;
}
