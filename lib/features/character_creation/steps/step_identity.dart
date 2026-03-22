import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class StepIdentity extends StatefulWidget {
  final String name;
  final String pronouns;
  final void Function(String name, String pronouns) onChanged;

  const StepIdentity({
    super.key,
    required this.name,
    required this.pronouns,
    required this.onChanged,
  });

  @override
  State<StepIdentity> createState() => _StepIdentityState();
}

class _StepIdentityState extends State<StepIdentity> {
  late final TextEditingController _nameController;
  late final TextEditingController _pronounsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _pronounsController = TextEditingController(text: widget.pronouns);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pronounsController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(_nameController.text.trim(), _pronounsController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who are you?',
            style: GoogleFonts.cinzel(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Every legend starts with a name. What do people call you?',
            style: GoogleFonts.crimsonText(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Character Name *',
            style: GoogleFonts.cinzel(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            onChanged: (_) => _notify(),
            textCapitalization: TextCapitalization.words,
            style: GoogleFonts.crimsonText(
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter character name...',
              prefixIcon: const Icon(Icons.person_outline),
              hintStyle: GoogleFonts.crimsonText(color: AppColors.textDisabled),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Pronouns (optional)',
            style: GoogleFonts.cinzel(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pronounsController,
            onChanged: (_) => _notify(),
            style: GoogleFonts.crimsonText(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. she/her, he/him, they/them',
              prefixIcon: const Icon(Icons.tag),
              hintStyle: GoogleFonts.crimsonText(color: AppColors.textDisabled),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your character name will appear on all screens. Pronouns help other players refer to your character correctly.',
                    style: GoogleFonts.crimsonText(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
