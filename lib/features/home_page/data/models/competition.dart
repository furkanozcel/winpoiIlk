class Competition {
  final String id;
  final String title;
  final String description;
  final String prize;
  final DateTime dateTime;
  final double entryFee;
  final String imageUrl;
  final int participantCount;

  Competition({
    required this.id,
    required this.title,
    required this.description,
    required this.prize,
    required this.dateTime,
    required this.entryFee,
    required this.imageUrl,
    this.participantCount = 0,
  });
}
