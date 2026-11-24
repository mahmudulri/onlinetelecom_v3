import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/app_setting_controller.dart';
import '../global_controller/languages_controller.dart';
import '../models/setting_model.dart';
import '../utils/colors.dart';

class AppSocialLinksSheet extends StatelessWidget {
  AppSocialLinksSheet({super.key});

  static const Color _blue = AppColors.primaryColor;

  final AppSettingController _settingsController =
      Get.find<AppSettingController>();
  final LanguagesController languagesController =
      Get.find<LanguagesController>();

  static Future<void> show(BuildContext context) {
    FocusScope.of(context).unfocus();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => AppSocialLinksSheet(),
    );
  }

  String _tr(String key) => languagesController.tr(key);

  Uri? _safeWebUri(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        !uri.hasAuthority ||
        uri.host.isEmpty) {
      return null;
    }

    return uri;
  }

  String _preview(Uri uri) {
    final host = uri.host.replaceFirst(RegExp(r'^www\.'), '');
    final path = uri.path == '/' ? '' : uri.path;
    return '$host$path';
  }

  String _handle(String? handle, Uri uri) {
    final cleaned = (handle ?? '').trim().replaceFirst(RegExp(r'^@+'), '');
    return cleaned.isNotEmpty ? '@$cleaned' : _preview(uri);
  }

  List<_SocialDestination> _destinations(Settings? settings) {
    if (settings == null) return const [];

    final items = <_SocialDestination>[];

    void add({
      required String name,
      required String? url,
      required Widget icon,
      required Color color,
      String? username,
    }) {
      final uri = _safeWebUri(url);
      if (uri == null) return;

      items.add(
        _SocialDestination(
          name: name,
          uri: uri,
          subtitle: username == null ? _preview(uri) : _handle(username, uri),
          icon: icon,
          color: color,
        ),
      );
    }

    add(
      name: 'Telegram',
      url: settings.telegramUrl,
      username: settings.telegramUsername,
      icon: const FaIcon(FontAwesomeIcons.telegram),
      color: const Color(0xFF229ED9),
    );
    add(
      name: 'Facebook',
      url: settings.facebookPageUrl,
      icon: const FaIcon(FontAwesomeIcons.facebook),
      color: const Color(0xFF1877F2),
    );
    add(
      name: 'Instagram',
      url: settings.instagramUrl,
      username: settings.instagramHandle,
      icon: const FaIcon(FontAwesomeIcons.instagram),
      color: const Color(0xFFE1306C),
    );
    add(
      name: 'X (Twitter)',
      url: settings.twitterUrl,
      icon: const FaIcon(FontAwesomeIcons.twitter),
      color: const Color(0xFF1D9BF0),
    );
    add(
      name: 'TikTok',
      url: settings.tiktokUrl,
      icon: const FaIcon(FontAwesomeIcons.tiktok),
      color: const Color(0xFF111111),
    );
    add(
      name: 'YouTube',
      url: settings.youtubeUrl,
      icon: const FaIcon(FontAwesomeIcons.youtube),
      color: const Color(0xFFFF0033),
    );
    add(
      name: 'Website',
      url: settings.websiteUrl,
      icon: const Icon(Icons.language_rounded),
      color: _blue,
    );

    return items;
  }

  Future<void> _openLink(BuildContext context, Uri uri) async {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened && context.mounted) {
        _message(context, _tr('SOCIAL_LINKS_OPEN_FAILED'));
      }
    } catch (_) {
      if (context.mounted) {
        _message(context, _tr('SOCIAL_LINKS_OPEN_FAILED'));
      }
    }
  }

  void _message(BuildContext context, String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryColor,
        behavior: SnackBarBehavior.floating,
        content: Text(
          value,
          style: const TextStyle(color: AppColors.listbuilderboxColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const surface = AppColors.listbuilderboxColor;
    const textColor = AppColors.primaryColor;
    const muted = AppColors.fontColor;
    const border = AppColors.secondaryColor;
    const tile = AppColors.secondaryColor;

    return Obx(() {
      // Rebuild the translated labels when the selected language changes.
      languagesController.selectedlan.value;

      final loading = _settingsController.isLoading.value;
      final error = _settingsController.error.value;
      final destinations = _destinations(_settingsController.settings);

      return SafeArea(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.86,
          ),
          decoration: const BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(17, 11, 17, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 42,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 17),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _blue.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.public_rounded,
                        color: _blue,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _tr('FIND_US_ON'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: _tr('SUPPORT_CONTACT_CLOSE'),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, color: muted),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                Flexible(
                  fit: FlexFit.loose,
                  child: loading && destinations.isEmpty
                      ? const SizedBox(
                          height: 160,
                          child: Center(
                            child: CircularProgressIndicator(color: _blue),
                          ),
                        )
                      : error != null && destinations.isEmpty
                      ? SizedBox(
                          height: 175,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.wifi_off_rounded,
                                size: 31,
                                color: muted,
                              ),
                              const SizedBox(height: 9),
                              Text(
                                _tr('SOCIAL_LINKS_ERROR'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: muted),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: textColor,
                                  backgroundColor: surface,
                                  side: const BorderSide(color: border),
                                ),
                                onPressed: () => _settingsController
                                    .fetchAppSetting(force: true),
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(_tr('SUPPORT_CONTACT_RETRY')),
                              ),
                            ],
                          ),
                        )
                      : destinations.isEmpty
                      ? SizedBox(
                          height: 145,
                          child: Center(
                            child: Text(
                              _tr('SOCIAL_LINKS_EMPTY'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: muted),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 3),
                          itemCount: destinations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 9),
                          itemBuilder: (context, index) => _socialTile(
                            context,
                            destinations[index],
                            background: tile,
                            border: border,
                            textColor: textColor,
                            muted: muted,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _socialTile(
    BuildContext context,
    _SocialDestination item, {
    required Color background,
    required Color border,
    required Color textColor,
    required Color muted,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openLink(context, item.uri),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                height: 43,
                width: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: IconTheme(
                  data: IconThemeData(size: 21, color: item.color),
                  child: item.icon,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: muted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.open_in_new_rounded, size: 18, color: _blue),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialDestination {
  const _SocialDestination({
    required this.name,
    required this.uri,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String name;
  final Uri uri;
  final String subtitle;
  final Widget icon;
  final Color color;
}
