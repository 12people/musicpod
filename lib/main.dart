import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:gtk/gtk.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mpris_service/mpris_service.dart';
import 'package:musicpod/musicpod.dart';
import 'package:musicpod/service/library_service.dart';
import 'package:musicpod/service/local_audio_service.dart';
import 'package:musicpod/service/podcast_service.dart';
import 'package:musicpod/service/radio_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

Future<void> main(List<String> args) async {
  await YaruWindowTitleBar.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final libraryService = LibraryService();
  await libraryService.init();

  final player = Player(
    configuration: const PlayerConfiguration(title: 'MusicPod'),
  );
  registerService<Player>(
    () => player,
    dispose: (p) => p.dispose(),
  );

  registerService<VideoController>(() => VideoController(player));

  final mpris = await MPRIS.create(
    busName: 'org.mpris.MediaPlayer2.musicpod',
    identity: 'Musicpod',
    desktopEntry: '/var/lib/snapd/desktop/applications/musicpod',
  );

  registerService<MPRIS>(
    () => mpris,
    dispose: (s) async => await s.dispose(),
  );

  registerService<LibraryService>(
    () => libraryService,
    dispose: (s) async => await s.dispose(),
  );
  registerService<LocalAudioService>(
    LocalAudioService.new,
    dispose: (s) async => await s.dispose(),
  );
  registerService<PodcastService>(
    PodcastService.new,
    dispose: (s) async => await s.dispose(),
  );
  final connectivity = Connectivity();
  registerService<Connectivity>(
    () => connectivity,
  );
  registerService<NotificationsClient>(
    NotificationsClient.new,
    dispose: (s) async => await s.close(),
  );
  registerService<GtkApplicationNotifier>(
    () => GtkApplicationNotifier(args),
    dispose: (s) => s.dispose(),
  );

  registerService<RadioService>(() => RadioService(connectivity));

  runApp(const MusicPod());
}
