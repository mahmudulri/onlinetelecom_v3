import 'package:onlinetelecom/services/dashboard_service.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../global_controller/languages_controller.dart';
import '../global_controller/page_controller.dart';
import 'receipts_screen.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final Mypagecontroller mypagecontroller = Get.put(Mypagecontroller());

  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );

  final List<String> namesKeys = const [
    'HOME',
    'TRANSACTIONS',
    'ORDERS',
    'NETWORK',
  ];

  final List<String> imagedata = const [
    'assets/icons/home.png',
    'assets/icons/transactiontype.png',
    'assets/icons/orders.png',
    'assets/icons/network.png',
  ];

  int selectedIndex = 0;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _background =>
      _isDark ? AppColors.darkBackground : AppColors.lightBackground;

  Color get _navSurface =>
      _isDark ? AppColors.darkCard : AppColors.lightSurface;

  Color get _border => _isDark ? AppColors.darkBorder : AppColors.lightBorder;

  Color get _muted =>
      _isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  Color get _primary => Theme.of(context).colorScheme.primary;

  @override
  void initState() {
    super.initState();

    // The system bar appearance is now handled in build(), so it responds
    // automatically when the existing app-level theme changes.
    mypagecontroller.setUpdateIndexCallback((index) {
      if (!mounted) {
        return;
      }

      setState(() {
        selectedIndex = index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color background = _background;
    final Color navSurface = _navSurface;
    final Color borderColor = _border;
    final Color primary = _primary;
    final bool dark = _isDark;

    final SystemUiOverlayStyle overlayStyle = dark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: background,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: background,
            systemNavigationBarIconBrightness: Brightness.dark,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }

          if (mypagecontroller.pageStack.length > 1) {
            mypagecontroller.goBack();
          } else {
            SystemNavigator.pop();
          }
        },
        child: Obx(
          () => Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: background,
            extendBody: true,
            body: mypagecontroller.pageStack.last,

            /// Center action button: same receipts action, theme-aware border.
            floatingActionButton: Transform.translate(
              offset: const Offset(0, 4),
              child: GestureDetector(
                onTap: _openReceipts,
                child: Container(
                  height: 62,
                  width: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.onlinetelecomAccent,
                      ],
                    ),
                    border: Border.all(color: navSurface, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(dark ? 0.35 : 0.28),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(dark ? 0.20 : 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 31,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,

            /// Bottom navigation: same size / routes, with a subtle glossy finish.
            bottomNavigationBar: SafeArea(
              top: false,
              child: Container(
                height: 76,
                margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: dark
                        ? [
                            Color.lerp(navSurface, Colors.white, 0.055)!,
                            navSurface,
                          ]
                        : [
                            Colors.white,
                            Color.lerp(navSurface, primary, 0.018)!,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: dark ? borderColor : primary.withOpacity(0.11),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.24 : 0.055),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: mypagecontroller.lastSelectedIndex == 0 ? 6 : 5,
                      child: _buildNavItem(0),
                    ),
                    Expanded(
                      flex: mypagecontroller.lastSelectedIndex == 1 ? 6 : 5,
                      child: _buildNavItem(1),
                    ),
                    const SizedBox(width: 46),
                    Expanded(
                      flex: mypagecontroller.lastSelectedIndex == 2 ? 6 : 5,
                      child: _buildNavItem(2),
                    ),
                    Expanded(
                      flex: mypagecontroller.lastSelectedIndex == 3 ? 6 : 5,
                      child: _buildNavItem(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Nav item: preserve click behavior and sizing; add light reflections.
  Widget _buildNavItem(int index) {
    final bool isSelected = mypagecontroller.lastSelectedIndex == index;
    final bool dark = _isDark;
    final Color primary = _primary;
    final Color muted = _muted;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        mypagecontroller.goToMainPageByIndex(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withOpacity(dark ? 0.24 : 0.13),
                    primary.withOpacity(dark ? 0.08 : 0.035),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(dark ? 0.035 : 0.22),
                    Colors.transparent,
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primary.withOpacity(dark ? 0.33 : 0.13)
                : Colors.transparent,
            width: 0.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(dark ? 0.08 : 0.055),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // A narrow translucent top sheen creates the glossy effect.
            Positioned(
              top: 0,
              left: 7,
              right: 7,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                    isSelected ? (dark ? 0.15 : 0.78) : (dark ? 0.04 : 0.42),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 3,
                  width: isSelected ? 22 : 0,
                  margin: const EdgeInsets.only(bottom: 3),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Image.asset(
                  imagedata[index],
                  width: 22,
                  height: 22,
                  color: isSelected ? primary : muted,
                ),
                const SizedBox(height: 3),
                SizedBox(
                  width: double.infinity,
                  height: 13,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: NText(
                      text: languagesController.tr(namesKeys[index]),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      fontSize: isSelected ? 10.5 : 10,
                      height: 1.0,
                      color: isSelected ? primary : muted,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Existing receipts action remains unchanged.
  void _openReceipts() {
    if (dashboardController.deactiveStatus.value.trim().toLowerCase() ==
        'deactivated') {
      Get.snackbar(
        dashboardController.deactiveStatus.toString(),
        dashboardController.deactivateMessage.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 1),
        icon: const Icon(Icons.block_rounded, color: Colors.white),
      );

      return;
    }

    mypagecontroller.changePage(const ReceiptsScreen(), isMainPage: false);
  }
}
