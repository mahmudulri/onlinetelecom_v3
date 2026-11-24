import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:onlinetelecom/screens/sign_up_screen.dart';
import 'package:onlinetelecom/utils/colors.dart';
import '../controllers/sign_in_controller.dart';
import '../global_controller/languages_controller.dart';
import '../global_controller/theme_controller.dart';
import '../widgets/language_number_dialog.dart';
import '../widgets/app_social_links_sheet.dart';
import '../widgets/support_contacts_sheet.dart';
import 'welcomescreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final LanguagesController languagesController =
      Get.find<LanguagesController>();
  final SignInController signInController = Get.find<SignInController>();
  final ThemeController themeController = Get.find<ThemeController>();
  bool isPasswordVisible = false;
  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _foreground => Theme.of(context).colorScheme.onSurface;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _card => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _green => Theme.of(context).colorScheme.primary;
  Future<bool> showExitPopup() async {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.offAll(() => const Welcomescreen());
    }
    return false;
  }

  Future<void> loginNow() async {
    if (signInController.usernameController.text.trim().isEmpty ||
        signInController.passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Oops!',
        'Fill the text fields',
        backgroundColor: _card,
        colorText: _foreground,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    await signInController.signIn();
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool password = false,
  }) {
    return SizedBox(
      height: 49,
      child: TextField(
        controller: controller,
        obscureText: password && !isPasswordVisible,
        cursorColor: _green,
        textInputAction: password ? TextInputAction.done : TextInputAction.next,
        onSubmitted: password ? (_) => loginNow() : null,
        style: TextStyle(
          color: _foreground,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _muted, fontSize: 13),
          prefixIcon: Icon(icon, size: 19, color: _green),
          suffixIcon: password
              ? IconButton(
                  onPressed: () =>
                      setState(() => isPasswordVisible = !isPasswordVisible),
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _muted,
                    size: 19,
                  ),
                )
              : null,
          filled: true,
          fillColor: _dark
              ? AppColors.darkInputBackground
              : AppColors.lightSurface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _green, width: 1.5),
          ),
        ),
      ),
    );
  }

  // Matches the AfghanNet support + social footer and respects the app theme.
  String _supportTitle() {
    final translated = languagesController.tr('CONTACT_SUPPORT');
    if (translated != 'CONTACT_SUPPORT' && translated.trim().isNotEmpty) {
      return translated;
    }
    final fallback = languagesController.tr('CONTACTUS');
    return fallback == 'CONTACTUS' ? 'Contact Support' : fallback;
  }

  void _openSupport() {
    SupportContactsSheet.show(
      context,
      languageCode: languagesController.selectedlan.value,
    );
  }

  Widget _buildSupportArea(bool compact) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: _openSupport,
              style: OutlinedButton.styleFrom(
                foregroundColor: _green,
                backgroundColor: _card,
                side: BorderSide(color: _border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded, size: 21),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      _supportTitle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _green,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 13),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: languagesController.tr('FIND_US_ON'),
          child: Material(
            color: _card,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: () => AppSocialLinksSheet.show(context),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _border),
                ),
                child: Image.asset(
                  'assets/icons/social-media.png',
                  width: 23,
                  height: 23,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.public_rounded, color: _green),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _themeButton() => Obx(
    () => IconButton(
      tooltip: themeController.isDarkMode.value ? 'Light mode' : 'Dark mode',
      onPressed: themeController.toggleTheme,
      icon: Icon(
        themeController.isDarkMode.value
            ? Icons.light_mode_rounded
            : Icons.dark_mode_rounded,
        size: 22,
        color: _foreground,
      ),
    ),
  );
  Widget _pageContent(double width, {required bool compact}) {
    final scheme = Theme.of(context).colorScheme;
    final logoSize = compact ? 92.0 : 112.0;
    final inputSpacing = compact ? 11.0 : 15.0;
    final sectionSpacing = compact ? 16.0 : 22.0;
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: logoSize,
              height: logoSize,
              padding: EdgeInsets.all(compact ? 12 : 15),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(compact ? 28 : 32),
                border: Border.all(color: _green.withOpacity(.18)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(
                      _dark ? .12 : .10,
                    ),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Image.asset('assets/icons/logo.png', fit: BoxFit.contain),
            ),
          ),
          SizedBox(height: compact ? 12 : 19),
          Text(
            languagesController.tr('LOGIN'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _foreground,
              fontSize: compact ? 25 : 29,
              fontWeight: FontWeight.w800,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            languagesController.tr('PLEASE_ENTER_YOUR_INFORMATION'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: compact ? 12 : 13,
              height: 1.35,
            ),
          ),
          SizedBox(height: sectionSpacing),
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_dark ? .08 : .025),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.all(compact ? 15 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _textField(
                  controller: signInController.usernameController,
                  hint: languagesController.tr('USERNAME'),
                  icon: Icons.person_outline_rounded,
                ),
                SizedBox(height: inputSpacing),
                _textField(
                  controller: signInController.passwordController,
                  hint: languagesController.tr('PASSWORD'),
                  icon: Icons.lock_outline_rounded,
                  password: true,
                ),
                const SizedBox(height: 11),

                Obx(() {
                  final loading = signInController.isLoading.value;
                  return SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : loginNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        disabledBackgroundColor: _green.withOpacity(.4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (loading) ...[
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: scheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 9),
                          ],
                          Flexible(
                            child: Text(
                              languagesController.tr(
                                loading ? 'PLEASE_WAIT' : 'LOGIN',
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: compact ? 15 : 22),
          Row(
            children: [
              Expanded(child: Divider(color: _border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  languagesController.tr('OR'),
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: _border)),
            ],
          ),
          SizedBox(height: compact ? 12 : 17),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 5,
            children: [
              Text(
                languagesController.tr('HAVE_NOT_REGISTERED_YET'),
                style: TextStyle(color: _muted, fontSize: 12.5),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const SignUpScreen()),
                child: Text(
                  languagesController.tr('REGISTER'),
                  style: TextStyle(
                    color: _green,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 17 : 30),
          // AfghanNet-style footer, replacing old WhatsApp/social/call icons.
          _buildSupportArea(MediaQuery.sizeOf(context).width < 370),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final background = _dark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    return WillPopScope(
      onWillPop: showExitPopup,
      child: Scaffold(
        backgroundColor: background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Keep the same widget hierarchy whether the keyboard is
                    // visible or not. Swapping FittedBox for a scroll view
                    // would dispose the focused TextField and hide the keyboard.
                    final screenHeight = MediaQuery.sizeOf(context).height;
                    final compact = screenHeight < 760;
                    final contentWidth = (constraints.maxWidth - 40)
                        .clamp(0.0, 420.0)
                        .toDouble();
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(20, 58, 20, 18),
                      child: SizedBox(
                        // With the keyboard hidden, fit everything vertically.
                        // When open, use natural height so fields remain usable
                        // and the form can scroll above the keyboard.
                        height: keyboardVisible
                            ? null
                            : (constraints.maxHeight - 76)
                                  .clamp(0.0, double.infinity)
                                  .toDouble(),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: _pageContent(contentWidth, compact: compact),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Global Icon
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return LanguageNumberDialog(
                              languagesController: languagesController,
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: _border),
                        ),
                        child: Image.asset(
                          'assets/icons/global.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Theme Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: _border),
                      ),
                      child: _themeButton(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
