import 'dart:async';
import 'package:ovdp_hub/features/portfolio/portfolio_gateway.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';

class FakePortfolioGateway implements PortfolioGateway {
  @override
  final bool supported;
  PrivatePortfolioPayload? stored;
  bool locked = true;
  final _unlockChanges = StreamController<bool>.broadcast(sync: true);

  FakePortfolioGateway({
    this.supported = true,
    this.stored,
  });

  @override
  bool get unlocked => !locked;

  @override
  Stream<bool> get unlockChanges => _unlockChanges.stream;

  @override
  Future<bool> exists() async => stored != null;

  @override
  Future<PrivatePortfolioPayload> create({
    required String recoverySecret,
  }) async {
    if (recoverySecret.length < 12) {
      throw const FormatException('portfolio.recovery_secret_too_short');
    }
    if (stored != null) throw StateError('vault.already_exists');
    stored = PrivatePortfolioPayload(portfolioId: 'primary');
    locked = false;
    _unlockChanges.add(true);
    return stored!;
  }

  @override
  Future<PrivatePortfolioPayload> open() async {
    final value = stored;
    if (value == null) throw StateError('portfolio.open_failed');
    locked = false;
    _unlockChanges.add(true);
    return value;
  }

  @override
  Future<void> save(PrivatePortfolioPayload payload) async {
    if (locked) throw StateError('vault.session_locked');
    stored = payload;
  }

  @override
  Future<void> lock() async {
    locked = true;
    _unlockChanges.add(false);
  }

  @override
  void onBackground() {}

  @override
  Future<void> onForeground() async {}

  @override
  Future<void> dispose() => _unlockChanges.close();
}
