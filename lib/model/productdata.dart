class Post {
  final int id;
  final String title;
  bool isRead;
  int remainingTime;
  bool isTimerActive; // Add this to track if a timer is active for the post

  Post({
    required this.id,
    required this.title,
    this.isRead = false,
    required this.remainingTime,
    this.isTimerActive = false, // Default to false
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      remainingTime: (10 + (json['id'] % 3) * 10).toInt(), // Random time: 10, 20, or 30
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isRead': isRead,
        'remainingTime': remainingTime,
      };
}
