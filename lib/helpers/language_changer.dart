import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../global_controller/languages_controller.dart';
import '../utils/colors.dart';

class LanguageSelectorButton extends StatefulWidget {
  const LanguageSelectorButton({
    super.key,
    this.size = 40,
    this.iconSize = 24,
    this.child,
  });

  final double size;
  final double iconSize;

  /// Optional full-width tap target, e.g. a drawer menu row.
  /// If omitted, the original icon button is shown.
  final Widget? child;

  @override
  State<LanguageSelectorButton> createState() => _LanguageSelectorButtonState();
}

class _LanguageSelectorButtonState extends State<LanguageSelectorButton> {
  final LanguagesController languagesController =
      Get.find<LanguagesController>();

  final GetStorage box = GetStorage();

  final List<Map<String, String>> numberFormats = [
    {"name": "En", "fullname": "English", "example": "123456"},
    {"name": "Fa", "fullname": "فارسی", "example": "۱۲۳۴۵۶"},
    {"name": "Ar", "fullname": "العربية", "example": "١٢٣٤٥٦"},
    {"name": "Tr", "fullname": "Türkçe", "example": "123456"},
    {"name": "Ps", "fullname": "پښتو", "example": "۱۲۳۴۵۶"},
    {"name": "Bn", "fullname": "বাংলা", "example": "১২৩৪৫৬"},
  ];

  Locale _getLocale(String isoCode, String region) {
    switch (isoCode.toLowerCase()) {
      case 'fa':
        return const Locale('fa', 'IR');

      case 'ar':
        return const Locale('ar', 'AE');

      case 'ps':
        return const Locale('ps', 'AF');

      case 'tr':
        return const Locale('tr', 'TR');

      case 'bn':
        return const Locale('bn', 'BD');

      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }

  Future<void> _changeLanguage({
    required BuildContext context,
    required Map<String, dynamic> data,
  }) async {
    final String languageName = data['name']?.toString() ?? '';

    if (languageName.isEmpty) {
      return;
    }

    final Map<String, dynamic> matched = languagesController.alllanguagedata
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (language) => language['name']?.toString() == languageName,
          orElse: () => <String, dynamic>{
            'isoCode': 'en',
            'region': 'US',
            'direction': 'ltr',
          },
        );

    final String languageISO =
        matched['isoCode']?.toString().trim().toLowerCase() ?? 'en';

    final String languageRegion =
        matched['region']?.toString().trim().toUpperCase() ?? 'US';

    final String languageDirection =
        matched['direction']?.toString().trim().toLowerCase() ?? 'ltr';

    /// Change app language
    languagesController.changeLanguage(languageName);

    /// Save language and API locale settings (same as SplashScreen)
    await box.write('language', languageName);

    await box.write('language_iso', languageISO);

    await box.write('language_region', languageRegion);

    await box.write('direction', languageDirection);

    /// EasyLocalization
    final Locale locale = _getLocale(languageISO, languageRegion);

    if (!mounted) {
      return;
    }

    await EasyLocalization.of(context)?.setLocale(locale);

    if (!mounted) {
      return;
    }

    setState(() {});

    debugPrint(
      'Language changed to $languageName '
      '($languageISO-$languageRegion), '
      'Direction: $languageDirection',
    );
  }

  void _showLanguageSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            padding: const EdgeInsets.fromLTRB(16, 11, 16, 22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// =============================
                /// DRAG HANDLE
                /// =============================
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCD6E0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 17),

