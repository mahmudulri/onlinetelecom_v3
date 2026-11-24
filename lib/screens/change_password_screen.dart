import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:onlinetelecom/controllers/change_password_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Redesigned Change Password screen.
///
/// Uses the same shared ThemeController and 42px header actions as Network.
/// Retains the original password controllers, validation and change() API.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final ChangePasswordController changePasswordController = Get.put(
    ChangePasswordController(),
  );
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final ThemeController themeController = Get.find<ThemeController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _dark => themeController.isDarkMode.value;
  Color get _background =>
      _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _card => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _foreground =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _primary => AppColors.primaryColor;
  Color get _softGreen =>
      _dark ? const Color(0xFF1D3829) : const Color(0xFFE9F7ED);

  @override
  Widget build(BuildContext context) {
    // Rebuild the entire page when the application's shared theme changes.
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final systemStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemStyle,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: const DrawerWidget(),
          backgroundColor: _background,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 26),
                    children: [
                      _buildSecurityBanner(),
                      const SizedBox(height: 19),
                      _buildSectionHeading(),
                      const SizedBox(height: 11),
                      _buildPasswordForm(),
                    ],
                  ),
                ),
                _buildBottomAction(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _headerIcon({
    required Widget icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: icon,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Back / Title / Theme / Menu: identical visual order to the recent forms.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            _headerIcon(
              tooltip: 'Back',
              onTap: mypagecontroller.goBack,
              icon: Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: _foreground,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                languagesController.tr('CHANGE_PASSWORD'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _foreground,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => _headerIcon(
                tooltip: themeController.isDarkMode.value
                    ? 'Light mode'
                    : 'Dark mode',
                onTap: themeController.toggleTheme,
                icon: Icon(
                  themeController.isDarkMode.value
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  size: 21,
                  color: _foreground,
                ),
              ),
            ),
            const SizedBox(width: 9),
            _headerIcon(
              tooltip: 'Menu',
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              icon: Icon(Icons.menu_rounded, size: 22, color: _foreground),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityBanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF145E37), Color(0xFF118646), Color(0xFF19A356)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF128049).withOpacity(_dark ? .12 : .17),
            blurRadius: 19,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            Positioned(
              top: -48,
              right: -37,
              child: Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(.13),
                    width: 22,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 57,
              bottom: -49,
              child: Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.055),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 51,
                    height: 51,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(.17)),
                    ),
                    child: const Icon(
                      Icons.enhanced_encryption_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languagesController.tr('CHANGE_PASSWORD'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              size: 14,
                              color: Colors.white.withOpacity(.8),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                languagesController.tr('CURRENT_PASSWORD'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.82),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.shield_outlined,
                    color: Color(0x77FFFFFF),
                    size: 36,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeading() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 19,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            languagesController.tr('CHANGE_PASSWORD'),
            style: TextStyle(
              color: _foreground,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          width: 31,
          height: 31,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _softGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.lock_outline_rounded, color: _primary, size: 17),
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .08 : .025),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _numberedLabel('01', languagesController.tr('CURRENT_PASSWORD')),
          const SizedBox(height: 9),
          PasswordFieldBox(
            hintText: languagesController.tr('CURRENT_PASSWORD'),
            controller: changePasswordController.currentpassController,
            icon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 18),
          Divider(color: _border, height: 1),
          const SizedBox(height: 17),
          _numberedLabel('02', languagesController.tr('NEW_PASSWORD')),
          const SizedBox(height: 9),
          PasswordFieldBox(
            hintText: languagesController.tr('NEW_PASSWORD'),
            controller: changePasswordController.newpassController,
            icon: Icons.key_rounded,
            isNewPassword: true,
          ),
          const SizedBox(height: 16),
          _numberedLabel('03', languagesController.tr('CONFIRM_NEW_PASSWORD')),
          const SizedBox(height: 9),
          PasswordFieldBox(
            hintText: languagesController.tr('CONFIRM_NEW_PASSWORD'),
            controller: changePasswordController.confirmpassController,
            icon: Icons.verified_user_outlined,
            isNewPassword: true,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _numberedLabel(String number, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: _softGreen,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: _primary,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _foreground,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: _background,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Obx(() {
        final loading = changePasswordController.isLoading.value;
        return SizedBox(
          width: double.infinity,
          height: 51,
          child: ElevatedButton(
            onPressed: loading ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              disabledBackgroundColor: _primary.withOpacity(.55),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: loading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        languagesController.tr('PLEASE_WAIT'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_reset_rounded, size: 21),
                      const SizedBox(width: 9),
                      Flexible(
                        child: Text(
                          languagesController.tr('CHANGE_NOW'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
          ),
        );
      }),
    );
  }

  void _changePassword() {
    // Preserve the original submission rules and existing API call.
    if (changePasswordController.currentpassController.text.isEmpty ||
        changePasswordController.newpassController.text.isEmpty ||
        changePasswordController.confirmpassController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: languagesController.tr('FILL_DATA_CORRECTLY'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    changePasswordController.change();
  }
}

/// Public reusable field class from the original screen. Its constructor and
/// visibility toggle are preserved. Additional properties are optional.
class PasswordFieldBox extends StatefulWidget {
  const PasswordFieldBox({
    super.key,
    required this.hintText,
    required this.controller,
    required this.icon,
    this.isNewPassword = false,
    this.textInputAction = TextInputAction.next,
  });

  final String hintText;
  final TextEditingController controller;
  final IconData icon;
  final bool isNewPassword;
  final TextInputAction textInputAction;

  @override
  State<PasswordFieldBox> createState() => _PasswordFieldBoxState();
}

class _PasswordFieldBoxState extends State<PasswordFieldBox> {
  final ThemeController themeController = Get.find<ThemeController>();
  bool _obscureText = true;
  bool _focused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = themeController.isDarkMode.value;
      final background = dark
          ? AppColors.darkInputBackground
          : const Color(0xFFF7FAF8);
      final text = dark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary;
      final muted = dark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary;
      final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
      final primary = AppColors.primaryColor;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 51,
        width: double.infinity,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: _focused ? primary.withOpacity(.65) : border,
            width: _focused ? 1.35 : 1,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 11),
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primary.withOpacity(dark ? .16 : .09),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(widget.icon, color: primary, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: _obscureText,
                obscuringCharacter: '•',
                enableSuggestions: false,
                autocorrect: false,
                textInputAction: widget.textInputAction,
                autofillHints: [
                  widget.isNewPassword
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                cursorColor: primary,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  color: text,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintMaxLines: 1,
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintStyle: TextStyle(
                    color: muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _obscureText = !_obscureText),
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 43, minHeight: 43),
              tooltip: _obscureText ? 'Show password' : 'Hide password',
              icon: Icon(
                _obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _obscureText ? muted : primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 2),
          ],
        ),
      );
    });
  }
}
