import 'package:onlinetelecom/controllers/support_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/models/support_model.dart';
import 'package:get/get.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Reusable support directory. Call [SupportContactsSheet.show] from any page.
/// Uses the app-wide GetX support controller; does not refetch when opened.
class SupportContactsSheet extends StatefulWidget {
  const SupportContactsSheet({
    super.key,
    this.languageCode,
    this.defaultCountryDialCode = '93',
  });

  // Retained for backward compatibility with existing show(...) callers.
  // All translations come from LanguagesController.tr(...).
  final String? languageCode;
  final String defaultCountryDialCode;

  static Future<void> show(
    BuildContext context, {
    String? languageCode,
    String defaultCountryDialCode = '93',
  }) {
    FocusScope.of(context).unfocus();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => SupportContactsSheet(
        languageCode: languageCode,
        defaultCountryDialCode: defaultCountryDialCode,
      ),
    );
  }

  @override
  State<SupportContactsSheet> createState() => _SupportContactsSheetState();
}

class _SupportContactsSheetState extends State<SupportContactsSheet> {
  static const _blue = AppColors.primaryColor;
  static const _whatsAppGreen = Color(0xFF25D366);

  final SupportController _controller = Get.find<SupportController>();
  final LanguagesController languagesController =
      Get.find<LanguagesController>();

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryColor,
        content: Text(
          text,
          style: const TextStyle(color: AppColors.listbuilderboxColor),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// WhatsApp needs an international number without '+' or punctuation.
  /// Normalize only numbers whose country code is unambiguous.
  String? _whatsAppNumber(String raw) {
    final trimmed = raw.trim();
    var digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    } else if (trimmed.startsWith('+')) {
      // Already in international format.
    } else if (digits.startsWith('0')) {
      // Afghanistan local mobile format: 07XXXXXXXX (10 digits).
      if (widget.defaultCountryDialCode == '93' &&
          digits.length == 10 &&
          digits.startsWith('07')) {
        digits = '93${digits.substring(1)}';
      } else {
        return null; // Refuse to guess malformed or ambiguous numbers.
      }
    } else if (widget.defaultCountryDialCode == '93' &&
        digits.length == 9 &&
        digits.startsWith('7')) {
      digits = '93$digits';
    }
    if (digits.length < 8 || digits.length > 15) return null;
    return digits;
  }

  Future<void> _openWhatsApp(Contact contact) async {
    final digits = _whatsAppNumber(contact.phone ?? '');
    if (digits == null) {
      _message(languagesController.tr('SUPPORT_CONTACT_BAD_NUMBER'));
      return;
    }
    try {
      final uri = Uri.https('wa.me', '/$digits');
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _message(languagesController.tr('SUPPORT_CONTACT_OPEN_FAILED'));
      }
    } catch (_) {
      _message(languagesController.tr('SUPPORT_CONTACT_OPEN_FAILED'));
    }
  }

  Future<void> _call(Contact contact) async {
    final phone = contact.phone?.trim() ?? '';
    if (phone.isEmpty) return;
    try {
      final launched = await launchUrl(
        Uri(scheme: 'tel', path: phone),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _message(languagesController.tr('SUPPORT_CONTACT_OPEN_FAILED'));
      }
    } catch (_) {
      _message(languagesController.tr('SUPPORT_CONTACT_OPEN_FAILED'));
    }
  }

  @override
  Widget build(BuildContext context) {
    const surface = AppColors.listbuilderboxColor;
    const textColor = AppColors.primaryColor;
    const muted = AppColors.fontColor;
    const border = AppColors.secondaryColor;
    const tile = AppColors.secondaryColor;
    return Obx(() {
      // Rebuild translated labels when the selected language changes.
      // Layout direction is inherited from the app (no manual RTL override).
      languagesController.selectedlan.value;

      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.86,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _whatsAppGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: _whatsAppGreen,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languagesController.tr('CONTACT_SUPPORT'),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: languagesController.tr('SUPPORT_CONTACT_CLOSE'),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: muted),
                  ),
                ],
              ),
              const SizedBox(height: 19),
              Flexible(
                fit: FlexFit.loose,
                child: Obx(() {
                  final loading = _controller.isLoading.value;
                  final error = _controller.error.value;
                  final contacts =
                      (_controller.alldata.value.data?.contacts ?? <Contact>[])
                          .where(
                            (contact) =>
                                contact.status?.trim().toLowerCase() ==
                                    'active' &&
                                (contact.phone?.trim().isNotEmpty ?? false) &&
                                (contact.isWhatsapp == true ||
                                    contact.isPhone == true),
                          )
                          .toList(growable: false);

                  if (loading && contacts.isEmpty) {
                    return const SizedBox(
                      height: 170,
                      child: Center(
                        child: CircularProgressIndicator(color: _blue),
                      ),
                    );
                  }

                  if (error != null && contacts.isEmpty) {
                    return SizedBox(
                      height: 180,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off_rounded, color: muted, size: 30),
                          const SizedBox(height: 10),
                          Text(
                            languagesController.tr('SUPPORT_CONTACT_ERROR'),
                            style: TextStyle(color: muted),
                          ),
                          const SizedBox(height: 11),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor,
                              backgroundColor: surface,
                              side: const BorderSide(color: border),
                            ),
                            onPressed: () =>
                                _controller.fetchSupport(force: true),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(
                              languagesController.tr('SUPPORT_CONTACT_RETRY'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (contacts.isEmpty) {
                    return SizedBox(
                      height: 160,
                      child: Center(
                        child: Text(
                          languagesController.tr('SUPPORT_CONTACT_EMPTY'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: muted),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: contacts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _contactTile(
                      contacts[index],
                      surface: tile,
                      textColor: textColor,
                      muted: muted,
                      border: border,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _contactTile(
    Contact contact, {
    required Color surface,
    required Color textColor,
    required Color muted,
    required Color border,
  }) {
    final title = (contact.title ?? '').trim();
    final description = (contact.description ?? '').trim();
    final number = (contact.phone ?? '').trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            height: 39,
            width: 39,
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.headset_mic_outlined,
              size: 21,
              color: _blue,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty
                      ? languagesController.tr('SUPPORT_CONTACT_GENERIC')
                      : title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: muted,
                      fontSize: 11.1,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone_outlined, color: muted, size: 12),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        number,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: muted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          if (contact.isWhatsapp == true) ...[
            _action(
              tooltip: languagesController.tr('SUPPORT_CONTACT_WHATSAPP'),
              color: _whatsAppGreen,
              icon: const FaIcon(
                FontAwesomeIcons.whatsapp,
                size: 19,
                color: Colors.white,
              ),
              onTap: () => _openWhatsApp(contact),
            ),
            const SizedBox(width: 7),
          ],
          if (contact.isPhone == true)
            _action(
              tooltip: languagesController.tr('SUPPORT_CONTACT_CALL'),
              color: _blue,
              icon: const Icon(
                Icons.call_rounded,
                color: Colors.white,
                size: 18,
              ),
              onTap: () => _call(contact),
            ),
        ],
      ),
    );
  }

  Widget _action({
    required String tooltip,
    required Color color,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: SizedBox(width: 39, height: 39, child: Center(child: icon)),
        ),
      ),
    );
  }
}
