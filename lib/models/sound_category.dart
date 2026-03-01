import 'package:flutter/material.dart';
import 'sound_item.dart';

/// Ses kategorilerini temsil eden model.
/// Her kategorinin bir kimliği, adı, ikonu ve o kategoriye ait seslerin listesi bulunur.
class SoundCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<SoundItem> sounds;

  SoundCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.sounds,
  });
} 