import 'package:audioplayers/audioplayers.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:music/data/audio.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class PlayerModel extends SafeChangeNotifier {
  PlayerModel() : _audioPlayer = AudioPlayer();

  Audio? _audio;
  Audio? get audio => _audio;
  set audio(Audio? value) {
    if (value == _audio) return;
    _audio = value;
    if (_audio?.audioType == AudioType.radio) {
      _repeatSingle = null;
    } else {
      _repeatSingle = _repeatSingle ?? false;
    }
    _duration = Duration.zero;
    _position = Duration.zero;
    notifyListeners();
  }

  final AudioPlayer _audioPlayer;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  set isPlaying(bool value) {
    if (value == _isPlaying) return;
    _isPlaying = value;
    notifyListeners();
  }

  Duration? _duration;
  Duration? get duration => _duration;
  set duration(Duration? value) {
    if (value == _duration) return;
    _duration = value;
    notifyListeners();
  }

  Duration? _position;
  Duration? get position => _position;
  set position(Duration? value) {
    if (value == _position) return;
    _position = value;
    notifyListeners();
  }

  Metadata? _metadata;
  Metadata? get metaData => _metadata;
  set metaData(Metadata? value) {
    if (value == null || value == _metadata) return;
    _metadata = value;
    notifyListeners();
  }

  bool? _repeatSingle;
  bool? get repeatSingle => _repeatSingle;
  set repeatSingle(bool? value) {
    if (value == null || value == _repeatSingle) return;
    _repeatSingle = value;
    notifyListeners();
  }

  Future<void> play() async {
    if (audio == null) return;

    if (audio!.audioType == AudioType.radio && audio!.resourceUrl != null) {
      await _audioPlayer.play(UrlSource(audio!.resourceUrl!));
    } else if (audio!.audioType == AudioType.local &&
        audio!.resourcePath != null) {
      await _audioPlayer.play(DeviceFileSource(audio!.resourcePath!));
    }
  }

  Future<void> pause() async {
    if (audio == null) return;

    await _audioPlayer.pause();
  }

  Future<void> seek() async {
    if (position == null) return;
    await _audioPlayer.seek(position!);
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  Future<void> setImage() async {
    if (audio != null &&
        audio!.audioType == AudioType.local &&
        audio!.resourcePath != null) {
      metaData = await MetadataGod.getMetadata(audio!.resourcePath!);
    }
  }

  Future<void> init() async {
    // Lame trick to avoid min max issues at first track
    duration = const Duration(hours: 100);
    _audioPlayer.onPlayerStateChanged.listen((playerState) {
      isPlaying = playerState == PlayerState.playing;
    });
    _audioPlayer.onDurationChanged.listen((newDuration) {
      duration = newDuration;
    });
    _audioPlayer.onPositionChanged.listen((newPosition) {
      position = newPosition;
    });

    _audioPlayer.onPlayerComplete.listen((_) async {
      if (repeatSingle == true) {
        position = Duration.zero;
        await seek();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}