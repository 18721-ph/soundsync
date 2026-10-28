import 'package:flutter/foundation.dart';

enum SoundProfile { balanced, bassBoost, clearVoice }

class SoundProfileService extends ChangeNotifier {
  SoundProfile _selectedProfile = SoundProfile.balanced;

  double _bass = 0;
  double _midrange = 0;
  double _treble = 0;

  SoundProfile get selectedProfile => _selectedProfile;
  double get bass => _bass;
  double get midrange => _midrange;
  double get treble => _treble;

  String get selectedProfileName {
    switch (_selectedProfile) {
      case SoundProfile.balanced:
        return 'Balanced';
      case SoundProfile.bassBoost:
        return 'Bass Boost';
      case SoundProfile.clearVoice:
        return 'Clear Voice';
    }
  }

  void selectProfile(SoundProfile profile) {
    _selectedProfile = profile;

    switch (profile) {
      case SoundProfile.balanced:
        _bass = 0;
        _midrange = 0;
        _treble = 0;
        break;

      case SoundProfile.bassBoost:
        _bass = 6;
        _midrange = 0;
        _treble = 2;
        break;

      case SoundProfile.clearVoice:
        _bass = -2;
        _midrange = 4;
        _treble = 3;
        break;
    }

    notifyListeners();
  }

  void setBass(double value) {
    _bass = value.clamp(-12.0, 12.0).toDouble();
    _selectedProfile = SoundProfile.balanced;
    notifyListeners();
  }

  void setMidrange(double value) {
    _midrange = value.clamp(-12.0, 12.0).toDouble();
    _selectedProfile = SoundProfile.balanced;
    notifyListeners();
  }

  void setTreble(double value) {
    _treble = value.clamp(-12.0, 12.0).toDouble();
    _selectedProfile = SoundProfile.balanced;
    notifyListeners();
  }

  void reset() {
    _selectedProfile = SoundProfile.balanced;
    _bass = 0;
    _midrange = 0;
    _treble = 0;
    notifyListeners();
  }
}
