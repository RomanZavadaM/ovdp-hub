import 'package:ovdp_hub/features/portfolio/portfolio_gateway.dart';
import 'package:ovdp_hub/features/portfolio/private_portfolio.dart';

class FakePortfolioGateway implements PortfolioGateway {
  @override
  final bool supported;
  PrivatePortfolioPayload? stored;
  bool locked = true;

  FakePortfolioGateway({
    this.supported = true,
    this.stored,
  });

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
    return stored!;
  }

  @override
  Future<PrivatePortfolioPayload> open() async {
    final value = stored;
    if (value == null) throw StateError('portfolio.open_failed');
    locked = false;
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
  }

  @override
  void dispose() {}
}
