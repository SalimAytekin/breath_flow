import 'package:breathe_flow/models/meditation_journey.dart';
import 'package:breathe_flow/widgets/journey_card.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:breathe_flow/screens/journey_detail_screen.dart';
import 'package:breathe_flow/widgets/global_background.dart';
import 'package:breathe_flow/widgets/professional_app_bar.dart';

class JourneysScreen extends StatefulWidget {
  const JourneysScreen({super.key});

  @override
  State<JourneysScreen> createState() => _JourneysScreenState();
}

class _JourneysScreenState extends State<JourneysScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journeys = MeditationJourney.sampleJourneys;

    return GlobalBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: ProfessionalAppBar(scrollController: _scrollController, title: 'Meditasyon Yolculukları'),
        body: ListView.builder(
          controller: _scrollController,
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
      ),
    );
  }
}