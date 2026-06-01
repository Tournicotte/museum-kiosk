// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todaySalesHash() => r'45bcc99be6ce624f05932e4ff9b006286fb37754';

/// See also [todaySales].
@ProviderFor(todaySales)
final todaySalesProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  todaySales,
  name: r'todaySalesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todaySalesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodaySalesRef = AutoDisposeFutureProviderRef<List<Order>>;
String _$adminHash() => r'af74f75845384fb0f34324b032744911b961eeeb';

/// See also [Admin].
@ProviderFor(Admin)
final adminProvider = AutoDisposeNotifierProvider<Admin, AdminState>.internal(
  Admin.new,
  name: r'adminProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$adminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Admin = AutoDisposeNotifier<AdminState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
