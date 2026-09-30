import 'package:lekhan_ai/core/utils/shimmer.dart';
import 'package:flutter/material.dart';

class NotificationShimmerList extends StatelessWidget {
  const NotificationShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: 8,
      itemBuilder: (context, index) {
        if (index % 3 == 0 && index != 0) {
          return const Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Shimmer(
              width: 80,
              height: 20,
              borderRadius: 4,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            color: const Color(0xFFF4FAFB),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Shimmer(
                        width: 18,
                        height: 18,
                        borderRadius: 9,
                      ),
                      const SizedBox(width: 6),
                      Shimmer(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: 14,
                        borderRadius: 4,
                      ),
                      const SizedBox(width: 6),
                      Shimmer(
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: 14,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Shimmer(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 16,
                    borderRadius: 4,
                  ),
                  const SizedBox(height: 4),
                  Shimmer(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 14,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
