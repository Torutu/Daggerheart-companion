import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/character_list/character_list_screen.dart';
import '../../features/character_creation/creation_wizard_screen.dart';
import '../../features/character_sheet/character_sheet_screen.dart';
import '../../features/level_up/level_up_screen.dart';
import '../../features/domain_cards/cards_browser_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CharacterListScreen(),
    ),
    GoRoute(
      path: '/character/new',
      builder: (context, state) => const CreationWizardScreen(),
    ),
    GoRoute(
      path: '/character/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return CharacterSheetScreen(characterId: id);
      },
    ),
    GoRoute(
      path: '/character/:id/level-up',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return LevelUpScreen(characterId: id);
      },
    ),
    GoRoute(
      path: '/character/:id/cards',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return CardsBrowserScreen(characterId: id);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Route not found: ${state.error}'),
    ),
  ),
);
