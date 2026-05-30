// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paymentHash() => r'78e1639e9e5a352ace8336a7c5c91b2b16d78374';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$Payment extends BuildlessAutoDisposeNotifier<PaymentState> {
  late final String orderId;

  PaymentState build(
    String orderId,
  );
}

/// See also [Payment].
@ProviderFor(Payment)
const paymentProvider = PaymentFamily();

/// See also [Payment].
class PaymentFamily extends Family<PaymentState> {
  /// See also [Payment].
  const PaymentFamily();

  /// See also [Payment].
  PaymentProvider call(
    String orderId,
  ) {
    return PaymentProvider(
      orderId,
    );
  }

  @override
  PaymentProvider getProviderOverride(
    covariant PaymentProvider provider,
  ) {
    return call(
      provider.orderId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'paymentProvider';
}

/// See also [Payment].
class PaymentProvider
    extends AutoDisposeNotifierProviderImpl<Payment, PaymentState> {
  /// See also [Payment].
  PaymentProvider(
    String orderId,
  ) : this._internal(
          () => Payment()..orderId = orderId,
          from: paymentProvider,
          name: r'paymentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$paymentHash,
          dependencies: PaymentFamily._dependencies,
          allTransitiveDependencies: PaymentFamily._allTransitiveDependencies,
          orderId: orderId,
        );

  PaymentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  PaymentState runNotifierBuild(
    covariant Payment notifier,
  ) {
    return notifier.build(
      orderId,
    );
  }

  @override
  Override overrideWith(Payment Function() create) {
    return ProviderOverride(
      origin: this,
      override: PaymentProvider._internal(
        () => create()..orderId = orderId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<Payment, PaymentState> createElement() {
    return _PaymentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PaymentRef on AutoDisposeNotifierProviderRef<PaymentState> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _PaymentProviderElement
    extends AutoDisposeNotifierProviderElement<Payment, PaymentState>
    with PaymentRef {
  _PaymentProviderElement(super.provider);

  @override
  String get orderId => (origin as PaymentProvider).orderId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
