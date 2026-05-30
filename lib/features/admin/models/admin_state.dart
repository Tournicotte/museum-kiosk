sealed class AdminState {
  const AdminState();
}

final class AdminLocked extends AdminState {
  const AdminLocked({this.errorKey});
  // null = no error, 'incorrectPin' = wrong PIN
  final String? errorKey;
}

final class AdminUnlocked extends AdminState {
  const AdminUnlocked();
}
