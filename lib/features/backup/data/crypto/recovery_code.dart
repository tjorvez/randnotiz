import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as hash;

/// The emergency key of a backup: 128 random bits, shown once to the user as
/// 28 Crockford-Base32 characters in groups of four, e.g.
/// `K7QM-2XRA-9F0T-…`. The last two characters are a checksum, so a typo is
/// noticed before the backup is even looked at.
///
/// Input is forgiving: case, spaces, dashes and any other non-alphanumeric
/// characters do not matter, `O` reads as
/// `0`, `I` and `L` read as `1` (Crockford's rules).
class RecoveryCode {
  RecoveryCode._(this.bytes);

  static const byteLength = 16;
  static const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  static const _dataChars = 26; // ceil(128 / 5), 2 padding bits
  static const _checkChars = 2; // 10 bits of SHA-256

  /// The 16 secret bytes.
  final Uint8List bytes;

  factory RecoveryCode.generate([Random? random]) {
    final r = random ?? Random.secure();
    return RecoveryCode._(
      Uint8List.fromList(List.generate(byteLength, (_) => r.nextInt(256))),
    );
  }

  factory RecoveryCode.fromBytes(List<int> bytes) {
    if (bytes.length != byteLength) {
      throw ArgumentError.value(bytes.length, 'bytes', 'must be 16 bytes');
    }
    return RecoveryCode._(Uint8List.fromList(bytes));
  }

  /// Parses user input; returns null if it is not a valid code (wrong
  /// length, unknown character or checksum mismatch).
  static RecoveryCode? tryParse(String input) {
    final normalized = input
        .toUpperCase()
        .replaceAll('O', '0')
        .replaceAll(RegExp('[IL]'), '1')
        // Separators, spaces, invisible characters from copy & paste.
        .replaceAll(RegExp('[^0-9A-Z]'), '');
    if (normalized.length != _dataChars + _checkChars) return null;
    final values = <int>[];
    for (final c in normalized.split('')) {
      final v = _alphabet.indexOf(c);
      if (v < 0) return null;
      values.add(v);
    }
    // 26 × 5 = 130 bits: 128 data bits and two zero bits.
    var acc = BigInt.zero;
    for (final v in values.take(_dataChars)) {
      acc = (acc << 5) | BigInt.from(v);
    }
    if ((acc & BigInt.from(3)) != BigInt.zero) return null;
    acc >>= 2;
    final bytes = Uint8List(byteLength);
    for (var i = byteLength - 1; i >= 0; i--) {
      bytes[i] = (acc & BigInt.from(0xff)).toInt();
      acc >>= 8;
    }
    final code = RecoveryCode._(bytes);
    final check = values.skip(_dataChars).toList();
    final expected = code._checksum();
    return check[0] == expected[0] && check[1] == expected[1] ? code : null;
  }

  List<int> _checksum() {
    final digest = hash.sha256.convert(bytes).bytes;
    final bits = (digest[0] << 2) | (digest[1] >> 6); // first 10 bits
    return [bits >> 5, bits & 31];
  }

  /// Without separators, 28 characters.
  String get compact {
    var acc = BigInt.zero;
    for (final b in bytes) {
      acc = (acc << 8) | BigInt.from(b);
    }
    acc <<= 2;
    final chars = List.filled(_dataChars, '');
    for (var i = _dataChars - 1; i >= 0; i--) {
      chars[i] = _alphabet[(acc & BigInt.from(31)).toInt()];
      acc >>= 5;
    }
    return chars.join() + _checksum().map((v) => _alphabet[v]).join();
  }

  /// For display: groups of four separated by dashes.
  String get formatted {
    final c = compact;
    return [for (var i = 0; i < c.length; i += 4) c.substring(i, i + 4)]
        .join('-');
  }

  @override
  bool operator ==(Object other) =>
      other is RecoveryCode && _equal(other.bytes, bytes);

  @override
  int get hashCode => Object.hashAll(bytes);

  @override
  String toString() => 'RecoveryCode(****)';
}

bool _equal(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}
