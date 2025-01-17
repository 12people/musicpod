import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AlbumPage extends StatelessWidget {
  const AlbumPage({
    super.key,
    required this.id,
    required this.isPinnedAlbum,
    required this.removePinnedAlbum,
    required this.album,
    required this.addPinnedAlbum,
    this.onTextTap,
  });

  static Widget createIcon(
    BuildContext context,
    Uint8List? picture,
  ) {
    Widget? albumArt;
    if (picture != null) {
      albumArt = SizedBox(
        width: kYaruIconSize,
        height: kYaruIconSize,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.memory(
            picture,
            height: kYaruIconSize,
            fit: BoxFit.fitHeight,
            filterQuality: FilterQuality.medium,
          ),
        ),
      );
    }
    return albumArt ??
        const Icon(
          YaruIcons.playlist_play,
        );
  }

  final String id;
  final bool Function(String name) isPinnedAlbum;
  final void Function(String name) removePinnedAlbum;
  final Set<Audio>? album;
  final void Function(String name, Set<Audio> audios) addPinnedAlbum;
  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

  @override
  Widget build(BuildContext context) {
    return AudioPage(
      onTextTap: onTextTap,
      audioPageType: AudioPageType.album,
      headerLabel: context.l10n.album,
      headerSubtile: album?.firstOrNull?.artist,
      image: album?.firstOrNull?.pictureData != null
          ? Image.memory(
              album!.firstOrNull!.pictureData!,
              width: 200.0,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.medium,
            )
          : null,
      controlPanelButton: isPinnedAlbum(id)
          ? IconButton(
              icon: Icon(
                YaruIcons.pin,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () => removePinnedAlbum(
                id,
              ),
            )
          : IconButton(
              icon: const Icon(
                YaruIcons.pin,
              ),
              onPressed: album == null
                  ? null
                  : () => addPinnedAlbum(
                        id,
                        album!,
                      ),
            ),
      audios: album,
      pageId: id,
      headerTitle: album?.firstOrNull?.album,
    );
  }
}
