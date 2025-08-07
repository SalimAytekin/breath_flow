import 'package:breathe_flow/models/meditation_journey.dart';
import 'package:breathe_flow/widgets/journey_card.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:breathe_flow/screens/journey_detail_screen.dart';

class JourneysScreen extends StatelessWidget {
  const JourneysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journeys = MeditationJourney.sampleJourneys;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Meditasyon Yolculukları'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: journeys.length,
        itemBuilder: (context, index) {
          final journey = journeys[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FadeInUp(
              duration: const Duration(milliseconds: 500),
              delay: Duration(milliseconds: 100 * index),
              child: JourneyCard(
                journey: journey,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JourneyDetailScreen(journey: journey),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
} 