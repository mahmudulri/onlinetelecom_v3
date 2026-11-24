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

/// Modern Set PIN screen matching the app green light/dark theme.
/// Preserves the existing controller, validation, subID and setpin() API flow.
class SetSubresellerPin extends StatefulWidget {
  const SetSubresellerPin({super.key, this.subID});

  final String? subID;

  @override
  State<SetSubresellerPin> createState() => _SetSubresellerPinState();
}

class _SetSubresellerPinState extends State<SetSubresellerPin> {
  final ChangePinController setpinController = Get.put(ChangePinController());
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
  Color get _accent => AppColors.primaryColor;
  Color get _softGreen =>
      _dark ? const Color(0xFF193C2B) : const Color(0xFFEAF7EF);

  @override
  void initState() {
    super.initState();
    // Clear previous PIN values on each entry, as in the original screen.
    setpinController.newPinController.clear();
    setpinController.confirmPinController.clear();
  }

  bool get _hasPinMismatch {
    final first = setpinController.newPinController.text;
    final second = setpinController.confirmPinController.text;
    return second.isNotEmpty && first != second;
  }

  bool get _hasPinMatch {
    final first = setpinController.newPinController.text;
    final second = setpinController.confirmPinController.text;
    return first.isNotEmpty && second.isNotEmpty && first == second;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = themeController.isDarkMode.value;
      final media = MediaQuery.of(context);
      final bottomClearance = media.viewInsets.bottom > 0
          ? 24.0
          : 76.0 + 38.0 + media.viewPadding.bottom;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: _background,
          systemNavigationBarIconBrightness: dark
              ? Brightness.light
              : Brightness.dark,
        ),
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
                    padding: EdgeInsets.fromLTRB(16, 6, 16, bottomClearance),
                    children: [
                      _fieldHeading(
                        index: '01',
                        icon: Icons.pin_outlined,
                        title: languagesController.tr('NEW_PIN'),
                      ),
                      const SizedBox(height: 9),
                      PinBox(
                        controller: setpinController.newPinController,
                        hintText: languagesController.tr('ENTER_NEW_PIN'),
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 22),
                      _fieldHeading(
                        index: '02',
                        icon: Icons.verified_outlined,
                        title: languagesController.tr('CONFIRM_PIN'),
                        showCheck: _hasPinMatch,
                      ),
                      const SizedBox(height: 9),
                      PinBox(
                        controller: setpinController.confirmPinController,
                        hintText: languagesController.tr('ENTER_CONFIRM_PIN'),
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _submitPin(),
                      ),
                      if (_hasPinMismatch) ...[
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 16,
                              color: Color(0xFFD65B5B),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                languagesController.tr('DONT_MATCH_BOTH_PIN'),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFD65B5B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 25),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _headerButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            height: 42,
            width: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Icon(icon, color: _text, size: 21),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 14),
      child: Row(
        children: [
          _headerButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onTap: mypagecontroller.goBack,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              languagesController.tr('SET_PIN'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -.25,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _headerButton(
            icon: _dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tooltip: _dark ? 'Light mode' : 'Dark mode',
            onTap: themeController.toggleTheme,
          ),
          const SizedBox(width: 8),
          _headerButton(
            icon: Icons.menu_rounded,
            tooltip: 'Menu',
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _fieldHeading({
    required String index,
    required IconData icon,
    required String title,
    bool showCheck = false,
  }) {
    return Row(
      children: [
        Container(
          width: 27,
          height: 27,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _softGreen,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: _accent),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (showCheck)
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF20A663),
            size: 18,
          ),
        const SizedBox(width: 8),
        Text(
          index,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: _muted,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final loading = setpinController.isLoading.value;
      return SizedBox(
        height: 51,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: loading ? null : _submitPin,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            disabledBackgroundColor: _accent.withOpacity(.55),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.check_circle_outline_rounded, size: 19),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  loading
                      ? languagesController.tr('PLEASE_WAIT')
                      : languagesController.tr('CONFIRMATION'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _submitPin() {
    if (setpinController.isLoading.value) return;

    final newPin = setpinController.newPinController.text.trim();
    final confirmPin = setpinController.confirmPinController.text.trim();

    if (newPin.isEmpty || confirmPin.isEmpty) {
      _toast(languagesController.tr('FILL_DATA_CORRECTLY'));
      return;
    }

    if (newPin != confirmPin) {
      _toast(languagesController.tr('DONT_MATCH_BOTH_PIN'));
      return;
    }

    // Preserve the existing API method and sub-reseller ID.
    setpinController.setpin(widget.subID.toString());
  }

  void _toast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16,
    );
  }
}

/// Public widget name and constructor retained for existing usages elsewhere.
/// The TextField owns its single fill and border; no double-container effect.
class PinBox extends StatefulWidget {
  const PinBox({
    super.key,
    this.hintText,
    this.controller,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
  });

  final String? hintText;
  final TextEditingController? controller;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PinBox> createState() => _PinBoxState();
}

class _PinBoxState extends State<PinBox> {
  final ThemeController themeController = Get.find<ThemeController>();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = themeController.isDarkMode.value;
      final fill = dark
          ? AppColors.darkInputBackground
          : AppColors.lightSurface;
      final foreground = dark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary;
      final muted = dark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary;
      final normalBorder = dark ? AppColors.darkBorder : AppColors.lightBorder;
      final green = AppColors.primaryColor;

      OutlineInputBorder outline(Color color, double width) {
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );
      }

      return TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        enableSuggestions: false,
        autocorrect: false,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: widget.textInputAction,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        cursorColor: green,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintMaxLines: 1,
          hintStyle: TextStyle(color: muted, fontSize: 12.5),
          isDense: true,
          filled: true,
          fillColor: fill,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
          prefixIcon: Icon(Icons.pin_outlined, color: green, size: 19),
          prefixIconConstraints: const BoxConstraints(minWidth: 45),
          suffixIconConstraints: const BoxConstraints(minWidth: 48),
          suffixIcon: IconButton(
            tooltip: _obscureText ? 'Show PIN' : 'Hide PIN',
            splashRadius: 20,
            icon: Icon(
              _obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: muted,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
          border: outline(normalBorder, 1),
          enabledBorder: outline(normalBorder, 1),
          focusedBorder: outline(green, 1.5),
          disabledBorder: outline(normalBorder.withOpacity(.55), 1),
          errorBorder: outline(const Color(0xFFD65B5B), 1),
          focusedErrorBorder: outline(const Color(0xFFD65B5B), 1.5),
        ),
      );
    });
  }
}
