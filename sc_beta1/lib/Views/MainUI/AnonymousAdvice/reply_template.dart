class Reply {
  final String id;
  final String replyTo;
  final int age;
  final String gender;
  final String text;
  final String adviceText;
  Reply(
      {required this.replyTo,
      required this.adviceText,
      required this.id,
      required this.text,
      required this.age,
      required this.gender});
}
