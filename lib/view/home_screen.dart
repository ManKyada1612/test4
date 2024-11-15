import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test4/controller/home_screen_controller.dart';
import 'package:test4/view/detailScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeScreenController controller = Get.put(HomeScreenController());

  @override
  void initState() {
    super.initState();
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        return ListView.builder(
          controller: controller.scrollController,
          itemCount: controller.posts.length,
          itemBuilder: (context, index) {
            final post = controller.posts[index];
            return GestureDetector(
              onTap: () {
                controller.pauseTimer(post.id);
                controller.markAsRead(post);
                Get.to(() => DetailScreen(postId: post.id));
              },
              child: Container(
                height: 80,
                color: post.isRead ? Colors.white : Colors.yellow[100],
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(child: Text(post.title)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer, color: Colors.blue),
                        Text('${post.remainingTime}s'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    controller. scrollController.dispose();
    super.dispose();
  }
}
