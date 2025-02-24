class Scan {
  final String id;
  final String title;
  final String content;
  final String contentPreview;
  final String thumbnailUrl;
  final DateTime date;

  Scan({
    required this.id,
    required this.title,
    required this.content,
    required this.contentPreview,
    required this.thumbnailUrl,
    required this.date,
  });

  String get formattedDate => 
    '${date.day}/${date.month}/${date.year}';
  
  String get formattedDateTime => 
    '${formattedDate} ${date.hour}h${date.minute}';
}