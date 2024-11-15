import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test4/model/productdata.dart';
import 'package:flutter/widgets.dart';  
class HomeScreenController extends GetxController {
  var posts = <Post>[].obs;  
  var isLoading = true.obs;   
  final timers = <int, Timer?>{}; 
  final storage = GetStorage();     
  final ScrollController scrollController = ScrollController(); 

  @override
  void onInit() {
    super.onInit();
    loadPosts();
   
    scrollController.addListener(_handleVisibility);
  }

  @override
  void onClose() {
    super.onClose();
    scrollController.removeListener(_handleVisibility); 
  }
  Future loadPosts() async {
    isLoading(true);

    var savedData = storage.read<List>('posts');
    if (savedData != null) {
      posts.assignAll(savedData.map((data) => Post.fromJson(data)).toList());
    } else {
      await fetchPostsFromApi();
    }

    isLoading(false);  
   WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimersForVisiblePosts(); 
    });
  }

  // Handle visibility of posts based on scroll position
  void _handleVisibility() {
    final firstVisibleIndex = (scrollController.offset / 80).floor();
    final lastVisibleIndex = firstVisibleIndex +
        (MediaQuery.of(Get.context!).size.height / 80).ceil();

    print("First visible index: $firstVisibleIndex, Last visible index: $lastVisibleIndex");

    for (var i = 0; i < posts.length; i++) {
      final post = posts[i];

     
      if (i >= firstVisibleIndex && i <= lastVisibleIndex) {
        if (!post.isTimerActive) {
          print("Starting timer for post: ${post.id}");
          startTimer(post.id); 
        }
      } else {
        if (post.isTimerActive) {
          print("Pausing timer for post: ${post.id}");
          pauseTimer(post.id); 
        }
      }
    }
  }

  void startTimer(int postId) {
    final post = posts.firstWhere((post) => post.id == postId);

    if (!post.isTimerActive) {
      print("Starting timer for post: $postId");
      post.isTimerActive = true;

     
      timers[postId] = Timer.periodic(Duration(seconds: 1), (timer) {
        if (post.remainingTime > 0) {
          post.remainingTime--;
          posts.refresh();  
        } else {
          timer.cancel();
          timers[postId] = null;
          post.isTimerActive = false;
          print("Timer finished for post $postId");
        }
      });
    }
  }

  void pauseTimer(int postId) {
    final post = posts.firstWhere((post) => post.id == postId);
    timers[postId]?.cancel();
    timers[postId] = null;
    post.isTimerActive = false;
    print("Timer paused for post: $postId");
  }

  Future<void> fetchPostsFromApi() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      if (response.statusCode == 200) {
        var fetchedPosts = (json.decode(response.body) as List)
            .map((data) => Post.fromJson(data))
            .toList();
        posts.assignAll(fetchedPosts);
        savePosts();
      } else {
        print("Failed to load posts from API");
      }
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }
  void markAsRead(Post post) {
    post.isRead = true;
    posts.refresh(); 
    savePosts();
  }
  void savePosts() {
    storage.write('posts', posts.map((post) => post.toJson()).toList());
  }

  void _startTimersForVisiblePosts() {
    final firstVisibleIndex = (scrollController.offset / 80).floor();
    final lastVisibleIndex = firstVisibleIndex +
        (MediaQuery.of(Get.context!).size.height / 80).ceil();

    for (var i = firstVisibleIndex; i <= lastVisibleIndex; i++) {
      if (i < posts.length) {
        final post = posts[i];
        if (!post.isTimerActive) {
          startTimer(post.id);
        }
      }
    }
  }
}
