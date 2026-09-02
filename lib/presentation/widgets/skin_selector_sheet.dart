import 'package:block/domain/models/block_skin.dart';
import 'package:block/presentation/view_models/skin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// เปิด Bottom Sheet เลือกสกิน
void showSkinSelectorSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _SkinSelectorSheet(),
  );
}

class _SkinSelectorSheet extends ConsumerWidget {
  const _SkinSelectorSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSkin = ref.watch(skinNotifierProvider);

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              spreadRadius: 2,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            '— SELECT SKIN —',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 5,
              color: Colors.black45,
              fontFamily: 'sans-serif',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'BLOCK SKIN',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
              color: Colors.black87,
              fontFamily: 'sans-serif',
            ),
          ),
          const SizedBox(height: 20),

          // Skin grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: allSkins.length,
                itemBuilder: (context, index) {
                  final skin = allSkins[index];
                  final isSelected = currentSkin.id == skin.id;
                  return _SkinCard(
                    skin: skin,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(skinNotifierProvider.notifier).selectSkin(skin.id);
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ));
  }
}

class _SkinCard extends StatefulWidget {
  final BlockSkin skin;
  final bool isSelected;
  final VoidCallback onTap;

  const _SkinCard({
    required this.skin,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SkinCard> createState() => _SkinCardState();
}

class _SkinCardState extends State<_SkinCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  // สีตัวอย่าง 4 สี สำหรับ preview
  static const _previewColors = [
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = widget.skin.accentColor;
    final isSelected = widget.isSelected;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? accent
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Selected check
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: accent,
                    size: 16,
                  ),
                ),

              // Preview: 2x2 grid of sample cells
              SizedBox(
                width: 52,
                height: 52,
                child: GridView.count(
                  crossAxisCount: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: _previewColors.map((c) {
                    return widget.skin.cellBuilder(
                      cellSize: 24,
                      color: c,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Label
              Text(
                widget.skin.displayName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: isSelected
                      ? accent
                      : Colors.black54,
                  fontFamily: 'sans-serif',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
