import 'package:breathe_flow/models/meditation_journey.dart';
import 'package:breathe_flow/providers/audio_provider.dart';
import 'package:breathe_flow/widgets/journey_step_tile.dart';
import 'package:breathe_flow/widgets/professional_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JourneyDetailScreen extends StatefulWidget {
  final MeditationJourney journey;

  const JourneyDetailScreen({super.key, required this.journey});

  @override
  State<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends State<JourneyDetailScreen> {
  late AudioProvider _audioProvider;

  @override
  void initState() {
    super.initState();
    // 'listen: false' ile provider'a erişim, initState içinde güvenlidir.
    _audioProvider = Provider.of<AudioProvider>(context, listen: false);
    // Provider'daki değişiklikleri dinlemek ve UI'ı güncellemek için listener ekle.
    _audioProvider.addListener(_onAudioProviderUpdate);

    // Örnek ilerleme verisi
    if (widget.journey.id == 'stres_azaltma') {
      widget.journey.steps[0].isCompleted = true;
      widget.journey.steps[1].isCompleted = true;
    }
  }

  @override
  void dispose() {
    // Listener'ı temizle
    _audioProvider.removeListener(_onAudioProviderUpdate);
    super.dispose();
  }

  void _onAudioProviderUpdate() {
    // Provider'dan bir güncelleme geldiğinde UI'ı yeniden çiz.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.journey.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
              centerTitle: true,
              titlePadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              background: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: Image.asset(
                  widget.journey.imagePath,
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.3),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
              child: Text(
                widget.journey.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.8)),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final step = widget.journey.steps[index];
                return Consumer<AudioProvider>(
                  builder: (context, audioProvider, child) {
                    final isCurrentlyPlaying = audioProvider.currentMeditationId == step.id && audioProvider.isMeditationPlaying;
                    return JourneyStepTile(
                      step: step,
                      isCurrentlyPlaying: isCurrentlyPlaying,
                      onTap: () {
                        if (isCurrentlyPlaying) {
                          _audioProvider.pauseMeditation();
                        } else {
                          _audioProvider.playMeditation(step);
                        }
                      },
                      stepIndex: index,
                      status: _getStepStatus(widget.journey, index),
                    );
                  },
                );
              },
              childCount: widget.journey.steps.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 50),
          )
        ],
      ),
    );
  }

  StepStatus _getStepStatus(MeditationJourney journey, int index) {
    final step = journey.steps[index];
    if (step.isCompleted) {
      return StepStatus.completed;
    }
    if (index == 0 || journey.steps[index - 1].isCompleted) {
      return StepStatus.unlocked;
    }
    return StepStatus.locked;
  }
} 