class Attachment {
  Attachment({
    required this.id,
    required this.transactionId,
    required this.filePath,
    required this.mimeType,
  });

  final String id;
  final String transactionId;
  final String filePath;
  final String mimeType;
}
