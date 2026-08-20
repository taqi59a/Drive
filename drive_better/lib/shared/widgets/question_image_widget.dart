import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a question image based on an SVG asset path.
///
/// Supports:
/// 1. Direct code (e.g. "sign:warning", "scenario:roundabout")
/// 2. Direct SVG paths
/// 3. Keyword-based matching of question text (to automatically assign images)
/// 4. Topic-based default fallbacks
class QuestionImageWidget extends StatelessWidget {
  final String? code;
  final String? questionText;
  final String? topicId;
  final double height;

  const QuestionImageWidget({
    super.key,
    this.code,
    this.questionText,
    this.topicId,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F9FC);

    String assetPath;
    if (code != null && code!.isNotEmpty) {
      if (code!.startsWith('sign:')) {
        assetPath = _mapSignCode(code!.substring(5));
      } else if (code!.startsWith('scenario:')) {
        assetPath = _mapScenarioCode(code!.substring(9));
      } else if (code!.startsWith('assets/')) {
        assetPath = code!;
      } else {
        assetPath = _mapSignCode(code!);
      }
    } else {
      final matched = questionText != null ? _matchTextToSvg(questionText!) : null;
      assetPath = matched ?? _fallbackSvgForTopic(topicId);
    }

    final isSvg = assetPath.toLowerCase().endsWith('.svg');

    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: isSvg
            ? SvgPicture.asset(
                assetPath,
                fit: BoxFit.contain,
                placeholderBuilder: (BuildContext context) => const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              )
            : Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
      ),
    );
  }

  static String _mapSignCode(String key) {
    switch (key) {
      case 'warning':
      case 'warning_general':
      case 'general':
        return 'assets/images/signs/general_warning.svg';
      case 'warning_children':
        return 'assets/images/signs/school_zone.svg';
      case 'warning_railway':
        return 'assets/images/signs/railway_crossing.svg';
      case 'warning_cyclist':
        return 'assets/images/signs/warning_triangle.svg';
      case 'warning_traffic_lights':
        return 'assets/images/signs/warning_triangle.svg';
      case 'prohibition':
        return 'assets/images/signs/prohibition_circle.svg';
      case 'no_entry':
        return 'assets/images/signs/no_entry.svg';
      case 'no_overtaking':
        return 'assets/images/signs/no_overtaking.svg';
      case 'no_trucks':
        return 'assets/images/signs/no_trucks.svg';
      case 'no_parking':
        return 'assets/images/signs/no_parking.svg';
      case 'speed_30':
        return 'assets/images/signs/zone30.svg';
      case 'speed_50':
        return 'assets/images/signs/speed_limit_50.svg';
      case 'speed_70':
        return 'assets/images/signs/speed_limit_70.svg';
      case 'speed_90':
        return 'assets/images/signs/speed_limit_90.svg';
      case 'speed_90_trailer':
        return 'assets/images/signs/speed_limit_90_trailer.svg';
      case 'speed_120':
        return 'assets/images/signs/speed_limit_120.svg';
      case 'min_speed_70':
      case 'min_speed_motorway':
        return 'assets/images/signs/min_speed_blue.svg';
      case 'priority_road':
        return 'assets/images/signs/priority_diamond.svg';
      case 'priority_road_end':
        return 'assets/images/signs/priority_diamond_end.svg';
      case 'priority_b':
        return 'assets/images/signs/priority_b.svg';
      case 'give_way':
        return 'assets/images/signs/give_way.svg';
      case 'stop':
        return 'assets/images/signs/stop_sign.svg';
      case 'mandatory_ahead':
        return 'assets/images/signs/mandatory_ahead.svg';
      case 'tram':
        return 'assets/images/signs/tram_mandatory.svg';
      case 'parking':
        return 'assets/images/signs/parking_sign.svg';
      case 'motorway':
        return 'assets/images/signs/motorway_green.svg';
      case 'zone30':
        return 'assets/images/signs/zone30.svg';
      case 'zone_residential':
        return 'assets/images/signs/woonerf_enter.svg';
      case 'cycle_path':
        return 'assets/images/signs/cycle_path.svg';
      case 'lez':
        return 'assets/images/signs/lez_sign.svg';
      case 'lane_closed':
        return 'assets/images/signs/lane_closed_x.svg';
      case 'road_works':
        return 'assets/images/signs/road_works_sign.svg';
      case 'works_end':
        return 'assets/images/signs/works_end.svg';
      default:
        return 'assets/images/signs/general_warning.svg';
    }
  }

  static String _mapScenarioCode(String key) {
    switch (key) {
      case 'priorite_droite':
        return 'assets/images/scenarios/priorite_droite.svg';
      case 'roundabout':
        return 'assets/images/scenarios/roundabout_priority.svg';
      case 'following_distance':
        return 'assets/images/scenarios/following_distance.svg';
      case 'emergency_corridor':
        return 'assets/images/scenarios/emergency_corridor.svg';
      case 'motorway_breakdown':
        return 'assets/images/scenarios/motorway_breakdown.svg';
      case 'bac_limit':
        return 'assets/images/scenarios/bac_limit.svg';
      case 'speed_limit_info':
        return 'assets/images/signs/speed_limit_50.svg';
      default:
        return 'assets/images/scenarios/accident_scene.svg';
    }
  }

  static String? _matchTextToSvg(String text) {
    final textLower = text.toLowerCase();

    // Specific scenarios
    if (textLower.contains('roundabout')) {
      return 'assets/images/scenarios/roundabout_priority.svg';
    }
    if (textLower.contains('aquaplaning')) {
      return 'assets/images/scenarios/aquaplaning.svg';
    }
    if (textLower.contains('blowout') || textLower.contains('blow out')) {
      return 'assets/images/scenarios/tyre_blowout.svg';
    }
    if (textLower.contains('tread depth') || textLower.contains('minimum tread')) {
      return 'assets/images/scenarios/tyre_tread.svg';
    }
    if (textLower.contains('tyre pressure') || textLower.contains('inflate') || textLower.contains('pressures')) {
      return 'assets/images/scenarios/tyre_pressure.svg';
    }
    if (textLower.contains('abs') || textLower.contains('anti-lock brakes') || textLower.contains('anti lock')) {
      return 'assets/images/scenarios/abs_braking.svg';
    }
    if (textLower.contains('braking distance') || textLower.contains('stopping distance') || textLower.contains('overall stopping')) {
      return 'assets/images/scenarios/braking_distance.svg';
    }
    if (textLower.contains('following distance') || textLower.contains('two-second') || textLower.contains('2-second') || textLower.contains('2 second')) {
      return 'assets/images/scenarios/following_distance.svg';
    }
    if (textLower.contains('emergency corridor') || textLower.contains('corridor')) {
      return 'assets/images/scenarios/emergency_corridor.svg';
    }
    if (textLower.contains('alcohol') || textLower.contains('bac limit') || textLower.contains('drink driving') || textLower.contains('blood alcohol')) {
      return 'assets/images/scenarios/bac_limit.svg';
    }
    if (textLower.contains('pedestrian crossing') || textLower.contains('zebra crossing') || textLower.contains('pelican crossing') || textLower.contains('toucan crossing') || textLower.contains('crossing')) {
      return 'assets/images/scenarios/pedestrian_crossing.svg';
    }
    if (textLower.contains('level crossing') || textLower.contains('railway') || textLower.contains('locomotive')) {
      return 'assets/images/signs/railway_crossing.svg';
    }
    if (textLower.contains('stop sign') || textLower.contains('stop line') || textLower.contains('must you stop')) {
      return 'assets/images/signs/stop_sign.svg';
    }
    if (textLower.contains('give way') || (textLower.contains('priority') && textLower.contains('oncoming'))) {
      return 'assets/images/signs/give_way.svg';
    }
    if (textLower.contains('no entry')) {
      return 'assets/images/signs/no_entry.svg';
    }
    if (textLower.contains('no overtaking') || textLower.contains('prohibit overtaking') || textLower.contains('must not overtake')) {
      return 'assets/images/signs/no_overtaking.svg';
    }
    if (textLower.contains('overtake') || textLower.contains('overtaking')) {
      return 'assets/images/scenarios/overtaking_safe.svg';
    }
    if (textLower.contains('no motor vehicles')) {
      return 'assets/images/signs/prohibition_circle.svg';
    }
    if (textLower.contains('parking') || textLower.contains('park') || textLower.contains('parked')) {
      return 'assets/images/signs/parking_sign.svg';
    }
    if (textLower.contains('motorway') || textLower.contains('smart motorway') || textLower.contains('hard shoulder')) {
      return 'assets/images/signs/motorway_green.svg';
    }
    if (textLower.contains('roadworks') || textLower.contains('road works') || textLower.contains('cones') || textLower.contains('contraflow')) {
      return 'assets/images/scenarios/road_works_zone.svg';
    }
    if (textLower.contains('school') || textLower.contains('children')) {
      return 'assets/images/signs/school_zone.svg';
    }
    if (textLower.contains('tram')) {
      return 'assets/images/signs/tram_mandatory.svg';
    }
    if (textLower.contains('cycle') || textLower.contains('bicycle') || textLower.contains('cyclist')) {
      return 'assets/images/signs/cycle_path.svg';
    }
    if (textLower.contains('low emission') || textLower.contains('lez') || textLower.contains('pollution')) {
      return 'assets/images/signs/lez_sign.svg';
    }
    if (textLower.contains('chevron') || textLower.contains('chevrons')) {
      return 'assets/images/signs/works_end.svg';
    }

    // Speed limits
    if (textLower.contains('speed limit') || textLower.contains('maximum speed')) {
      if (textLower.contains('30')) return 'assets/images/signs/zone30.svg';
      if (textLower.contains('50')) return 'assets/images/signs/speed_limit_50.svg';
      if (textLower.contains('70')) return 'assets/images/signs/speed_limit_70.svg';
      if (textLower.contains('90')) return 'assets/images/signs/speed_limit_90.svg';
      if (textLower.contains('120')) return 'assets/images/signs/speed_limit_120.svg';
    }

    if (textLower.contains('oil') || textLower.contains('dipstick')) {
      return 'assets/images/scenarios/oil_level.svg';
    }
    if (textLower.contains('coolant') || textLower.contains('overheating') || textLower.contains('temperature')) {
      return 'assets/images/scenarios/engine_warning.svg';
    }
    if (textLower.contains('brake fluid')) {
      return 'assets/images/scenarios/car_inspection.svg';
    }
    if (textLower.contains('battery') || textLower.contains('alternator')) {
      return 'assets/images/scenarios/car_inspection.svg';
    }
    if (textLower.contains('accident') || textLower.contains('casualty') || textLower.contains('first-aid') || textLower.contains('unconscious') || textLower.contains('breathing')) {
      return 'assets/images/scenarios/accident_scene.svg';
    }
    if (textLower.contains('cpr')) {
      return 'assets/images/scenarios/cpr_symbol.svg';
    }
    if (textLower.contains('bleeding')) {
      return 'assets/images/scenarios/bleeding_control.svg';
    }
    if (textLower.contains('spinal')) {
      return 'assets/images/scenarios/spinal_injury.svg';
    }
    if (textLower.contains('environment') || textLower.contains('fuel') || textLower.contains('eco-driving') || textLower.contains('emissions')) {
      return 'assets/images/scenarios/eco_driving.svg';
    }

    return null;
  }

  static String _fallbackSvgForTopic(String? topicId) {
    switch (topicId) {
      case 'road_signs':
        return 'assets/images/signs/general_warning.svg';
      case 'hazard_awareness':
        return 'assets/images/scenarios/blind_bend.svg';
      case 'motorway_rules':
        return 'assets/images/scenarios/motorway_exit.svg';
      case 'vehicle_safety':
        return 'assets/images/scenarios/car_inspection.svg';
      case 'rules_of_road':
        return 'assets/images/scenarios/pedestrian_crossing.svg';
      case 'road_works':
        return 'assets/images/scenarios/road_works_zone.svg';
      case 'accidents':
        return 'assets/images/scenarios/accident_scene.svg';
      case 'environment':
        return 'assets/images/scenarios/eco_driving.svg';
      default:
        return 'assets/images/signs/general_warning.svg';
    }
  }
}
