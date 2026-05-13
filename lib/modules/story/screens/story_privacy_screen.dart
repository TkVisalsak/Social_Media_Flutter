import 'package:flutter/material.dart';

class StoryPrivacyScreen extends StatefulWidget {
  const StoryPrivacyScreen({super.key});

  @override
  State<StoryPrivacyScreen> createState() =>
      _StoryPrivacyScreenState();
}

class _StoryPrivacyScreenState
    extends State<StoryPrivacyScreen> {

  String selectedPrivacy =
      "Close Friends";

  bool storyArchive = true;

  String allowReplies =
      "Everyone";

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      Colors.white,

      body: SafeArea(

        child: Column(
          children: [

            /// TOP BAR
            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),

              child: Stack(
                alignment: Alignment.center,

                children: [

                  /// BACK BUTTON
                  Align(
                    alignment: Alignment.centerLeft,

                    child: GestureDetector(

                      onTap: () {
                        Navigator.pop(context);
                      },

                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,

                        size: 22,

                        color: Colors.black,
                      ),
                    ),
                  ),

                  /// TITLE
                  const Text(
                    "Story privacy",

                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            /// DIVIDER
            Container(
              height: 1,
              color: Colors.black12,
            ),

            Expanded(
              child: ListView(
                padding:
                const EdgeInsets.all(16),

                children: [

                  /// TITLE
                  const Text(
                    "Story audience",

                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Choose who can view your story before it disappears after 24 hours.",

                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// PUBLIC
                  buildPrivacyTile(
                    icon: Icons.public_rounded,

                    title: "Public",

                    subtitle:
                    "Anyone can view your story",

                    value: "Public",
                  ),

                  const SizedBox(height: 10),

                  /// FRIENDS
                  buildPrivacyTile(
                    icon:
                    Icons.people_alt_outlined,

                    title: "Friends",

                    subtitle:
                    "Only your friends can view",

                    value: "Friends",
                  ),

                  const SizedBox(height: 10),

                  /// CLOSE FRIENDS
                  buildPrivacyTile(
                    icon:
                    Icons.favorite_border_rounded,

                    title: "Close Friends",

                    subtitle:
                    "Selected people only",

                    value: "Close Friends",
                  ),

                  const SizedBox(height: 10),

                  /// CUSTOM
                  buildPrivacyTile(
                    icon:
                    Icons.person_outline_rounded,

                    title: "Custom",

                    subtitle:
                    "Choose specific people",

                    value: "Custom",
                  ),

                  const SizedBox(height: 18),

                  Container(
                    height: 1,
                    color: Colors.black12,
                  ),

                  const SizedBox(height: 18),

                  const SizedBox(height: 20),

                  /// HIDE STORY
                  GestureDetector(

                    onTap: () {

                      /// HIDE USERS LATER
                    },

                    child: buildSettingTile(
                      title:
                      "Hide story from",

                      subtitle:
                      "18 people hidden",

                      trailing:
                      Icons.chevron_right_rounded,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ARCHIVE
                  AnimatedContainer(

                    duration:
                    const Duration(
                        milliseconds: 180),

                    padding:
                    const EdgeInsets.all(16),

                    decoration: BoxDecoration(

                      color:
                      const Color(0xFFF7F7F7),

                      borderRadius:
                      BorderRadius.circular(20),
                    ),

                    child: Row(
                      children: [

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(
                                "Story archive",

                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                "Automatically save stories",

                                style: TextStyle(
                                  color:
                                  Colors.black54,

                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Switch(

                          value: storyArchive,

                          activeThumbColor:
                          Colors.black,

                          onChanged: (value) {

                            setState(() {

                              storyArchive =
                                  value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// REPLIES
                  GestureDetector(

                    onTap: () {

                      showModalBottomSheet(

                        context: context,

                        backgroundColor:
                        Colors.white,

                        shape:
                        const RoundedRectangleBorder(

                          borderRadius:
                          BorderRadius.vertical(
                            top:
                            Radius.circular(28),
                          ),
                        ),

                        builder: (context) {

                          return Padding(
                            padding:
                            const EdgeInsets.all(20),

                            child: Column(
                              mainAxisSize:
                              MainAxisSize.min,

                              children: [

                                buildReplyOption(
                                  "Everyone",
                                ),

                                buildReplyOption(
                                  "Friends",
                                ),

                                buildReplyOption(
                                  "No one",
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },

                    child: buildSettingTile(
                      title:
                      "Allow replies",

                      subtitle:
                      allowReplies,

                      trailing:
                      Icons.chevron_right_rounded,
                    ),
                  ),

                  const SizedBox(height: 26),

                  /// SAVE BUTTON
                  SizedBox(
                    height: 54,

                    child: ElevatedButton(

                      style:
                      ElevatedButton.styleFrom(

                        backgroundColor:
                        Colors.black,

                        elevation: 0,

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                        ),
                      ),

                      onPressed: () {

                        Navigator.pop(
                          context,
                        );
                      },

                      child: const Text(
                        "Save",

                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.w700,

                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPrivacyTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {

    final bool isSelected =
        selectedPrivacy == value;

    return GestureDetector(

      onTap: () {

        setState(() {

          selectedPrivacy =
              value;
        });
      },

      child: AnimatedScale(

        duration:
        const Duration(milliseconds: 220),

        curve: Curves.easeOutBack,

        scale:
        isSelected ? 1 : 0.985,

        child: AnimatedContainer(

          duration:
          const Duration(milliseconds: 220),

          padding:
          const EdgeInsets.all(13),

          decoration: BoxDecoration(

            color: isSelected
                ? Colors.black
                : const Color(0xFFF7F7F7),

            borderRadius:
            BorderRadius.circular(20),

            boxShadow: isSelected

                ? [

              BoxShadow(
                color:
                Colors.black.withValues(
                  alpha: 0.08,
                ),

                blurRadius: 14,

                offset:
                const Offset(0, 6),
              ),
            ]

                : [],
          ),

          child: Row(
            children: [

              Container(
                width: 42,
                height: 42,

                decoration: BoxDecoration(

                  color: isSelected
                      ? Colors.white12
                      : Colors.white,

                  shape: BoxShape.circle,
                ),

                child: Icon(
                  icon,

                  color: isSelected
                      ? Colors.white
                      : Colors.black,

                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(
                      title,

                      style: TextStyle(

                        fontSize: 16,

                        fontWeight:
                        FontWeight.w700,

                        color: isSelected
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,

                      style: TextStyle(

                        fontSize: 13,

                        color: isSelected
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              AnimatedContainer(

                duration:
                const Duration(milliseconds: 180),

                width: 26,
                height: 26,

                decoration: BoxDecoration(

                  shape: BoxShape.circle,

                  border: Border.all(

                    color: isSelected
                        ? Colors.white
                        : Colors.black26,

                    width: 2,
                  ),

                  color: isSelected
                      ? Colors.white
                      : Colors.transparent,
                ),

                child: isSelected

                    ? const Icon(
                  Icons.check,

                  size: 14,

                  color: Colors.black,
                )

                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSettingTile({
    required String title,
    required String subtitle,
    required IconData trailing,
  }) {

    return AnimatedContainer(

      duration:
      const Duration(milliseconds: 180),

      padding:
      const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color:
        const Color(0xFFF7F7F7),

        borderRadius:
        BorderRadius.circular(20),
      ),

      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,

                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            trailing,
            size: 22,
            color: Colors.black45,
          ),
        ],
      ),
    );
  }

  Widget buildReplyOption(
      String value) {

    final bool isSelected =
        allowReplies == value;

    return GestureDetector(

      onTap: () {

        setState(() {

          allowReplies = value;
        });

        Navigator.pop(context);
      },

      child: Container(

        margin:
        const EdgeInsets.only(
          bottom: 10,
        ),

        padding:
        const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: isSelected
              ? Colors.black
              : const Color(0xFFF5F5F5),

          borderRadius:
          BorderRadius.circular(18),
        ),

        child: Row(
          children: [

            Expanded(
              child: Text(
                value,

                style: TextStyle(

                  fontSize: 15,

                  fontWeight:
                  FontWeight.w600,

                  color: isSelected
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),

            if (isSelected)

              const Icon(
                Icons.check,
                size: 18,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}