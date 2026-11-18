import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart' as hash;
import 'package:flutter_test/flutter_test.dart';
import 'package:randnotiz/features/backup/data/crypto/backup_cipher.dart';
import 'package:randnotiz/features/backup/data/crypto/key_ring.dart';
import 'package:randnotiz/features/backup/data/crypto/recovery_code.dart';

import 'backup_fixtures.dart';

void main() {
  group('RecoveryCode', () {
    test('round-trips through its display form', () {
      final r = Random(1);
      for (var i = 0; i < 50; i++) {
        final code = RecoveryCode.generate(r);
        expect(
          code.formatted,
          matches(RegExp(r'^([0-9A-Z]{4}-){6}[0-9A-Z]{4}$')),
        );
        expect(RecoveryCode.tryParse(code.formatted), code);
        expect(RecoveryCode.tryParse(code.compact), code);
      }
    });

    test('accepts lower case, spaces and look-alike letters', () {
      final code = RecoveryCode.fromBytes(List.generate(16, (i) => i * 7));
      final sloppy = code.formatted
          .toLowerCase()
          .replaceAll('-', ' ')
          .replaceAll('0', 'o')
          .replaceAll('1', 'l');
      expect(RecoveryCode.tryParse(sloppy), code);
      expect(RecoveryCode.tryParse(' ${code.formatted}\u200b\n'), code);
    });

    test('rejects typos via the checksum', () {
      final code = RecoveryCode.generate(Random(2));
      final c = code.compact;
      var rejected = 0;
      for (var i = 0; i < c.length; i++) {
        final other = c[i] == 'A' ? 'B' : 'A';
        final typo = c.replaceRange(i, i + 1, other);
        if (RecoveryCode.tryParse(typo) == null) rejected++;
      }
      // A 10-bit checksum lets about 1 in 1000 typos through; with 28
      // single-character changes all are caught in practice.
      expect(rejected, c.length);
      expect(RecoveryCode.tryParse('${c}X'), isNull);
      expect(RecoveryCode.tryParse(c.substring(1)), isNull);
      expect(RecoveryCode.tryParse('U${c.substring(1)}'), isNull);
    });

    test('never shows the secret in toString', () {
      expect(RecoveryCode.generate().toString(), isNot(contains('-')));
    });
  });

  group('KeyRing', () {
    test('opens with the password and with the emergency key', () async {
      final created = await KeyRing.create('richtig geheim', kdf: fastKdf);
      final ring = KeyRing.decode(created.ring.encode());
      expect(await ring.unlockWithPassword('richtig geheim'), created.dataKey);
      expect(
        await ring.unlockWithRecoveryCode(created.recoveryCode),
        created.dataKey,
      );
      expect(
        await ring.unlock(created.recoveryCode.formatted),
        created.dataKey,
      );
      expect(await ring.unlock('richtig geheim'), created.dataKey);
    });

    test('a password that looks like an emergency key still works', () async {
      final lookalike = RecoveryCode.generate(Random(5)).formatted;
      final created = await KeyRing.create(lookalike, kdf: fastKdf);
      expect(await created.ring.unlock(lookalike), created.dataKey);
    });

    test('spaces in a password count', () async {
      final created = await KeyRing.create(' mit Leerzeichen ', kdf: fastKdf);
      expect(await created.ring.unlock(' mit Leerzeichen '), created.dataKey);
      await expectLater(
        created.ring.unlock('mit Leerzeichen'),
        throwsA(isA<WrongSecretException>()),
      );
    });

    test('rejects a wrong password or emergency key', () async {
      final created = await KeyRing.create('richtig geheim', kdf: fastKdf);
      await expectLater(
        created.ring.unlockWithPassword('falsch'),
        throwsA(isA<WrongSecretException>()),
      );
      await expectLater(
        created.ring.unlockWithRecoveryCode(RecoveryCode.generate()),
        throwsA(isA<WrongSecretException>()),
      );
    });

    test('contains no secret in the clear', () async {
      final created = await KeyRing.create('richtig geheim', kdf: fastKdf);
      final json = created.ring.encode();
      expect(json, isNot(contains('richtig geheim')));
      expect(json, isNot(contains(created.recoveryCode.compact)));
      expect(json, isNot(contains(base64Encode(created.dataKey))));
    });

    test('a new password keeps data key and emergency key', () async {
      final created = await KeyRing.create('alt alt alt', kdf: fastKdf);
      final changed = await created.ring.withNewPassword(
        created.dataKey,
        'neu neu neu',
      );
      expect(changed.keyId, created.ring.keyId);
      expect(await changed.unlockWithPassword('neu neu neu'), created.dataKey);
      expect(
        await changed.unlockWithRecoveryCode(created.recoveryCode),
        created.dataKey,
      );
      await expectLater(
        changed.unlockWithPassword('alt alt alt'),
        throwsA(isA<WrongSecretException>()),
      );
    });

    test('a new emergency key replaces the old one', () async {
      final created = await KeyRing.create('passwort!!', kdf: fastKdf);
      final renewed = await created.ring.withNewRecoveryCode(created.dataKey);
      expect(
        await renewed.ring.unlockWithRecoveryCode(renewed.recoveryCode),
        created.dataKey,
      );
      expect(
        await renewed.ring.unlockWithPassword('passwort!!'),
        created.dataKey,
      );
      await expectLater(
        renewed.ring.unlockWithRecoveryCode(created.recoveryCode),
        throwsA(isA<WrongSecretException>()),
      );
    });

    test('rejects other formats and newer versions', () {
      expect(() => KeyRing.decode('{"format":"x"}'), throwsFormatException);
      expect(
        () => KeyRing.decode('{"format":"randnotiz-keyring","version":99}'),
        throwsFormatException,
      );
    });
  });

  group('BackupCipher', () {
    late BackupCipher cipher;
    setUp(() async {
      cipher = await BackupCipher.create(List.filled(32, 7), keyId: 'k1');
    });

    test('round-trips and hides the plaintext', () async {
      final plain = utf8.encode('Liebes Tagebuch, heute am Meer.');
      final sealed = await cipher.seal(plain, objectName: 'snapshot-1.bin');
      expect(
        utf8.decode(sealed, allowMalformed: true),
        isNot(contains('Tagebuch')),
      );
      expect(BackupCipher.keyIdOf(sealed), 'k1');
      expect(await cipher.open(sealed, objectName: 'snapshot-1.bin'), plain);
    });

    test('uses a fresh nonce for every object', () async {
      final a = await cipher.seal([1, 2, 3], objectName: 'x');
      final b = await cipher.seal([1, 2, 3], objectName: 'x');
      expect(a, isNot(equals(b)));
    });

    test('detects a changed byte', () async {
      final sealed = await cipher.seal(List.filled(100, 1), objectName: 'x');
      for (final i in [10, 30, sealed.length - 1]) {
        final broken = [...sealed];
        broken[i] ^= 1;
        await expectLater(
          cipher.open(broken, objectName: 'x'),
          throwsA(isA<BackupIntegrityException>()),
        );
      }
    });

    test('detects a swapped object', () async {
      final sealed = await cipher.seal([1, 2, 3], objectName: 'b-aaa');
      await expectLater(
        cipher.open(sealed, objectName: 'b-bbb'),
        throwsA(isA<BackupIntegrityException>()),
      );
    });

    test('detects another data key', () async {
      final other = await BackupCipher.create(List.filled(32, 8), keyId: 'k2');
      final sealed = await other.seal([1, 2, 3], objectName: 'x');
      await expectLater(
        cipher.open(sealed, objectName: 'x'),
        throwsA(isA<BackupIntegrityException>()),
      );
      final sameId = await BackupCipher.create(List.filled(32, 8), keyId: 'k1');
      final sealed2 = await sameId.seal([1, 2, 3], objectName: 'x');
      await expectLater(
        cipher.open(sealed2, objectName: 'x'),
        throwsA(isA<BackupIntegrityException>()),
      );
    });

    test('blob names are keyed and deterministic', () async {
      final other = await BackupCipher.create(List.filled(32, 8), keyId: 'k1');
      const sha = 'abc123';
      expect(cipher.blobNameFor(sha), cipher.blobNameFor(sha));
      expect(cipher.blobNameFor(sha), startsWith('b-'));
      expect(cipher.blobNameFor(sha), isNot(other.blobNameFor(sha)));
      expect(cipher.blobNameFor(sha), isNot(contains(sha)));
    });

    // The sub-keys come from HKDF without salt. Android's HMAC rejects an
    // empty key, so the code passes 32 zero bytes – which must derive the
    // same keys as RFC 5869 with an empty salt (the backup format).
    test('sub-keys are HKDF-SHA256 with an empty salt', () {
      final prk = hash.Hmac(hash.sha256, const []).convert(List.filled(32, 7));
      final nameKey = hash.Hmac(
        hash.sha256,
        prk.bytes,
      ).convert([...utf8.encode('randnotiz name v1'), 1]);
      final expected = hash.Hmac(
        hash.sha256,
        nameKey.bytes,
      ).convert(utf8.encode('abc123'));
      expect(cipher.blobNameFor('abc123'), 'b-$expected');
      expect(BackupCipher.hkdfNoSalt, List.filled(32, 0));
    });
  });
}