                /// =============================
                /// HEADER
                /// =============================
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.language_rounded,
                        color: AppColors.primaryColor,
                        size: 21,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        languagesController.tr('LANGUAGES'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF302A35),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(sheetContext);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F3F8),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 19,
                          color: Color(0xFF706977),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// =============================
                /// COLUMN HEADERS
                /// =============================
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(.06),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.language_rounded,
                              size: 17,
                              color: AppColors.primaryColor,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Language',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF302A35),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(.06),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.numbers_rounded,
                              size: 17,
                              color: AppColors.primaryColor,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Number Format',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF302A35),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// =============================
                /// LANGUAGE + NUMBER FORMAT
                /// =============================
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// =========================
                        /// LEFT SIDE - LANGUAGE
                        /// =========================
                        Expanded(
                          child: Obx(
                            () => Column(
                              children: List.generate(
                                languagesController.alllanguagedata.length,
                                (index) {
                                  final Map<String, dynamic>
                                  data = Map<String, dynamic>.from(
                                    languagesController.alllanguagedata[index],
                                  );

                                  final String languageName =
                                      data['name']?.toString() ?? '';

                                  final String fullName =
                                      data['fullname']?.toString() ??
                                      languageName;

                                  final bool isSelected =
                                      languagesController.selectedlan.value ==
                                      languageName;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(13),
                                        onTap: () async {
                                          await _changeLanguage(
                                            context: context,
                                            data: data,
                                          );
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 180,
                                          ),
                                          height: 58,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primaryColor
                                                      .withOpacity(.08)
                                                : const Color(0xFFFAF9FB),
                                            borderRadius: BorderRadius.circular(
                                              13,
                                            ),
                                            border: Border.all(
                                              width: isSelected ? 1.3 : 1,
                                              color: isSelected
                                                  ? AppColors.primaryColor
                                                  : const Color(0xFFEEE9F1),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  fullName,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w700
                                                        : FontWeight.w500,
                                                    color: isSelected
                                                        ? AppColors.primaryColor
                                                        : const Color(
                                                            0xFF514B57,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              if (isSelected) ...[
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 18,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// =========================
                        /// RIGHT SIDE - NUMBER FORMAT
                        /// =========================
                        Expanded(
                          child: Obx(
                            () => Column(
                              children: List.generate(numberFormats.length, (
                                index,
                              ) {
                                final data = numberFormats[index];

                                final String numberLanguage =
                                    data['name']?.toString() ?? '';

                                final bool isSelected =
                                    languagesController
                                        .selectedNumberLanguage
                                        .value ==
                                    numberLanguage;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(13),
                                      onTap: () {
                                        languagesController
                                            .changeNumberLanguage(
                                              numberLanguage,
                                            );

                                        debugPrint(
                                          'Number format changed to: '
                                          '$numberLanguage',
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        height: 58,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primaryColor
                                                    .withOpacity(.08)
                                              : const Color(0xFFFAF9FB),
                                          borderRadius: BorderRadius.circular(
                                            13,
                                          ),
                                          border: Border.all(
                                            width: isSelected ? 1.3 : 1,
                                            color: isSelected
                                                ? AppColors.primaryColor
                                                : const Color(0xFFEEE9F1),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data['fullname']
                                                            ?.toString() ??
                                                        '',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w700
                                                          : FontWeight.w500,
                                                      color: isSelected
                                                          ? AppColors
                                                                .primaryColor
                                                          : const Color(
                                                              0xFF514B57,
                                                            ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    data['example']
                                                            ?.toString() ??
                                                        '',
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isSelected
                                                          ? AppColors
                                                                .primaryColor
                                                          : const Color(
                                                              0xFF77717C,
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isSelected) ...[
                                              const SizedBox(width: 3),
                                              const Icon(
                                                Icons.check_circle_rounded,
                                                size: 18,
                                                color: AppColors.primaryColor,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// =============================
                /// DONE BUTTON
                /// =============================
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _showLanguageSheet,
      child:
          widget.child ??
          Container(
            height: widget.size,
            width: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primarycolor2.withOpacity(.30),
              ),
            ),
            child: Image.asset(
              'assets/icons/gridmenu.png',
              height: widget.iconSize,
              width: widget.iconSize,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.language_rounded,
                  color: AppColors.primaryColor,
                  size: widget.iconSize,
                );
              },
            ),
          ),
    );
  }
}
