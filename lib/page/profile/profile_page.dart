import 'package:flutter/material.dart';
import 'package:jithub_flutter/core/widget/clickable.dart';
import 'package:jithub_flutter/core/widget/container/shadow_container.dart';
import 'package:jithub_flutter/page/home/home_page.dart';
import 'package:jithub_flutter/router/router.dart';
import 'package:jithub_flutter/widget/network_image.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ShadowContainer(
                child: Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: const DefaultNetworkImage(
                              "https://avatars.githubusercontent.com/u/13328707?s=200&v=4",
                              width: 80,
                              height: 80,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "aJIEw",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[850]),
                            ),
                          ),
                          Expanded(
                              child: Container(
                            // color: Colors.cyan[100],
                            alignment: Alignment.centerRight,
                            child: Clickable(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(Icons.settings,
                                    color: Colors.grey[850], size: 22),
                              ),
                              onPressed: () {
                                XRouter.push(XRouter.settingsPage);
                              },
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Be open to evreything and atached to nothig.",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[850]),
                      ),
                      const SizedBox(height: 10),
                      buildIconText(
                          'Hangzhou',
                          const Icon(
                            Icons.pin_drop_outlined,
                            size: 14,
                          )),
                      const SizedBox(height: 8),
                      buildIconText(
                          '@ajiew42',
                          const Icon(
                            Icons.email,
                            size: 14,
                          )),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people_alt_outlined,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '16',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'followers',
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.circle,
                            size: 5,
                            color: Colors.grey[850],
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '172',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'followers',
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ShadowContainer(
                  child: Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.book,
                          size: 16,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Contribution",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[850],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text.rich(TextSpan(
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[850]),
                            children: const [
                              TextSpan(
                                style: TextStyle(fontWeight: FontWeight.bold),
                                children: [
                                  TextSpan(
                                    text: '48',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  TextSpan(text: ' contributions')
                                ],
                              ),
                              TextSpan(text: ' in the last 90 days'),
                            ])),
                        Icon(
                          Icons.question_mark,
                          size: 14,
                          color: Colors.grey[700],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // graph
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
