import 'dart:async';
import 'dart:math' as math;

import 'package:Talab/data/model/home/home_screen_section.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/app_icon.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BannerSectionWidget extends StatefulWidget {
  final HomeScreenSection section;

  const BannerSectionWidget({
    super.key,
    required this.section,
  });

  @override
  State<BannerSectionWidget> createState() => _BannerSectionWidgetState();
}

class _BannerSectionWidgetState extends State<BannerSectionWidget>
    with AutomaticKeepAliveClientMixin {
  late PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      viewportFraction: 0.90,
      initialPage: 0,
    );

    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    if (widget.section.bannerImages.length > 1) {
      _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_pageController.hasClients) {
          if (_currentPage < widget.section.bannerImages.length - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutQuint,
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
  }

  Widget _buildDotIndicator(int totalPages, int currentPage, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        return Container(
          width: screenWidth * 0.025,
          height: screenWidth * 0.025,
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
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

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (widget.section.bannerImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: SizedBox(
            height: screenHeight * 0.20,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.section.bannerImages.length,
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
                      value = (value * 0.05).clamp(-1, 1);
                    }

                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002)
                        ..rotateY(math.pi * value * 0.5)
                        ..scale(1 - value.abs() * 0.1),
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(screenWidth * 0.05),
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
                            offset: Offset(value * 20, 0),
                            child: CachedNetworkImage(
                              imageUrl: widget.section.bannerImages[index],
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white70,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: context.color.primaryColor.withOpacity(0.1),
                                child: Center(
                                  child: UiUtils.getSvg(
                                    AppIcons.somethingWentWrong,
                                    width: 40,
                                    height: 40,
                                    color: context.color.textDefaultColor,
                                  ),
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
        SizedBox(height: screenHeight * 0.025),
        _buildDotIndicator(widget.section.bannerImages.length, _currentPage, screenWidth),
      ],
    );
  }
}


