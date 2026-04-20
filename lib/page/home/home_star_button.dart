import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/page/explore/star_button_controller.dart';

class HomeStarButton extends StatelessWidget {
  HomeStarButton(this.author, this.repoName, {super.key})
    : controller = StarButtonController(author, repoName);

  final String author;
  final String repoName;
  final StarButtonController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.loading.value;
      final hasStarred = controller.hasStarred.value;

      return TextButton(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 32),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          foregroundColor: hasStarred ? Colors.grey[600] : Colors.amber,
        ),
        onPressed: isLoading
            ? null
            : () {
                if (hasStarred) {
                  controller.requestUnstarRepo();
                } else {
                  controller.requestStarRepo();
                }
              },
        child: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                hasStarred ? 'Unstar' : 'Star',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
      );
    });
  }
}
