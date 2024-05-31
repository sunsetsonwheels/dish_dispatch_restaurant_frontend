import 'package:dish_dispatch_restaurant_frontend/providers/api_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dish_dispatch_restaurant_frontend/models/restaurant.dart';
import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:provider/provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<RestaurantRating> ratingFuture;
  late Future<RestaurantRevenue> revenueFuture;

  @override
  void initState() {
    reload();
    super.initState();
  }

  void reload() {
    final api = Provider.of<APIProvider>(context, listen: false);
    setState(() {
      ratingFuture = api.getRestaurantRating();
      revenueFuture = api.getRestaurantRevenue();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stats"),
        actions: [
          IconButton(
            onPressed: reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GridTile(
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FutureBuilder(
                      future: ratingFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final rating = snapshot.requireData;
                        List<Widget> children = [
                          Text(
                            "Ratings",
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              Text(
                                "Average",
                                style: theme.textTheme.titleMedium,
                              ),
                              const Spacer(),
                              AnimatedRatingStars(
                                onChanged: (_) {},
                                customFilledIcon: Icons.star,
                                customHalfFilledIcon: Icons.star_half,
                                customEmptyIcon: Icons.star_outline,
                                readOnly: true,
                                initialRating: rating.average,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Recent comments",
                            style: theme.textTheme.titleMedium,
                          ),
                        ];
                        List<Widget> commentsWidgets = [];
                        for (final comment in rating.recent) {
                          commentsWidgets.addAll([
                            Chip(
                              label: Text('"$comment"'),
                            ),
                            const SizedBox(width: 8),
                          ]);
                        }
                        children.add(
                          Row(
                            children: commentsWidgets,
                          ),
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: children,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GridTile(
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FutureBuilder(
                      future: revenueFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final revenue = snapshot.requireData;
                        List<Widget> children = [
                          Text(
                            "Revenue",
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              Text(
                                "Total",
                                style: theme.textTheme.titleMedium,
                              ),
                              const Spacer(),
                              Text(
                                "\$${revenue.total.toStringAsFixed(2)}",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: children,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
