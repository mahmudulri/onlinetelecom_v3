import 'package:onlinetelecom/controllers/dashboard_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/screens/change_password_screen.dart';
import 'package:onlinetelecom/screens/change_pin.dart';
import 'package:onlinetelecom/screens/commission_group_screen.dart';
import 'package:onlinetelecom/screens/helpscreen.dart';
import 'package:onlinetelecom/screens/profile_screen.dart';
import 'package:onlinetelecom/screens/selling_price_screen.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/custom_text.dart';
import 'package:onlinetelecom/widgets/app_social_links_sheet.dart';
import 'package:onlinetelecom/widgets/support_contacts_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'contact_dialogbox.dart';
import 'language_number_dialog.dart';
import 'logoutbox.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final GetStorage box = GetStorage();

  String _version = '';

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _background =>
      _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _foreground => Theme.of(context).colorScheme.onSurface;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _primary => Theme.of(context).colorScheme.primary;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _version = info.version);
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = box.read('direction')?.toString().toLowerCase() == 'rtl';
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final shape = isRtl
        ? const BorderRadius.only(
            topLeft: Radius.circular(26),
            bottomLeft: Radius.circular(26),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(26),
            bottomRight: Radius.circular(26),
          );

    return Material(
      color: Colors.transparent,
      child: Container(
        width: screenWidth < 320 ? screenWidth * .88 : 300,
        height: double.infinity,
        decoration: BoxDecoration(color: _background, borderRadius: shape),
        clipBehavior: Clip.antiAlias,
        child: Obx(() {
          final bool deactivated =
              dashboardController.deactiveStatus.value.trim().toLowerCase() ==
              'deactivated';
          if (deactivated) return _buildDeactivatedState();

          return Column(
            children: [
              _buildDrawerHeader(isRtl: isRtl),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  children: [
                    DrawerMenu(
                      imageLink: 'assets/icons/drawerprofile.png',
                      menuName: languagesController.tr('PROFILE'),
                      onPressed: () => _openPage(ProfileScreen()),
                    ),
                    DrawerMenu(
                      imageLink: 'assets/icons/faq.png',
                      menuName: languagesController.tr('SET_SALE_PRICE'),
                      onPressed: () => _openPage(SellingPriceScreen()),
                    ),
                    DrawerMenu(
                      imageLink: 'assets/icons/discount.png',
                      menuName: languagesController.tr('COMMISSION_GROUP'),
                      onPressed: () => _openPage(CommissionGroupScreen()),
                    ),
                    DrawerMenu(
                      imageLink: 'assets/icons/key.png',
                      menuName: languagesController.tr('CHANGE_PIN'),
                      onPressed: () => _openPage(ChangePinScreen()),
                    ),
                    DrawerMenu(
                      imageLink: 'assets/icons/padlock.png',
                      menuName: languagesController.tr('CHANGE_PASSWORD'),
                      onPressed: () => _openPage(ChangePasswordScreen()),
                    ),
                    DrawerMenu(
                      imageLink: 'assets/icons/drawerguide.png',
                      menuName: languagesController.tr('HELP'),
                      onPressed: () => _openPage(Helpscreen()),
                    ),

                    DrawerMenu(
                      imageLink: 'assets/icons/global.png',
                      menuName: languagesController.tr('LANGUAGES'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => LanguageNumberDialog(
                            languagesController: languagesController,
                          ),
                        );
                      },
                    ),
                    _buildSupportArea(context),
                    const SizedBox(height: 9),
                    DrawerMenu(
                      imageLink: 'assets/icons/logout.png',
                      menuName: languagesController.tr('LOGOUT'),
                      isDestructive: true,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            contentPadding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            content: LogoutDialogBox(),
                          ),
                        );
                      },
                    ),

                    Center(
                      child: NText(
                        text:
                            '${languagesController.tr("VERSION")} ${_version.isEmpty ? "..." : _version}',
                        color: _muted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// Prefer the Contact Support translation; fall back to Contact Us if needed.
  String _supportTitle() {
    final translated = languagesController.tr('CONTACT_SUPPORT');
    return translated == 'CONTACT_SUPPORT'
        ? languagesController.tr('CONTACTUS')
        : translated;
  }

  /// Same Support + Social Media layout as AfghanNet's drawer, adapted
  /// to Online Telecom's light/dark color scheme.
  Widget _buildSupportArea(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 370;
    final Color surface = _surface;
    final Color borderColor = _border;
    final Color primaryColor = _primary;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () => SupportContactsSheet.show(
                context,
                languageCode: languagesController.selectedlan.value,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                backgroundColor: surface,
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                padding: EdgeInsets.symmetric(horizontal: compact ? 9 : 12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded, size: 19),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      _supportTitle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!compact)
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: languagesController.tr('FIND_US_ON'),
          child: Material(
            color: surface,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              onTap: () => AppSocialLinksSheet.show(context),
              borderRadius: BorderRadius.circular(13),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: borderColor),
                ),
                child: Image.asset(
                  'assets/icons/social-media.png',
                  height: 22,
                  width: 22,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.public_rounded, color: primaryColor),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerHeader({required bool isRtl}) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return SizedBox(
      width: double.infinity,
      height: 133 + topPadding,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _dark
                      ? const [Color(0xFF17462A), Color(0xFF0E7537)]
                      : const [Color(0xFF168944), Color(0xFF22B963)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -72,
            right: -42,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.07),
                border: Border.all(color: Colors.white.withOpacity(.12)),
              ),
            ),
          ),
          Positioned(
            bottom: -84,
            left: -35,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.06),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(top: topPadding + 9),
              child: Container(
                height: 90,
                width: 90,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.98),
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(
                    color: Colors.white.withOpacity(.65),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icons/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 11,
            right: isRtl ? null : 12,
            left: isRtl ? 12 : null,
            child: Material(
              color: Colors.white.withOpacity(.16),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  height: 34,
                  width: 34,
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPage(Widget page) {
    mypagecontroller.changePage(page, isMainPage: false);
    Navigator.pop(context);
  }

  Widget _buildDeactivatedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.block_rounded,
                color: Colors.redAccent,
                size: 35,
              ),
            ),
            const SizedBox(height: 16),
            NText(
              text: dashboardController.deactivateMessage.value.toString(),
              color: _foreground,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
              height: 1.4,
            ),
          ],
        ),
      ),
    );
  }
}

