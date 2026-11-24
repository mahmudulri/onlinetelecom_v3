import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:onlinetelecom/controllers/change_balance_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// A fully themed, compact balance-adjustment page.
/// The existing BalanceController methods and stored currency are unchanged.
class ChangeBalance extends StatefulWidget {
  const ChangeBalance({super.key, this.subID});

  final String? subID;

  @override
  State<ChangeBalance> createState() => _ChangeBalanceState();
}

class _ChangeBalanceState extends State<ChangeBalance> {
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final BalanceController balanceController = Get.put(BalanceController());
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final ThemeController themeController = Get.find<ThemeController>();
  final GetStorage box = GetStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedType = 1; // 1 = credit; 2 = debit, matching the original form.

  bool get _dark => themeController.isDarkMode.value;
  Color get _background =>
      _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _input =>
      _dark ? AppColors.darkInputBackground : const Color(0xFFF6FAF7);
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _primary => AppColors.primaryColor;
  Color get _actionColor =>
      _selectedType == 1 ? _primary : const Color(0xFFDD5964);
  Color get _actionSoft => _selectedType == 1
      ? (_dark ? const Color(0xFF1B3828) : const Color(0xFFEAF8F0))
      : (_dark ? const Color(0xFF3B2228) : const Color(0xFFFFF0F1));

  @override
  void initState() {
    super.initState();
    balanceController.status.value = 'credit';
    balanceController.amountController.addListener(_updateAmountPreview);
  }

