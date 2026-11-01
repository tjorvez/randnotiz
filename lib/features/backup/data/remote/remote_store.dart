import 'dart:typed_data';

/// A file in the backup folder on the server.
class RemoteFile {
  const RemoteFile({
    required this.id,
    required this.name,
    required this.size,
    this.modifiedAt,
  });

  final String id;
  final String name;
  final int size;
  final DateTime? modifiedAt;

  @override
  String toString() => 'RemoteFile($name, $size B)';
}

/// The access to the server was refused (signed out, consent revoked) –
/// the user has to connect again.
class RemoteAuthException implements Exception {
  const RemoteAuthException([this.message = '']);

  final String message;

  @override
  String toString() => 'RemoteAuthException: $message';
}

/// No connection, timeout or a server error – trying again later may help.
class RemoteUnavailableException implements Exception {
  const RemoteUnavailableException([this.message = '']);

  final String message;

  @override
  String toString() => 'RemoteUnavailableException: $message';
}

/// The file does not exist (any more).
class RemoteNotFoundException implements Exception {
  const RemoteNotFoundException();
}

/// The storage quota of the account is used up.
class RemoteQuotaException implements Exception {
  const RemoteQuotaException();
}

/// A flat folder of files (the hidden app folder of Google Drive). Names
/// are not unique on Drive; callers address files by [RemoteFile.id] and
/// treat duplicate names themselves.
abstract interface class RemoteStore {
  Future<List<RemoteFile>> list();

  Future<Uint8List> read(String id);

  Future<RemoteFile> create(String name, Uint8List bytes);

  /// Replaces the content of an existing file.
  Future<RemoteFile> update(String id, Uint8List bytes);

  Future<void> delete(String id);
}
