import 'package:Talab/app/app_theme.dart';
import 'package:Talab/app/routes.dart';
import 'package:Talab/data/cubits/favorite/favorite_cubit.dart';
import 'package:Talab/data/cubits/favorite/manage_fav_cubit.dart';
import 'package:Talab/data/cubits/system/app_theme_cubit.dart';
import 'package:Talab/data/model/home/home_screen_section.dart';
import 'package:Talab/data/model/item/item_model.dart';
import 'package:Talab/data/repositories/favourites_repository.dart';
import 'package:Talab/ui/screens/home/home_screen.dart';
import 'package:Talab/ui/screens/home/widgets/grid_list_adapter.dart';
import 'package:Talab/ui/screens/widgets/promoted_widget.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/app_icon.dart';
import 'package:Talab/utils/custom_text.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/extensions/lib/currency_formatter.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeSectionsAdapter extends StatelessWidget {
  final HomeScreenSection section;

  const HomeSectionsAdapter({
    super.key,
    required this.section,
  });

  // _buildItemCard function (used in style_2)
  Widget _buildItemCard({
    required BuildContext context,
    required ItemModel? item,
    required int index,
    required int realIndex,
    required double animationValue,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.adDetailsScreen,
          arguments: {"model": item},
        );
      },
      child: Opacity(
        opacity: animationValue,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[50]!],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                spreadRadius: 2,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      child: Stack(
                        children: [
                          Image.network(
                            item?.image ?? "",
                            height: 125,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 125,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 125,
                                color: Colors.grey[200],
                                child: Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item?.name ?? "Item Name",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (item?.price ?? 0.0).currencyFormat,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.star, size: 11, color: Colors.blueAccent),
                                    SizedBox(width: 1),
                                    Text(
                                      "4.8",
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 7,
                  top: 7,
                  child: AnimatedOpacity(
                    opacity: realIndex == index ? 1.0 : 0.7,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 15,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Add media queries for style_3 and style_4
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;
    final gridHeightStyle3 = isDesktop ? 265.0 : isTablet ? 245.0 : 225.0; // Retained reduced values
    final crossAxisCountStyle3 = isDesktop ? 4 : isTablet ? 3 : 2;
    final cardWidthStyle3And4 = isDesktop ? 240.0 : isTablet ? 210.0 : 192.0;
    final listSeparatorWidthStyle4 = isDesktop ? 20.0 : isTablet ? 16.0 : 14.0;

    if (section.style == "style_1") {
      return section.sectionData!.isNotEmpty
          ? Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          section.title ?? "Trending Items",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.sectionWiseItemsScreen,
                              arguments: {
                                "title": section.title,
                                "sectionId": section.sectionId,
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                "See All",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.blueAccent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 300,
                    child: CarouselSlider.builder(
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 5),
                        autoPlayAnimationDuration: Duration(milliseconds: 1500),
                        viewportFraction: 0.75,
                        enlargeCenterPage: true,
                        enlargeFactor: 0.25,
                        scrollPhysics: BouncingScrollPhysics(),
                        enableInfiniteScroll: true,
                      ),
                      itemCount: section.sectionData?.length ?? 0,
                      itemBuilder: (context, index, realIndex) {
                        ItemModel? item = section.sectionData?[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.adDetailsScreen,
                              arguments: {"model": item},
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            margin: EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        item?.image ?? "",
                                        height: 140,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            height: 140,
                                            child: Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 140,
                                            color: Colors.grey[200],
                                            child: Icon(Icons.image_not_supported),
                                          );
                                        },
                                      ),
                                      Positioned.fill(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.2),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item?.name ?? "Item Name",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            (item?.price ?? 0.0).currencyFormat,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[700],
                                            ),
                                          ),
                                          Icon(
                                            Icons.favorite_border,
                                            size: 18,
                                            color: Colors.grey[600],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : SizedBox.shrink();
    } else if (section.style == "style_2") {
      return section.sectionData!.isNotEmpty
          ? Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blueAccent, Colors.purpleAccent],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              section.title ?? "Featured Collections",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.sectionWiseItemsScreen,
                                arguments: {
                                  "title": section.title,
                                  "sectionId": section.sectionId,
                                },
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  "Explore",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 18,
                                  color: Colors.blueAccent,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 340,
                    child: CarouselSlider.builder(
                      options: CarouselOptions(
                        autoPlay: false,
                        viewportFraction: 0.78,
                        enlargeCenterPage: true,
                        enlargeFactor: 0.3,
                        scrollPhysics: BouncingScrollPhysics(),
                        enableInfiniteScroll: true,
                        padEnds: true,
                      ),
                      itemCount: section.sectionData?.length ?? 0,
                      itemBuilder: (context, index, realIndex) {
                        ItemModel? item = section.sectionData?[index];
                        final animation = ModalRoute.of(context)?.animation;

                        return animation != null
                            ? AnimatedBuilder(
                                animation: CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOut,
                                ),
                                builder: (context, child) {
                                  return _buildItemCard(
                                    context: context,
                                    item: item,
                                    index: index,
                                    realIndex: realIndex,
                                    animationValue: animation.value,
                                  );
                                },
                              )
                            : _buildItemCard(
                                context: context,
                                item: item,
                                index: index,
                                realIndex: realIndex,
                                animationValue: 1.0,
                              );
                      },
                    ),
                  ),
                ],
              ),
            )
          : SizedBox.shrink();
    } else if (section.style == "style_3") {
      return section.sectionData!.isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                children: [
                  TitleHeader(
                    title: section.title ?? "",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.sectionWiseItemsScreen,
                          arguments: {
                            "title": section.title,
                            "sectionId": section.sectionId,
                          });
                    },
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: gridHeightStyle3),
                    child: GridListAdapter(
                      type: ListUiType.Grid,
                      crossAxisCount: crossAxisCountStyle3,
                      height: gridHeightStyle3,
                      builder: (context, int index, bool) {
                        ItemModel? item = section.sectionData?[index];
                        return ItemCard(
                          item: item,
                          width: cardWidthStyle3And4,
                        );
                      },
                      total: section.sectionData?.length ?? 0,
                    ),
                  ),
                ],
              ),
            )
          : SizedBox.shrink();
    } else if (section.style == "style_4") {
      return section.sectionData!.isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                children: [
                  TitleHeader(
                    title: section.title ?? "",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.sectionWiseItemsScreen,
                          arguments: {
                            "title": section.title,
                            "sectionId": section.sectionId,
                          });
                    },
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: gridHeightStyle3),
                    child: GridListAdapter(
                      type: ListUiType.List,
                      height: gridHeightStyle3,
                      listAxis: Axis.horizontal,
                      listSeparator: (BuildContext p0, int p1) => SizedBox(
                        width: listSeparatorWidthStyle4,
                      ),
                      builder: (context, int index, bool) {
                        ItemModel? item = section.sectionData?[index];
                        return ItemCard(
                          item: item,
                          width: cardWidthStyle3And4,
                        );
                      },
                      total: section.sectionData?.length ?? 0,
                    ),
                  ),
                ],
              ),
            )
          : SizedBox.shrink();
    } else {
      return Container();
    }
  }
}

