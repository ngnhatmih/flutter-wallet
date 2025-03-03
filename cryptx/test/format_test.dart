import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/utils/format.dart';

void main() {
  group('Format', () {
    test('should format address', () {
      const address = '0xD5278713631a98CED7c33F6c83D451b8197647F3';
      final formattedAddress = AddressFormat.formatAddress(address);
      expect(formattedAddress, '0xD527...47F3');
    });
  });
}