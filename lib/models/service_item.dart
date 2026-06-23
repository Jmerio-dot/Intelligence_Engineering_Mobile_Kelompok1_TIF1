import 'package:flutter/material.dart';

class ServiceItem {
  final String icon;
  final String badge;
  final String title;
  final String description;
  final List<Color> gradientColors;

  const ServiceItem({
    required this.icon,
    required this.badge,
    required this.title,
    required this.description,
    required this.gradientColors,
  });
}
