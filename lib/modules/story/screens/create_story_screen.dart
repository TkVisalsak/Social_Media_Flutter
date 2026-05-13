import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'story_privacy_screen.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() =>
      _CreateStoryScreenState();
}

class _CreateStoryScreenState
    extends State<CreateStoryScreen> {

  final ImagePicker picker =
  ImagePicker();

  File? selectedImage;

  bool isSelectingMultiple = false;

  List<int> selectedIndexes = [];

  Future<void> pickImage() async {

    final XFile? file =
    await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (file != null) {

      setState(() {

        selectedImage =
            File(file.path);
      });
    }
  }

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
                horizontal: 12,
                vertical: 10,
              ),

              child: Row(
                children: [

                  GestureDetector(

                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: const Icon(
                      Icons.close,

                      size: 30,

                      color: Colors.black,
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    "Create story",

                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  const Spacer(),

                  GestureDetector(

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                          const StoryPrivacyScreen(),
                        ),
                      );
                    },

                    child: Container(
                      width: 48,
                      height: 48,

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(16),

                        border: Border.all(
                          color: Colors.black12,
                        ),
                      ),

                      child: const Icon(
                        Icons.settings_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// MULTIPLE TOP BAR
            if (isSelectingMultiple)

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                ),

                child: Row(
                  children: [

                    /// CANCEL
                    GestureDetector(

                      onTap: () {

                        setState(() {

                          isSelectingMultiple =
                          false;

                          selectedIndexes.clear();
                        });
                      },

                      child: const Text(
                        "Cancel",

                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(),

                    /// COUNT
                    Text(

                      "${selectedIndexes.length} selected",

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    /// NEXT
                    GestureDetector(

                      onTap: () {

                        /// NEXT LATER
                      },

                      child: Container(

                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(

                          color: Colors.black,

                          borderRadius:
                          BorderRadius.circular(12),
                        ),

                        child: const Text(
                          "Next",

                          style: TextStyle(
                            color: Colors.white,

                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            /// TOP ACTIONS
          if (!isSelectingMultiple)
            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
              ),

              child: Row(
                children: [

                  Expanded(
                    child: buildTopButton(
                      icon:
                      Icons.text_fields_rounded,
                      title: "Text",
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: buildTopButton(
                      icon:
                      Icons.music_note_rounded,
                      title: "Music",
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: buildTopButton(
                      icon:
                      Icons.grid_view_rounded,
                      title: "Collage",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// GALLERY HEADER
            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
              ),

              child: Row(
                children: [

                  PopupMenuButton<String>(

                    color: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),

                    itemBuilder: (context) => [

                      const PopupMenuItem(
                        value: "gallery",

                        child: Text("Gallery"),
                      ),

                      const PopupMenuItem(
                        value: "camera",

                        child: Text("Camera"),
                      ),

                      const PopupMenuItem(
                        value: "downloads",

                        child: Text("Downloads"),
                      ),
                    ],

                    child: const Row(
                      children: [

                        Text(
                          "Gallery",

                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(width: 4),

                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 24,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  /// MULTIPLE
                  if (!isSelectingMultiple)
                  GestureDetector(

                    onTap: () {

                      setState(() {

                        isSelectingMultiple =
                        !isSelectingMultiple;
                      });
                    },

                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),

                      decoration: BoxDecoration(

                        color:
                        isSelectingMultiple
                            ? Colors.black
                            : Colors.white,

                        borderRadius:
                        BorderRadius.circular(14),

                        border: Border.all(
                          color: Colors.black,
                          width: 1.2,
                        ),
                      ),

                      child: Row(
                        children: [

                          Icon(
                            Icons.layers_rounded,

                            size: 17,

                            color:
                            isSelectingMultiple
                                ? Colors.white
                                : Colors.black,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            "Select multiple",

                            style: TextStyle(
                              fontSize: 13,

                              fontWeight:
                              FontWeight.w600,

                              color:
                              isSelectingMultiple
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// MAIN CONTENT
            Expanded(
              child: Stack(
                children: [

                  /// IMAGE PREVIEW
                  selectedImage != null

                      ? Padding(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),

                    child: Image.file(
                      selectedImage!,

                      fit: BoxFit.contain,

                      width: double.infinity,
                    ),
                  )

                  /// GALLERY GRID
                      : GridView.builder(

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),

                    itemCount:
                    galleryImages.length + 1,

                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(

                      crossAxisCount: 3,

                      crossAxisSpacing: 4,

                      mainAxisSpacing: 4,

                      childAspectRatio: 0.68,
                    ),

                    itemBuilder:
                        (context, index) {

                      /// FIRST BOX
                      if (index == 0) {

                        return GestureDetector(

                          onTap: pickImage,

                          child: Container(

                            color: Colors.grey.shade100,

                            child: const Center(
                              child: Icon(
                                Icons.add_photo_alternate,

                                size: 34,

                                color: Colors.black54,
                              ),
                            ),
                          ),
                        );
                      }

                      final bool isSelected =
                      selectedIndexes.contains(index);

                      return GestureDetector(

                        onTap: () {

                          /// MULTIPLE MODE
                          if (isSelectingMultiple) {

                            setState(() {

                              if (selectedIndexes
                                  .contains(index)) {

                                selectedIndexes
                                    .remove(index);

                              } else {

                                selectedIndexes
                                    .add(index);
                              }
                            });
                          }

                          /// SINGLE MODE
                          else {

                            ScaffoldMessenger.of(context)
                                .showSnackBar(

                              const SnackBar(
                                content:
                                Text("Single image selected"),
                              ),
                            );
                          }
                        },

                        child: AnimatedScale(

                          duration:
                          const Duration(
                              milliseconds: 180),

                          scale:
                          isSelected ? 0.94 : 1,

                          child: Stack(
                            children: [

                              Positioned.fill(

                                child:
                                AnimatedContainer(

                                  duration:
                                  const Duration(
                                      milliseconds: 180),

                                  decoration: BoxDecoration(

                                    border: isSelected

                                        ? Border.all(
                                      color: Colors.blue,
                                      width: 3,
                                    )

                                        : null,
                                  ),

                                  child: Image.asset(

                                    galleryImages[
                                    (index - 1) %
                                        galleryImages.length
                                    ],

                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              /// NUMBERED SELECT
                              if (isSelected)

                                Positioned(
                                  top: 8,
                                  right: 8,

                                  child: Container(

                                    width: 24,
                                    height: 24,

                                    decoration:
                                    const BoxDecoration(

                                      color: Colors.blue,

                                      shape:
                                      BoxShape.circle,
                                    ),

                                    child: Center(
                                      child: Text(

                                        "${selectedIndexes.indexOf(index) + 1}",

                                        style:
                                        const TextStyle(

                                          color:
                                          Colors.white,

                                          fontSize: 12,

                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  /// FLOATING CAMERA
                  Positioned(
                    right: 20,
                    bottom: 20,

                    child: GestureDetector(

                      onTap: () async {

                        final XFile? file =
                        await picker.pickImage(
                          source: ImageSource.camera,
                        );

                        if (file != null) {

                          setState(() {

                            selectedImage =
                                File(file.path);
                          });
                        }
                      },

                      child: Container(

                        width: 56,
                        height: 56,

                        decoration: BoxDecoration(

                          color: Colors.white,

                          shape: BoxShape.circle,

                          boxShadow: [

                            BoxShadow(
                              color:
                              Colors.black.withValues(
                                alpha: 0.10,
                              ),

                              blurRadius: 14,

                              offset:
                              const Offset(0, 5),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.camera_alt_rounded,

                          size: 26,

                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<String> galleryImages = [

    'assets/images/post1.jpg',
    'assets/images/post2.jpg',
    'assets/images/post3.jpg',
    'assets/images/post4.jpg',
    'assets/images/post5.jpg',
    'assets/images/post6.jpg',
    'assets/images/post7.jpg',
    'assets/images/post8.jpg',
    'assets/images/story1.jpg',
  ];

  Widget buildTopButton({
    required IconData icon,
    required String title,
  }) {

    return Container(

      height: 76,

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        border: Border.all(
          color: Colors.black12,
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(
              alpha: 0.04,
            ),

            blurRadius: 8,

            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Icon(
            icon,

            size: 22,

            color: Colors.black,
          ),

          const SizedBox(width: 8),

          Text(
            title,

            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}