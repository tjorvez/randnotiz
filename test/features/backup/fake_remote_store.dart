import 'dart:typed_data';

import 'package:randnotiz/features/backup/data/remote/remote_store.dart';

/// In-memory backup folder. Records every upload, can fail after a number
/// of writes (to simulate an interrupted backup).
class FakeRemoteStore implements RemoteStore {
  final files = <String, ({String name, Uint8List bytes})>{};
  final uploads = <String>[];
  final deletes = <String>[];
  var _next = 0;

  /// Throws on the write after this many more successful writes.
  int? failAfterWrites;

  Set<String> get names => {for (final f in files.values) f.name};

  Uint8List bytesOf(String name) =>
      files.values.firstWhere((f) => f.name == name).bytes;

  void _maybeFail() {
    if (failAfterWrites == null) return;
    if (failAfterWrites == 0) {
      throw const RemoteUnavailableException('simulated');
    }
    failAfterWrites = failAfterWrites! - 1;
  }

  @override
  Future<List<RemoteFile>> list() async => [
    for (final MapEntry(:key, :value) in files.entries)
      RemoteFile(id: key, name: value.name, size: value.bytes.length),
  ];

  @override
  Future<Uint8List> read(String id) async {
    final f = files[id];
    if (f == null) throw const RemoteNotFoundException();
    return f.bytes;
  }

  @override
  Future<RemoteFile> create(String name, Uint8List bytes) async {
    _maybeFail();
    final id = 'id${_next++}';
    files[id] = (name: name, bytes: Uint8List.fromList(bytes));
    uploads.add(name);
    return RemoteFile(id: id, name: name, size: bytes.length);
  }

  @override
  Future<RemoteFile> update(String id, Uint8List bytes) async {
    _maybeFail();
    final f = files[id];
    if (f == null) throw const RemoteNotFoundException();
    files[id] = (name: f.name, bytes: Uint8List.fromList(bytes));
    uploads.add(f.name);
    return RemoteFile(id: id, name: f.name, size: bytes.length);
  }

  @override
  Future<void> delete(String id) async {
    final f = files.remove(id);
    if (f != null) deletes.add(f.name);
  }
}