/// One compact, glossy menu row. The original DrawerMenu public API is retained.
class DrawerMenu extends StatelessWidget {
  const DrawerMenu({
    super.key,
    required this.menuName,
    required this.imageLink,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String menuName;
  final String imageLink;
  final VoidCallback onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final foreground = theme.colorScheme.onSurface;
    final muted = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accent = isDestructive ? const Color(0xFFE46060) : primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Ink(
            height: 49,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppColors.darkCard, AppColors.darkSurface]
                    : isDestructive
                    ? [Colors.white, const Color(0xFFFFF8F8)]
                    : [Colors.white, const Color(0xFFF4FAF6)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDestructive
                    ? accent.withOpacity(isDark ? .27 : .15)
                    : border.withOpacity(isDark ? .85 : 1),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: primary.withOpacity(.025),
                        blurRadius: 9,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Container(
                    height: 33,
                    width: 33,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withOpacity(isDark ? .20 : .13),
                          accent.withOpacity(isDark ? .08 : .045),
                        ],
                      ),
                    ),
                    child: Image.asset(
                      imageLink,
                      color: accent,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.circle_outlined, color: accent, size: 19),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: NText(
                      text: menuName,
                      color: isDestructive ? accent : foreground,
                      fontSize: 12.8,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 17,
                    color: isDestructive ? accent.withOpacity(.65) : muted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