class TitleHeader extends StatelessWidget {
  final String title;
  final Function() onTap;
  final bool? hideSeeAll;

  const TitleHeader({
    super.key,
    required this.title,
    required this.onTap,
    this.hideSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          top: 18, bottom: 0, start: sidePadding, end: sidePadding),
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: CustomText(
                title,
                fontSize: context.font.large,
                fontWeight: FontWeight.w600,
                maxLines: 1,
              )),
          const Spacer(),
          if (!(hideSeeAll ?? false))
            GestureDetector(
                onTap: onTap,
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2.2),
                    child: CustomText(
                      "seeAll".translate(context),
                      fontSize: context.font.smaller + 1,
                    )))
        ],
      ),
    );
  }
}

class ItemCard extends StatefulWidget {
  final double? width;
  final bool? bigCard;
  final ItemModel? item;

  const ItemCard({
    super.key,
    required this.item,
    this.width,
    this.bigCard,
  });

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  double likeButtonSize = 32;
  double imageHeight = 170;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.adDetailsScreen, arguments: {
          "model": widget.item,
        });
      },
      child: Container(
        width: widget.width ?? 250,
        decoration: BoxDecoration(
          border: Border.all(
            color: context.color.borderColor.darken(30),
            width: 1,
          ),
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: UiUtils.getImage(
                        widget.item?.image ?? "",
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (widget.item?.isFeature ?? false)
                      const PositionedDirectional(
                          start: 10,
                          top: 5,
                          child: PromotedCard(type: PromoteCardType.icon)),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0), // Reduced from 6.0 to 5.0
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          (widget.item?.price ?? 0.0).currencyFormat,
                          fontWeight: FontWeight.bold,
                          color: context.color.territoryColor,
                          fontSize: context.font.large,
                        ),
                        CustomText(
                          widget.item!.name!,
                          fontSize: context.font.large,
                          maxLines: 1,
                          firstUpperCaseWidget: true,
                        ),
                        if (widget.item?.address != "")
                          Row(
                            children: [
                              UiUtils.getSvg(
                                AppIcons.location,
                                width: widget.bigCard == true ? 10 : 8,
                                height: widget.bigCard == true ? 13 : 11,
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsetsDirectional.only(start: 3.0),
                                  child: CustomText(
                                    widget.item?.address ?? "",
                                    fontSize: (widget.bigCard == true)
                                        ? context.font.small
                                        : context.font.smaller,
                                    color: context.color.textDefaultColor
                                        .withValues(alpha: 0.5),
                                    maxLines: 1,
                                  ),
                                ),
                              )
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            favButton(),
          ],
        ),
      ),
    );
  }

  Widget favButton() {
    bool isLike =
        context.read<FavoriteCubit>().isItemFavorite(widget.item!.id!);

    return BlocProvider(
        create: (context) => UpdateFavoriteCubit(FavoriteRepository()),
        child: BlocConsumer<FavoriteCubit, FavoriteState>(
            bloc: context.read<FavoriteCubit>(),
            listener: ((context, state) {
              if (state is FavoriteFetchSuccess) {
                isLike = context
                    .read<FavoriteCubit>()
                    .isItemFavorite(widget.item!.id!);
              }
            }),
            builder: (context, likeAndDislikeState) {
              return BlocConsumer<UpdateFavoriteCubit, UpdateFavoriteState>(
                  bloc: context.read<UpdateFavoriteCubit>(),
                  listener: ((context, state) {
                    if (state is UpdateFavoriteSuccess) {
                      if (state.wasProcess) {
                        context
                            .read<FavoriteCubit>()
                            .addFavoriteitem(state.item);
                      } else {
                        context
                            .read<FavoriteCubit>()
                            .removeFavoriteItem(state.item);
                      }
                    }
                  }),
                  builder: (context, state) {
                    return PositionedDirectional(
                      top: imageHeight - (likeButtonSize / 2) - 2,
                      end: 16,
                      child: InkWell(
                        onTap: () {
                          UiUtils.checkUser(
                              onNotGuest: () {
                                context
                                    .read<UpdateFavoriteCubit>()
                                    .setFavoriteItem(
                                      item: widget.item!,
                                      type: isLike ? 0 : 1,
                                    );
                              },
                              context: context);
                        },
                        child: Container(
                          width: likeButtonSize,
                          height: likeButtonSize,
                          decoration: BoxDecoration(
                            color: context.color.secondaryColor,
                            shape: BoxShape.circle,
                            boxShadow:
                                context.watch<AppThemeCubit>().state.appTheme ==
                                        AppTheme.dark
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: Colors.grey[300]!,
                                          offset: const Offset(0, 2),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                        ),
                                      ],
                          ),
                          child: FittedBox(
                            fit: BoxFit.none,
                            child: state is UpdateFavoriteInProgress
                                ? Center(child: UiUtils.progress())
                                : UiUtils.getSvg(
                                    isLike ? AppIcons.like_fill : AppIcons.like,
                                    width: 22,
                                    height: 22,
                                    color: context.color.territoryColor,
                                  ),
                          ),
                        ),
                      ),
                    );
                  });
            }));
  }
}