  void _updateAmountPreview() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    balanceController.amountController.removeListener(_updateAmountPreview);
    super.dispose();
  }

  void _selectType(int type) {
    if (_selectedType == type) return;
    setState(() {
      _selectedType = type;
      balanceController.status.value = type == 1 ? 'credit' : 'debit';
    });
  }

  String get _currency => box.read('currency_code')?.toString() ?? '';

  @override
  Widget build(BuildContext context) {
    // Observe the shared GetX theme at the page root, exactly as on Network.
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final overlay = SystemUiOverlayStyle(
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
        value: overlay,
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
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 22),
                    children: [
                      _buildOverviewCard(),
                      const SizedBox(height: 20),
                      _sectionTitle(languagesController.tr('CHANGE_BALANCE')),
                      const SizedBox(height: 11),
                      _buildTypeSelector(),
                      const SizedBox(height: 19),
                      _sectionTitle(languagesController.tr('AMOUNT')),
                      const SizedBox(height: 11),
                      _buildAmountInput(),
                      const SizedBox(height: 18),
                      _buildReviewStrip(),
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

  // Exact header control pattern used by the Network screen.
  Widget _headerIcon({
    required Widget icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: _dark ? AppColors.darkCard : AppColors.lightSurface,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            _headerIcon(
              tooltip: 'Back',
              onTap: mypagecontroller.goBack,
              icon: Icon(Icons.arrow_back_rounded, size: 22, color: _text),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                languagesController.tr('CHANGE_BALANCE'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: 21,
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
                  color: _text,
                ),
              ),
            ),
            const SizedBox(width: 9),
            _headerIcon(
              tooltip: 'Menu',
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              icon: Icon(Icons.menu_rounded, size: 22, color: _text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF185D39), Color(0xFF117C43), Color(0xFF18A356)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF128348).withOpacity(_dark ? .15 : .19),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              right: -35,
              top: -42,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(.10),
                    width: 25,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: -55,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.045),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 17, 16, 16),
              child: Row(
                children: [
                  Container(
                    height: 51,
                    width: 51,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      border: Border.all(color: Colors.white.withOpacity(.17)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
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
                          languagesController.tr('CHANGE_BALANCE'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _selectedType == 1
                                  ? Icons.add_circle_outline_rounded
                                  : Icons.remove_circle_outline_rounded,
                              color: Colors.white.withOpacity(.87),
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                _selectedType == 1
                                    ? languagesController.tr('CREDIT')
                                    : languagesController.tr('DEBIT'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.87),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 17,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(5),
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
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _typeCard(
            type: 1,
            label: languagesController.tr('CREDIT'),
            icon: Icons.south_west_rounded,
            accent: _primary,
            selectedBackground: _dark
                ? const Color(0xFF1C3627)
                : const Color(0xFFEAF8EF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _typeCard(
            type: 2,
            label: languagesController.tr('DEBIT'),
            icon: Icons.north_east_rounded,
            accent: const Color(0xFFDD5964),
            selectedBackground: _dark
                ? const Color(0xFF382126)
                : const Color(0xFFFFF0F1),
          ),
        ),
      ],
    );
  }

  Widget _typeCard({
    required int type,
    required String label,
    required IconData icon,
    required Color accent,
    required Color selectedBackground,
  }) {
    final selected = _selectedType == type;
    return Material(
      color: selected ? selectedBackground : _surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: () => _selectType(type),
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 190),
          height: 87,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              width: selected ? 1.4 : 1,
              color: selected ? accent.withOpacity(.60) : _border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 29,
                    height: 29,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(selected ? .15 : .085),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 17, color: accent),
                  ),
                  const Spacer(),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 19,
                    color: selected ? accent : _muted.withOpacity(.55),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? accent : _text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    // Use a single surface for the entire field. In particular, explicitly
    // disable the app-wide TextField fill so it cannot create a second color
    // inside the amount container in light or dark mode.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(Icons.payments_outlined, color: _actionColor, size: 23),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: balanceController.amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              cursorColor: _primary,
              style: TextStyle(
                color: _text,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -.4,
              ),
              decoration: InputDecoration(
                hintText: languagesController.tr('ENTER_AMOUNT'),
                hintStyle: TextStyle(
                  color: _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
                filled: false,
                fillColor: Colors.transparent,
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 25, color: _border),
          const SizedBox(width: 10),
          Text(
            _currency,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _text,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStrip() {
    final amount = balanceController.amountController.text.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: _actionSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _actionColor.withOpacity(.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: _actionColor.withOpacity(.11),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _selectedType == 1 ? Icons.add_rounded : Icons.remove_rounded,
              color: _actionColor,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _selectedType == 1
                  ? languagesController.tr('CREDIT')
                  : languagesController.tr('DEBIT'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              amount.isEmpty
                  ? '—'
                  : '$amount${_currency.isEmpty ? '' : ' $_currency'}',
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _actionColor,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 13),
      decoration: BoxDecoration(
        color: _background,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Obx(() {
        final loading = balanceController.isLoading.value;
        return SizedBox(
          width: double.infinity,
          height: 51,
          child: Material(
            color: loading ? _muted.withOpacity(.45) : _actionColor,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: loading ? null : _submitBalanceChange,
              borderRadius: BorderRadius.circular(15),
              child: Center(
                child: loading
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            languagesController.tr('PLEASE_WAIT'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 19,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 9),
                          Text(
                            languagesController.tr('CONFIRMATION'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // Preserve the original validation and credit/debit request routing.
  void _submitBalanceChange() {
    if (balanceController.amountController.text.trim().isEmpty ||
        balanceController.status.value.isEmpty) {
      Fluttertoast.showToast(
        msg: languagesController.tr('ENTER_AMOUNT'),
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

    if (balanceController.status.value == 'credit') {
      balanceController.credit(widget.subID.toString());
    } else {
      balanceController.debit(widget.subID.toString());
    }
  }
}

/// Existing public helper preserved for any other screens that use PasswordBox.
class PasswordBox extends StatelessWidget {
  const PasswordBox({super.key, this.hintText});

  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final background = dark
        ? AppColors.darkInputBackground
        : AppColors.lightSurface;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final hint = dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: TextField(
        obscureText: true,
        style: TextStyle(color: text),
        cursorColor: AppColors.primaryColor,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: hint),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          suffixIcon: Icon(
            Icons.visibility_off_outlined,
            color: hint,
            size: 20,
          ),
        ),
      ),
    );
  }
}
