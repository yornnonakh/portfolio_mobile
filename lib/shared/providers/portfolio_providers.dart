import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/portfolio_repository.dart';
import '../models/portfolio.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>(
  (ref) => const LocalPortfolioRepository(),
);
final portfolioProvider = Provider<Portfolio>(
  (ref) => ref.watch(portfolioRepositoryProvider).load(),
);
