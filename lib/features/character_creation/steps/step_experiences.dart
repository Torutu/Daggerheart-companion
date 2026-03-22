import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/character_model.dart';

class StepExperiences extends StatelessWidget {
  final List<ExperienceEntry> experiences;
  final void Function(List<ExperienceEntry>) onChanged;

  const StepExperiences({
    super.key,
    required this.experiences,
    required this.onChanged,
  });

  static const List<String> _exampleNames = [
    'Former soldier', 'Street urchin', 'Apprentice mage',
    'Sailor', 'Scholar of ancient ruins', 'Thief-catcher',
    'Animal trainer', 'Herbalist', 'Negotiator',
  ];

  void _addExperience() {
    if (experiences.length < 2) {
      onChanged([...experiences, const ExperienceEntry(name: '', modifier: 1)]);
    }
  }

  void _updateName(int index, String name) {
    final updated = List<ExperienceEntry>.from(experiences);
    updated[index] = ExperienceEntry(name: name, modifier: experiences[index].modifier);
    onChanged(updated);
  }

  void _updateModifier(int index, int modifier) {
    final updated = List<ExperienceEntry>.from(experiences);
    updated[index] = ExperienceEntry(name: experiences[index].name, modifier: modifier);
    onChanged(updated);
  }

  void _remove(int index) {
    final updated = List<ExperienceEntry>.from(experiences);
    updated.removeAt(index);
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Experiences',
            style: GoogleFonts.cinzel(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add up to 2 experiences from your character\'s past. Each gives you a +1 bonus to relevant rolls.',
            style: GoogleFonts.crimsonText(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Examples:',
                  style: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDisabled,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _exampleNames.map((e) {
                    return GestureDetector(
                      onTap: experiences.length < 2
                          ? () {
                              onChanged([
                                ...experiences,
                                ExperienceEntry(name: e, modifier: 1),
                              ]);
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          e,
                          style: GoogleFonts.crimsonText(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Experience entries
          ...List.generate(experiences.length, (i) {
            return _ExperienceCard(
              index: i,
              entry: experiences[i],
              onNameChanged: (name) => _updateName(i, name),
              onModifierChanged: (mod) => _updateModifier(i, mod),
              onRemove: () => _remove(i),
            );
          }),

          if (experiences.length < 2) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addExperience,
                icon: const Icon(Icons.add),
                label: Text(
                  'Add Experience (${experiences.length}/2)',
                  style: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExperienceCard extends StatefulWidget {
  final int index;
  final ExperienceEntry entry;
  final void Function(String) onNameChanged;
  final void Function(int) onModifierChanged;
  final VoidCallback onRemove;

  const _ExperienceCard({
    required this.index,
    required this.entry,
    required this.onNameChanged,
    required this.onModifierChanged,
    required this.onRemove,
  });

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entry.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Experience ${widget.index + 1}',
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.textDisabled),
                onPressed: widget.onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            onChanged: widget.onNameChanged,
            style: GoogleFonts.crimsonText(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Experience name...',
              hintStyle: GoogleFonts.crimsonText(color: AppColors.textDisabled),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Modifier: ',
                style: GoogleFonts.crimsonText(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              DropdownButton<int>(
                value: widget.entry.modifier,
                dropdownColor: AppColors.surface,
                style: GoogleFonts.cinzel(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                items: [1, 2, 3].map((v) {
                  return DropdownMenuItem(
                    value: v,
                    child: Text('+$v'),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) widget.onModifierChanged(v);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
