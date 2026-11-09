import 'package:flutter_test/flutter_test.dart';
import 'package:soundsync/services/sound_profile_service.dart';

void main() {
  test('non-finite parameters leave the profile unchanged', () {
    final service = SoundProfileService();
    service.setBass(double.nan);
    service.setMidrange(double.infinity);
    service.setTreble(double.negativeInfinity);
    expect(service.bass, 0);
    expect(service.midrange, 0);
    expect(service.treble, 0);
    expect(service.selectedProfile, SoundProfile.balanced);
    service.dispose();
  });
  test(
    'manual adjustment preserves other frequencies and clears the preset',
    () {
      final service = SoundProfileService();

      service.selectProfile(SoundProfile.bassBoost);
      service.setBass(8);

      expect(service.selectedProfile, isNull);
      expect(service.selectedProfileName, 'Custom');
      expect(service.bass, 8);
      expect(service.midrange, 0);
      expect(service.treble, 2);
    },
  );

  test('frequency values are limited and reset restores Balanced', () {
    final service = SoundProfileService();

    service.setBass(20);
    service.setMidrange(-20);
    service.setTreble(6);

    expect(service.bass, 12);
    expect(service.midrange, -12);
    expect(service.treble, 6);

    service.reset();

    expect(service.selectedProfile, SoundProfile.balanced);
    expect(service.bass, 0);
    expect(service.midrange, 0);
    expect(service.treble, 0);
  });
}
