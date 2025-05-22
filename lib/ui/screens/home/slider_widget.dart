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
  Widget _buildDotIndicator(int totalPages, int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        return Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
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
              SizedBox(
                height: 200, // Increased height for more modern look
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
                          value = (value * 0.038).clamp(-1, 1);
                        }

                        return Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(math.pi * value)
                            ..scale(1 - value.abs() * 0.15),
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              // Navigation logic from original widget
                              _handleSliderItemTap(context, state.sliderlist[index]);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15), // More rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                                  imageUrl: state.sliderlist[index].image ?? "",
                                  fit: BoxFit.fill,
                                  placeholder: (context, url) => 
                                    const Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => 
                                    const Icon(Icons.error),
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
              const SizedBox(height: 16),
              // Custom dot indicator
              _buildDotIndicator(state.sliderlist.length, _currentPage),
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