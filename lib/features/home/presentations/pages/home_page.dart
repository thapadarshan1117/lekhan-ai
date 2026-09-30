import 'package:flutter/material.dart';
import 'package:lekhan_ai/features/home/presentations/widgets/home_header.dart';
import 'package:lekhan_ai/features/home/presentations/widgets/search_bar.dart';
import 'package:lekhan_ai/features/home/presentations/widgets/recent_searches.dart';
import 'package:lekhan_ai/features/home/presentations/widgets/section_header.dart';
import 'package:lekhan_ai/features/home/presentations/widgets/categories_grid.dart';
import 'package:lekhan_ai/features/home/presentations/widgets/top_rated_pros_list.dart';
import 'package:lekhan_ai/features/home/presentations/widgets/spotlight_carousel.dart';
import 'package:lekhan_ai/features/home/presentations/widgets/limited_offer_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    HomeHeader(),
                    SizedBox(height: 16),
                    SearchBarWidget(),
                    SizedBox(height: 14),
                    RecentSearches(),
                    SizedBox(height: 12),
                    SectionHeader(title: 'Categories', actionLabel: 'View All'),
                    SizedBox(height: 20),
                    CategoriesGrid(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.zero,
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SectionHeader(title: 'Top Rated Pros'),
                    SizedBox(height: 8),
                    TopRatedProsList(),
                    SizedBox(height: 12),
                    SectionHeader(title: 'In the spotlight'),
                    SizedBox(height: 8),
                    SpotlightCarousel(),
                    SizedBox(height: 12),
                    LimitedOfferCard(),
                    SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
