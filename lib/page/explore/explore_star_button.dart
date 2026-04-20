import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jithub_flutter/page/explore/star_button_controller.dart';

class ExploreStarButton extends StatefulWidget {
  ExploreStarButton(this.author, this.repoName, {super.key})
    : controller = StarButtonController(author, repoName);

  final String author;
  final String repoName;
  final StarButtonController controller;

  @override
  State<ExploreStarButton> createState() => _ExploreStarButtonState();
}

class _ExploreStarButtonState extends State<ExploreStarButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Obx(() {
        final loggedIn = widget.controller.isLoggedIn.value;
        final isLoading = widget.controller.loading.value;
        final hasStarred = widget.controller.hasStarred.value;
        final backgroundColor = hasStarred
            ? Colors.amber.withValues(alpha: 0.18)
            : Colors.amber.withValues(alpha: 0.08);
        const borderColor = Colors.amber;

        return loggedIn
            ? Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    if (isLoading) {
                      return;
                    }

                    if (hasStarred) {
                      widget.controller.requestUnstarRepo();
                    } else {
                      widget.controller.requestStarRepo();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: borderColor.withValues(alpha: 0.75),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.amber,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            hasStarred
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 22,
                          ),
                  ),
                ),
              )
            : const SizedBox.shrink();
      }),
    );
  }
}
