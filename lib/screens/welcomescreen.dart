import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/routes/routes.dart';
import 'package:onlinetelecom/screens/sign_up_screen.dart';
import 'package:onlinetelecom/utils/colors.dart';

class Welcomescreen extends StatefulWidget {
  const Welcomescreen({super.key});

  @override
  State<Welcomescreen> createState() => _WelcomescreenState();
}

class _WelcomescreenState extends State<Welcomescreen> {
  final LanguagesController languagesController =
      Get.find<LanguagesController>();
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final ThemeController themeController = Get.find<ThemeController>();
  final PageController titlePageController = PageController();

  Timer? sliderTimer;
  int currentTitlePage = 0;

  List<Map<String, String>> get titleSlides => [
    {
      'title': languagesController.tr('ALL_YOUR_FINANCIAL_SERVICES_IN_ONE_APP'),
      'subtitle': languagesController.tr(
        'RECHARGE_PAY_TRANSFER_AND_MANAGE_YOUR_EVERYDAY_PAYMENTS_EASILY',
      ),
    },
    {
      'title': languagesController.tr('FAST_AND_SECURE_MOBILE_RECHARGE'),
      'subtitle': languagesController.tr(
        'RECHARGE_AFGHANISTAN_TURKEY_AND_MORE_NETWORKS_QUICKLY_AND_SECURELY',
      ),
    },
    {
      'title': languagesController.tr('SIMPLE_PAYMENTS_ANYWHERE_ANYTIME'),
      'subtitle': languagesController.tr(
        'EVERYTHING_YOU_NEED_FOR_TELECOM_AND_DIGITAL_PAYMENTS_IN_ONE_PLACE',
      ),
    },
  ];

  @override
  void initState() {
    super.initState();
    sliderTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !titlePageController.hasClients) return;
      titlePageController.animateToPage(
        (currentTitlePage + 1) % 3,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    sliderTimer?.cancel();
    titlePageController.dispose();
    super.dispose();
  }

  Future<bool> showExitPopup() async {
    if (mypagecontroller.pageStack.length > 1) {
      mypagecontroller.goBack();
      return false;
    }

    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(languagesController.tr('EXIT_APP')),
        content: Text(languagesController.tr('DO_YOU_WANT_TO_EXIT_APP')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(languagesController.tr('NO')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              languagesController.tr('YES'),
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void showContinueOptions() {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 13, 24, 28),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(.18),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 27),
              Container(
                height: 62,
                width: 62,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.colorScheme.primary,
                  size: 29,
                ),
              ),
              const SizedBox(height: 17),
              Text(
                'Online Telecom',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Choose how you want to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: dark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              _actionButton(
                context: sheetContext,
                label: languagesController.tr('REGISTER'),
                filled: true,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Get.to(() => const SignUpScreen());
                },
              ),
              const SizedBox(height: 12),
              _actionButton(
                context: sheetContext,
                label: languagesController.tr('LOGIN'),
                filled: false,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Get.offAllNamed(signinscreen);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required String label,
    required bool filled,
    required VoidCallback onPressed,
  }) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: filled
          ? FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary.withOpacity(.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final foreground = theme.colorScheme.onSurface;
    final secondary = dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: WillPopScope(
        onWillPop: showExitPopup,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                final compact = availableHeight < 690;
                final veryCompact = availableHeight < 570;
                final heroHeight = (availableHeight * (veryCompact ? .31 : .36))
                    .clamp(145.0, 286.0);
                final titleHeight = (availableHeight * .20).clamp(94.0, 146.0);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: veryCompact ? 4 : 12),
                      _header(theme),
                      const Spacer(flex: 2),
                      SizedBox(height: heroHeight, child: _heroArtwork(theme)),
                      const Spacer(flex: 2),
                      Text(
                        'ONE APP. MORE POSSIBILITIES.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 10,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: compact ? 8 : 14),
                      SizedBox(
                        height: titleHeight,
                        child: PageView.builder(
                          controller: titlePageController,
                          itemCount: titleSlides.length,
                          onPageChanged: (index) =>
                              setState(() => currentTitlePage = index),
                          itemBuilder: (context, index) {
                            final slide = titleSlides[index];
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  slide['title'] ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: foreground,
                                    fontWeight: FontWeight.w800,
                                    height: 1.12,
                                    fontSize: veryCompact
                                        ? 19
                                        : (compact ? 22 : 25),
                                    letterSpacing: -.5,
                                  ),
                                ),
                                SizedBox(height: compact ? 7 : 11),
                                Text(
                                  slide['subtitle'] ?? '',
                                  maxLines: veryCompact ? 2 : 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: secondary,
                                    height: 1.4,
                                    fontSize: compact ? 11.5 : 13,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: compact ? 7 : 12),
                      _pageIndicators(theme),
                      const Spacer(flex: 2),
                      _actionButton(
                        context: context,
                        label: languagesController.tr('CONTINUE'),
                        filled: true,
                        onPressed: showContinueOptions,
                      ),
                      SizedBox(height: veryCompact ? 8 : 18),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Image.asset(
            'assets/icons/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.cell_tower_rounded,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ONLINE TELECOM',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
              Text(
                'Digital services, simplified',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final isDark = themeController.isDarkMode.value;
          return Tooltip(
            message: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            child: Material(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: themeController.toggleTheme,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Icon(
                    isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_outlined,
                    color: theme.colorScheme.primary,
                    size: 23,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Completely new hero: no floating badges, no Positioned elements,
  // and no operator images. Everything is laid out within its own space.
  Widget _heroArtwork(ThemeData theme) {
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final compact = h < 205;
        final circleSize = (h * (compact ? .57 : .62)).clamp(76.0, 165.0);
        final iconSize = circleSize * .42;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: circleSize,
              width: circleSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withOpacity(dark ? .14 : .09),
                border: Border.all(
                  color: colors.primary.withOpacity(.18),
                  width: 1.5,
                ),
              ),
              child: Container(
                width: circleSize * .74,
                height: circleSize * .74,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withOpacity(.22),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.cell_tower_rounded,
                  color: colors.onPrimary,
                  size: iconSize,
                ),
              ),
            ),
            SizedBox(height: compact ? 9 : 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _heroService(Icons.phone_android_rounded, theme),
                SizedBox(width: compact ? 10 : 16),
                _heroService(Icons.account_balance_wallet_outlined, theme),
                SizedBox(width: compact ? 10 : 16),
                _heroService(Icons.swap_horiz_rounded, theme),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _heroService(IconData icon, ThemeData theme) {
    return Container(
      width: 43,
      height: 43,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Icon(icon, size: 21, color: theme.colorScheme.primary),
    );
  }

  Widget _pageIndicators(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(titleSlides.length, (index) {
        final active = currentTitlePage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 25 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withOpacity(.16),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}
