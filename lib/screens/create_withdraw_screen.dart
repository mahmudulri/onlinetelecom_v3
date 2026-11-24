import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:onlinetelecom/controllers/create_withdraw_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Create Withdraw — Online Telecom green Light/Dark UI.
/// The original form controllers and createBankWithdraw() submission are kept.
/// The submit button stays directly below Bank Details in the scrollable form.
class CreateWithdrawScreen extends StatelessWidget {
  CreateWithdrawScreen({super.key});

  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final CreateWithdrawController createWithdrawController = Get.put(
    CreateWithdrawController(),
  );
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final ThemeController themeController = Get.find<ThemeController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _dark => themeController.isDarkMode.value;
  Color get _background =>
      _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _input =>
      _dark ? AppColors.darkInputBackground : const Color(0xFFF7FAF8);
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _accent => AppColors.primaryColor;
  Color get _softGreen =>
      _dark ? const Color(0xFF1D3829) : const Color(0xFFE9F7ED);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final systemBars = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      );

      final media = MediaQuery.of(context);
      // The parent BaseScreen uses extendBody and a raised center action.
      // Reserve clearance INSIDE the scrollable area, not underneath a fixed
      // footer. This ensures Create Now can be scrolled above that navigation.
      final double bottomClearance = media.viewInsets.bottom > 0
          ? 24.0
          : 76.0 + 38.0 + media.viewPadding.bottom;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemBars,
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
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(16, 2, 16, bottomClearance),
                    children: [
                      _buildWithdrawDetailsSection(),
                      const SizedBox(height: 13),
                      _buildBankDetailsSection(),
                      const SizedBox(height: 18),
                      _buildSubmitButton(),
                      const SizedBox(height: 35),
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
            height: 42,
            width: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Icon(icon, size: 21, color: _text),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            _headerButton(
              tooltip: 'Back',
              icon: Icons.arrow_back_rounded,
              onTap: mypagecontroller.goBack,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                languagesController.tr('CREATE_NEW_WITHDRAW'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.35,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => _headerButton(
                tooltip: themeController.isDarkMode.value
                    ? 'Light mode'
                    : 'Dark mode',
                icon: themeController.isDarkMode.value
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                onTap: themeController.toggleTheme,
              ),
            ),
            const SizedBox(width: 9),
            _headerButton(
              tooltip: 'Menu',
              icon: Icons.menu_rounded,
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    String? title,
    IconData? icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .06 : .025),
            blurRadius: 13,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title.isNotEmpty && icon != null) ...[
            Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _softGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: _accent, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _fieldLabel(String text, {bool optional = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: _muted,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 5),
          Text(
            '(${languagesController.tr('OPTIONAL')})',
            style: TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _field({
    required String keyName,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool optional = false,
    bool multiline = false,
  }) {
    final label = languagesController.tr(keyName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, optional: optional),
        const SizedBox(height: 7),
        Container(
          constraints: BoxConstraints(minHeight: multiline ? 96 : 53),
          decoration: BoxDecoration(
            color: _input,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Row(
            crossAxisAlignment: multiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(12, multiline ? 16 : 0, 0, 0),
                child: Icon(icon, color: _accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: multiline
                      ? TextInputType.multiline
                      : keyboardType,
                  textInputAction: multiline
                      ? TextInputAction.newline
                      : TextInputAction.next,
                  minLines: multiline ? 3 : 1,
                  maxLines: multiline ? 4 : 1,
                  cursorColor: _accent,
                  style: TextStyle(
                    color: _text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: label,
                    hintStyle: TextStyle(
                      color: _muted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                    isDense: true,
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: multiline ? 15 : 17,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawDetailsSection() {
    // The page header already displays Create New Withdraw, so avoid
    // repeating that heading inside the first form card.
    return _sectionCard(
      children: [
        _field(
          keyName: 'AMOUNT',
          controller: createWithdrawController.amountController,
          icon: Icons.payments_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 15),
        _field(
          keyName: 'ACCOUNT_NAME',
          controller: createWithdrawController.accountNameController,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 15),
        _field(
          keyName: 'ACCOUNT_NUMBER',
          controller: createWithdrawController.accountNumberController,
          icon: Icons.credit_card_outlined,
        ),
        const SizedBox(height: 15),
        _field(
          keyName: 'BANK_NAME',
          controller: createWithdrawController.bankNameController,
          icon: Icons.account_balance_outlined,
        ),
        const SizedBox(height: 15),
        _field(
          keyName: 'NOTES',
          controller: createWithdrawController.notesController,
          icon: Icons.notes_rounded,
          optional: true,
          multiline: true,
        ),
      ],
    );
  }

  Widget _buildBankDetailsSection() {
    return _sectionCard(
      title: languagesController.tr('BANK_DETAILS'),
      icon: Icons.account_balance_rounded,
      children: [
        _field(
          keyName: 'BANK_NAME',
          controller: createWithdrawController.bankDetailNameController,
          icon: Icons.account_balance_outlined,
        ),
        const SizedBox(height: 15),
        _field(
          keyName: 'ACCOUNT_HOLDER_NAME',
          controller: createWithdrawController.bankHolderNameController,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 15),
        _field(
          keyName: 'ACCOUNT_NUMBER',
          controller: createWithdrawController.bankAccountNumberController,
          icon: Icons.credit_card_outlined,
        ),
        const SizedBox(height: 15),
        _field(
          keyName: 'IBAN',
          controller: createWithdrawController.ibanController,
          icon: Icons.numbers_rounded,
        ),
        const SizedBox(height: 15),
        _field(
          keyName: 'BRANCH',
          controller: createWithdrawController.branchController,
          icon: Icons.location_city_outlined,
        ),
        const SizedBox(height: 15),
        _field(
          keyName: 'SWIFT_CODE',
          controller: createWithdrawController.swiftCodeController,
          icon: Icons.pin_outlined,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final isLoading = createWithdrawController.isLoading.value;
      return SizedBox(
        height: 53,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () => createWithdrawController.createBankWithdraw(),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _accent.withOpacity(.45),
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: isLoading
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
                    Text(
                      languagesController.tr('PLEASE_WAIT'),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 20),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        languagesController.tr('CREATE_NOW'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
