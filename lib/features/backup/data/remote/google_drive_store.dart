import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'remote_store.dart';

/// Supplies OAuth access tokens for the `drive.appdata` scope.
abstract interface class AccessTokenSource {
  /// A token, obtained without user interaction. Throws
  /// [RemoteAuthException] if the user has to connect again.
  Future<String> accessToken();

  /// Drops a token the server rejected, so the next call gets a fresh one.
  Future<void> invalidate(String token);
}

/// [RemoteStore] on the hidden app folder of Google Drive (REST v3, scope
/// `drive.appdata`): only this app can see the files, and the app cannot
/// see any other Drive file. Plain `http`, no Google client library.
class GoogleDriveStore implements RemoteStore {
  GoogleDriveStore(
    this._client,
    this._tokens, {
    this.timeout = const Duration(seconds: 30),
    this.uploadTimeout = const Duration(minutes: 2),
  });

  static const _api = 'https://www.googleapis.com/drive/v3/files';
  static const _upload = 'https://www.googleapis.com/upload/drive/v3/files';
  static const _fields = 'id,name,size,modifiedTime';

  final http.Client _client;
  final AccessTokenSource _tokens;
  final Duration timeout;
  final Duration uploadTimeout;

  @override
  Future<List<RemoteFile>> list() async {
    final files = <RemoteFile>[];
    String? pageToken;
    do {
      final uri = Uri.parse(_api).replace(
        queryParameters: {
          'spaces': 'appDataFolder',
          'fields': 'nextPageToken,files($_fields)',
          'pageSize': '1000',
          'pageToken': ?pageToken,
        },
      );
      final response = await _send(() => http.Request('GET', uri), timeout);
      final json = _json(response);
      for (final f in (json['files'] as List? ?? const [])) {
        files.add(_file(f as Map<String, Object?>));
      }
      pageToken = json['nextPageToken'] as String?;
    } while (pageToken != null);
    return files;
  }

  @override
  Future<Uint8List> read(String id) async {
    final uri = Uri.parse('$_api/$id')
        .replace(queryParameters: {'alt': 'media'});
    final response = await _send(() => http.Request('GET', uri), uploadTimeout);
    return response.bodyBytes;
  }

  @override
  Future<RemoteFile> create(String name, Uint8List bytes) async {
    final uri = Uri.parse(
      _upload,
    ).replace(queryParameters: {'uploadType': 'multipart', 'fields': _fields});
    final response = await _send(
      () => _multipart('POST', uri, {
        'name': name,
        'parents': ['appDataFolder'],
      }, bytes),
      uploadTimeout,
    );
    return _file(_json(response));
  }

  @override
  Future<RemoteFile> update(String id, Uint8List bytes) async {
    final uri = Uri.parse(
      '$_upload/$id',
    ).replace(queryParameters: {'uploadType': 'multipart', 'fields': _fields});
    final response = await _send(
      () => _multipart('PATCH', uri, const {}, bytes),
      uploadTimeout,
    );
    return _file(_json(response));
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _send(
        () => http.Request('DELETE', Uri.parse('$_api/$id')),
        timeout,
      );
    } on RemoteNotFoundException {
      // Already gone.
    }
  }

  static http.Request _multipart(
    String method,
    Uri uri,
    Map<String, Object?> metadata,
    Uint8List bytes,
  ) {
    final r = Random.secure();
    final boundary =
        'randnotiz${List.generate(16, (_) => r.nextInt(36).toRadixString(36)).join()}';
    final head = utf8.encode(
      '--$boundary\r\n'
      'Content-Type: application/json; charset=UTF-8\r\n\r\n'
      '${jsonEncode(metadata)}\r\n'
      '--$boundary\r\n'
      'Content-Type: application/octet-stream\r\n\r\n',
    );
    final tail = utf8.encode('\r\n--$boundary--\r\n');
    return http.Request(method, uri)
      ..headers['Content-Type'] = 'multipart/related; boundary=$boundary'
      ..bodyBytes = Uint8List.fromList([...head, ...bytes, ...tail]);
  }

  /// Sends a request with a token; on 401 once more with a fresh token.
  Future<http.Response> _send(
    http.Request Function() build,
    Duration limit,
  ) async {
    for (var attempt = 0; ; attempt++) {
      final token = await _tokens.accessToken();
      final request = build()..headers['Authorization'] = 'Bearer $token';
      final http.Response response;
      try {
        response = await http.Response.fromStream(
          await _client.send(request).timeout(limit),
        ).timeout(limit);
      } on TimeoutException {
        throw const RemoteUnavailableException('timeout');
      } on http.ClientException catch (e) {
        throw RemoteUnavailableException(e.message);
      } on SocketException catch (e) {
        throw RemoteUnavailableException(e.message);
      }
      final status = response.statusCode;
      if (status >= 200 && status < 300) return response;
      if (status == 401 && attempt == 0) {
        await _tokens.invalidate(token);
        continue;
      }
      final reason = _reason(response);
      debugPrint('Drive ${request.method} failed: $status $reason');
      if (status == 401) throw RemoteAuthException(reason);
      if (status == 404) throw const RemoteNotFoundException();
      if (status == 403 &&
          (reason == 'storageQuotaExceeded' || reason == 'quotaExceeded')) {
        throw const RemoteQuotaException();
      }
      if (status == 403 &&
          (reason == 'insufficientPermissions' ||
              reason == 'appNotAuthorizedToFile' ||
              reason == 'forbidden')) {
        throw RemoteAuthException(reason);
      }
      throw RemoteUnavailableException('HTTP $status $reason');
    }
  }

  static String _reason(http.Response response) {
    try {
      final json = jsonDecode(response.body) as Map<String, Object?>;
      final error = json['error'] as Map<String, Object?>?;
      final errors = error?['errors'] as List?;
      if (errors != null && errors.isNotEmpty) {
        return ((errors.first as Map)['reason'] as String?) ?? '';
      }
      return (error?['status'] as String?) ?? '';
    } on Object {
      return '';
    }
  }

  static Map<String, Object?> _json(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, Object?>;
    } on Object {
      throw const RemoteUnavailableException('unexpected response');
    }
  }

  static RemoteFile _file(Map<String, Object?> f) => RemoteFile(
    id: f['id']! as String,
    name: (f['name'] as String?) ?? '',
    size: int.tryParse('${f['size'] ?? 0}') ?? 0,
    modifiedAt: f['modifiedTime'] == null
        ? null
        : DateTime.tryParse(f['modifiedTime']! as String),
  );
}
