import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/providers/character_provider.dart';
import 'widgets/character_card.dart';

class CharacterListScreen extends ConsumerWidget {
  const CharacterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCharacters = ref.watch(characterListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daggerheart Companion'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/character/new'),
        icon: const Icon(Icons.add),
        label: Text(
          'New Character',
          style: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
        ),
      ),
      body: asyncCharacters.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text(
            'Error loading characters:\n$err',
            style: GoogleFonts.crimsonText(color: AppColors.textSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        data: (characters) {
          if (characters.isEmpty) {
            return _buildEmptyState(context);
          }

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              // ~70 % of a typical 1280 px desktop; also looks great on mobile
              constraints: const BoxConstraints(maxWidth: 860),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: characters.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final character = characters[index];
                  return SizedBox(
                    height: 96,
                    child: CharacterCard(
                      character: character,
                      onTap: () => context.push('/character/${character.id}'),
                      onDelete: () => _showDeleteDialog(
                          context, ref, character.id, character.name),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: const Icon(
              Icons.sports_martial_arts,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Characters Yet',
            style: GoogleFonts.cinzel(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your next adventure awaits.\nTap the button below to forge a legend.',
            style: GoogleFonts.crimsonText(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/character/new'),
            icon: const Icon(Icons.auto_fix_high),
            label: Text(
              'Forge a Legend',
              style: GoogleFonts.cinzel(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 120,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primary.withAlpha(180),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Character'),
        content: Text(
          'Are you sure you want to permanently delete "$name"?\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(characterListProvider.notifier).delete(id);
    }
  }
}
