import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:onlinetelecom/controllers/change_pin_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Change PIN: redesigned to match the shared Online Telecom light/dark UI.
/// Keeps the original ChangePinController, validation and change() API call.
class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final ChangePinController changePinController = Get.put(
    ChangePinController(),
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
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _primary => AppColors.primaryColor;
  Color get _softGreen =>
      _dark ? const Color(0xFF1D3829) : const Color(0xFFEAF8EE);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final overlay = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: const DrawerWidget(),
          resizeToAvoidBottomInset: true,
          backgroundColor: _background,
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
                    padding: const EdgeInsets.fromLTRB(16, 3, 16, 26),
                    children: [
                      _buildSecurityBanner(),
                      const SizedBox(height: 20),
                      _buildSectionTitle(),
                      const SizedBox(height: 11),
                      _buildPinForm(),
                    ],
                  ),
                ),
                _buildBottomButton(),
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
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: _surface,
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
    // Same header structure as the latest Network and Change Password pages.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            _headerIcon(
              tooltip: 'Back',
              onTap: mypagecontroller.goBack,
              icon: Icon(Icons.arrow_back_rounded, color: _text, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                languagesController.tr('CHANGE_PIN'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: 20,
                  letterSpacing: -.4,
                  fontWeight: FontWeight.w800,
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
                  color: _text,
                ),
              ),
            ),
            const SizedBox(width: 9),
            _headerIcon(
              tooltip: 'Menu',
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              icon: Icon(Icons.menu_rounded, color: _text, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF145F37), Color(0xFF0D8543), Color(0xFF1DA857)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF138047).withOpacity(_dark ? .11 : .17),
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
              top: -49,
              right: -43,
              child: Container(
                width: 151,
                height: 151,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(.11),
                    width: 23,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 51,
              bottom: -42,
              child: Container(
                height: 88,
                width: 88,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(.16)),
                    ),
                    child: const Icon(
                      Icons.pin_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languagesController.tr('CHANGE_PIN'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.white.withOpacity(.80),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                languagesController.tr('OLD_PIN'),
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
                  Icon(
                    Icons.shield_outlined,
                    size: 34,
                    color: Colors.white.withOpacity(.65),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Container(
          height: 19,
          width: 4,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            languagesController.tr('CHANGE_PIN'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        Container(
          height: 31,
          width: 31,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _softGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.key_rounded, color: _primary, size: 17),
        ),
      ],
    );
  }

  Widget _buildPinForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 17),
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .08 : .024),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _numberedLabel('01', languagesController.tr('OLD_PIN')),
          const SizedBox(height: 9),
          ChangePinBox(
            hintText: languagesController.tr('ENTER_YOUR_OLD_PIN'),
            controller: changePinController.oldPinController,
            icon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 18),
          Divider(height: 1, color: _border),
          const SizedBox(height: 17),
          _numberedLabel('02', languagesController.tr('NEW_PIN')),
          const SizedBox(height: 9),
          ChangePinBox(
            hintText: languagesController.tr('ENTER_YOUR_NEW_PIN'),
            controller: changePinController.newPinController,
            icon: Icons.key_rounded,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _changePin(),
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
              fontSize: 10,
              fontWeight: FontWeight.w800,
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
              color: _text,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: _background,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Obx(() {
        final loading = changePinController.isLoading.value;
        return SizedBox(
          width: double.infinity,
          height: 51,
          child: ElevatedButton(
            onPressed: loading ? null : _changePin,
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
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          languagesController.tr('PLEASE_WAIT'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, size: 20),
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

  void _changePin() {
    // Preserve the original validation and controller-based submit behavior.
    if (changePinController.isLoading.value) return;

    if (changePinController.oldPinController.text.isEmpty ||
        changePinController.newPinController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: languagesController.tr('FILL_DATA_CORRECTLY'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16,
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    changePinController.change();
  }
}

/// Replaces the previous public ChangePinBox while retaining its original
/// constructor arguments. Adds PIN visibility and focused border styling.
class ChangePinBox extends StatefulWidget {
  const ChangePinBox({
    super.key,
    required this.hintText,
    required this.controller,
    required this.icon,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final String hintText;
  final TextEditingController controller;
  final IconData icon;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<ChangePinBox> createState() => _ChangePinBoxState();
}

class _ChangePinBoxState extends State<ChangePinBox> {
  final ThemeController themeController = Get.find<ThemeController>();
  late final FocusNode _focusNode;
  bool _focused = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_focusChanged);
  }

  void _focusChanged() {
    if (mounted) setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusChanged);
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
      final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
      final text = dark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary;
      final muted = dark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary;
      const primary = AppColors.primaryColor;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            width: _focused ? 1.35 : 1,
            color: _focused ? primary.withOpacity(.68) : border,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 11),
            Container(
              height: 30,
              width: 30,
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
                obscureText: _obscure,
                obscuringCharacter: '•',
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.number,
                textInputAction: widget.textInputAction,
                onSubmitted: widget.onSubmitted,
                cursorColor: primary,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  color: text,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: _obscure ? 2 : .4,
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
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 43, minHeight: 43),
              tooltip: _obscure ? 'Show PIN' : 'Hide PIN',
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _obscure ? muted : primary,
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
