import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FavoriteWorker {
  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final int jobsCount;
  final int yearsExp;
  final double rating;
  final int ratePerHour;
  final bool isVerified;

  const FavoriteWorker({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.jobsCount,
    required this.yearsExp,
    required this.rating,
    required this.ratePerHour,
    required this.isVerified,
  });
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // Static favorite workers data
  static const List<FavoriteWorker> favoriteWorkers = [
    FavoriteWorker(
      id: '1',
      name: 'Sunil Sharma',
      specialty: 'Expert Electrician',
      imageUrl: 'https://img.magnific.com/free-photo/image-young-asian-woman-company-worker-glasses-smiling-holding-digital-tablet-standing-white-background_1258-89376.jpg?semt=ais_hybrid&w=740&q=80',
      jobsCount: 800,
      yearsExp: 4,
      rating: 5.0,
      ratePerHour: 1500,
      isVerified: true,
    ),
    FavoriteWorker(
      id: '2',
      name: 'Hari Subedi',
      specialty: 'Expert Electrician',
      imageUrl: 'https://img.magnific.com/free-photo/image-young-asian-woman-company-worker-glasses-smiling-holding-digital-tablet-standing-white-background_1258-89376.jpg?semt=ais_hybrid&w=740&q=80',
      jobsCount: 800,
      yearsExp: 4,
      rating: 5.0,
      ratePerHour: 1500,
      isVerified: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left_2,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Favorite Customers',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: favoriteWorkers.length,
        itemBuilder: (context, index) {
          final worker = favoriteWorkers[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FavoriteWorkerCard(
              worker: worker,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          );
        },
      ),
    );
  }
}

// ============= REUSABLE PIECES =============

class _FavoriteWorkerCard extends StatefulWidget {
  final FavoriteWorker worker;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _FavoriteWorkerCard({
    required this.worker,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  State<_FavoriteWorkerCard> createState() => _FavoriteWorkerCardState();
}

class _FavoriteWorkerCardState extends State<_FavoriteWorkerCard> {
  late bool _isFavorited = true;

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Worker Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.worker.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color: widget.colorScheme.secondary.withValues(alpha: 0.1),
                    child: Icon(
                      Iconsax.user,
                      color: widget.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              if (widget.worker.isVerified)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber[400],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Worker Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Favorite button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.worker.name,
                        style: widget.textTheme.bodyMedium?.copyWith(
                          color: widget.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleFavorite,
                      child: Icon(
                        Icons.favorite,
                        color: _isFavorited ? Colors.red : Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Specialty
                Text(
                  widget.worker.specialty,
                  style: widget.textTheme.bodySmall?.copyWith(
                    color: widget.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),

                // Jobs, Experience, Rating row
                Row(
                  children: [
                    Icon(
                      Iconsax.briefcase,
                      size: 12,
                      color: widget.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${widget.worker.jobsCount}+ Jobs',
                      style: widget.textTheme.bodySmall?.copyWith(
                        color: widget.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Iconsax.medal_star,
                      size: 12,
                      color: widget.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${widget.worker.yearsExp} Years Exp',
                      style: widget.textTheme.bodySmall?.copyWith(
                        color: widget.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${widget.worker.rating}',
                      style: widget.textTheme.bodySmall?.copyWith(
                        color: widget.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Rate and Book button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NPR. ${widget.worker.ratePerHour}/hr',
                      style: widget.textTheme.bodyMedium?.copyWith(
                        color: widget.colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      height: 32,
                      width: 90,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle book now
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.colorScheme.secondary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          'Book Now',
                          style: widget.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
