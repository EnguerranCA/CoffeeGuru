import 'package:flutter/material.dart';
import '../models/badge.dart' as badge_model;

/// Widget pour afficher un badge avec animation de rotation
class BadgeDisplay extends StatefulWidget {
  final badge_model.Badge badge;
  final double size;

  const BadgeDisplay({
    super.key,
    required this.badge,
    this.size = 80,
  });

  @override
  State<BadgeDisplay> createState() => _BadgeDisplayState();
}

class _BadgeDisplayState extends State<BadgeDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159, // 360° en radians
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.badge.isUnlocked) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Afficher le dialogue de détails
        showDialog(
          context: context,
          builder: (context) => BadgeDetailDialog(badge: widget.badge),
        );
        
        // Animation de rotation au clic
        if (widget.badge.isUnlocked) {
          _controller.forward(from: 0);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: widget.badge.isUnlocked ? _rotationAnimation.value : 0,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.badge.isUnlocked
                        ? LinearGradient(
                            colors: [
                              widget.badge.color,
                              widget.badge.color.withOpacity(0.6),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: widget.badge.isUnlocked
                        ? null
                        : Colors.grey.shade300,
                    boxShadow: widget.badge.isUnlocked
                        ? [
                            BoxShadow(
                              color: widget.badge.color.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    widget.badge.icon,
                    size: widget.size * 0.5,
                    color: widget.badge.isUnlocked
                        ? Colors.white
                        : Colors.grey.shade500,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            widget.badge.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: widget.badge.isUnlocked
                  ? Colors.black87
                  : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.badge.isUnlocked && widget.badge.unlockedAt != null)
            Text(
              _formatDate(widget.badge.unlockedAt!),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Widget pour afficher une grille de badges
class BadgeGrid extends StatelessWidget {
  final List<badge_model.Badge> badges;

  const BadgeGrid({
    super.key,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        return BadgeDisplay(badge: badges[index]);
      },
    );
  }
}

/// Dialogue pour afficher les détails d'un badge
class BadgeDetailDialog extends StatelessWidget {
  final badge_model.Badge badge;

  const BadgeDetailDialog({
    super.key,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BadgeDisplay(badge: badge, size: 120),
            const SizedBox(height: 24),
            Text(
              badge.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              badge.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (badge.isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: badge.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: badge.color, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Débloqué',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Verrouillé',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }
}
