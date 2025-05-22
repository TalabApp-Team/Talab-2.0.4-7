import 'dart:async';
import 'dart:math' as math;

import 'package:Talab/app/routes.dart';
import 'package:Talab/data/cubits/slider_cubit.dart';
import 'package:Talab/data/helper/widgets.dart';
import 'package:Talab/data/model/category_model.dart';
import 'package:Talab/data/model/data_output.dart';
import 'package:Talab/data/model/item/item_model.dart';
import 'package:Talab/data/repositories/item/item_repository.dart';
import 'package:Talab/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart'; // Direct import without alias

import 'package:cached_network_image/cached_network_image.dart';

class SliderWidget extends StatefulWidget {
  const SliderWidget({Key? key}) : super(key: key);

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> 
    with AutomaticKeepAliveClientMixin {
  
  // Page Controller with improved configuration
  late PageController _pageController;
  
  // Timer for auto-sliding
  Timer? _autoSlideTimer;
  
  // Current page index
  int _currentPage = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    // Initialize PageController with improved settings
    _pageController = PageController(
      viewportFraction: 0.90, // More modern, slight peek of next/previous slides
      initialPage: 0,
    );

    // Start auto-sliding
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final state = context.read<SliderCubit>().state;
      if (state is SliderFetchSuccess) {
        if (_currentPage < state.sliderlist.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutQuint, // More sophisticated easing
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutQuint,
          );
        }
      }
    });
  }

  // Custom Dot Indicator
 Widget _buildDotIndicator(int totalPages, int currentPage, double screenWidth) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(totalPages, (index) {
      return Container(
        width: screenWidth * 0.025, // 2.5% of screen width
        height: screenWidth * 0.025,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01), // 1% of screen width
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: index == currentPage 
            ? Theme.of(context).primaryColor 
            : Colors.grey.shade300,
        ),
      );
    }),
  );
}



@override
Widget build(BuildContext context) {
  super.build(context);

  // Get screen dimensions for responsive sizing
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return BlocConsumer<SliderCubit, SliderState>(
    listener: (context, state) {
      if (state is SliderFetchFailure && !state.isUserDeactivated) {
        // Optional error handling
      }
    },
    builder: (context, state) {
      if (state is SliderFetchSuccess && state.sliderlist.isNotEmpty) {
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9, // Standard banner aspect ratio
              child: SizedBox(
                height: screenHeight * 0.35, // Increased for prominence
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: state.sliderlist.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 0.0;
                        if (_pageController.position.haveDimensions) {
                          value = index - (_pageController.page ?? 0);
                          value = (value * 0.05).clamp(-1, 1); // Smoother transitions
                        }

                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.002) // Enhanced 3D effect
                            ..rotateY(math.pi * value * 0.5) // Subtle 3D flip
                            ..scale(1 - value.abs() * 0.1), // Reduced scaling for elegance
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              _handleSliderItemTap(context, state.sliderlist[index]);
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.015), // 1.5% of screen width
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(screenWidth * 0.05), // Responsive rounded edges
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15 + value.abs() * 0.05),
                                    blurRadius: screenWidth * 0.03,
                                    spreadRadius: screenWidth * 0.005,
                                    offset: Offset(0, screenWidth * 0.015),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(screenWidth * 0.05),
                                child: Transform.translate(
                                  offset: Offset(value * 20, 0), // Parallax effect
                                  child: CachedNetworkImage(
                                    imageUrl: state.sliderlist[index].image ?? "",
                                    fit: BoxFit.contain, // Image contained within container
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.error,
                                      color: Colors.redAccent,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.025), // 2.5% of screen height
            // Custom dot indicator with responsive sizes
            _buildDotIndicator(state.sliderlist.length, _currentPage, screenWidth),
          ],
        );
      } else if (state is SliderFetchInProgress) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return const SizedBox.shrink();
      }
    },
  );
}

  // Method to handle slider item tap (extracted from original widget)
  void _handleSliderItemTap(BuildContext context, dynamic sliderItem) async {
    if (sliderItem.thirdPartyLink != null && sliderItem.thirdPartyLink!.isNotEmpty) {
      // Launch third-party link
      await launchUrl(
        Uri.parse(sliderItem.thirdPartyLink!),
        mode: LaunchMode.externalApplication,
      );
    } else if (sliderItem.modelType!.contains("Category")) {
      // Navigate to category or subcategory
      if (sliderItem.model!.subCategoriesCount! > 0) {
        Navigator.pushNamed(
          context, 
          Routes.subCategoryScreen,
          arguments: {
            "categoryList": <CategoryModel>[],
            "catName": sliderItem.model!.name,
            "catId": sliderItem.modelId,
            "categoryIds": [
              sliderItem.model!.parentCategoryId.toString(),
              sliderItem.modelId.toString()
            ]
          }
        );
      } else {
        Navigator.pushNamed(
          context, 
          Routes.itemsList,
          arguments: {
            'catID': sliderItem.modelId.toString(),
            'catName': sliderItem.model!.name,
            "categoryIds": [sliderItem.modelId.toString()]
          }
        );
      }
    } else {
      // Fetch and navigate to item details
      try {
        ItemRepository fetch = ItemRepository();
        Widgets.showLoader(context);
        DataOutput<ItemModel> dataOutput = 
          await fetch.fetchItemFromItemId(sliderItem.modelId!);
        Widgets.hideLoder(context);
        Navigator.pushNamed(
          context, 
          Routes.adDetailsScreen,
          arguments: {
            "model": dataOutput.modelList[0],
          }
        );
      } catch (e) {
        Widgets.hideLoder(context);
        HelperUtils.showSnackBarMessage(context, e.toString());
      }
    }
  }
}
