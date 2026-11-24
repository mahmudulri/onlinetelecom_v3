import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:onlinetelecom/controllers/add_hawala_controller.dart';
import 'package:onlinetelecom/controllers/branch_controller.dart';
import 'package:onlinetelecom/controllers/conversation_controller.dart';
import 'package:onlinetelecom/controllers/currency_controller.dart';
import 'package:onlinetelecom/controllers/hawala_currency_controller.dart';
import 'package:onlinetelecom/controllers/sign_in_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Create Hawala — themed Online Telecom UI.
/// All existing controllers, exchange-rate calculation and createhawala()
/// submission behavior have been retained.
class HawalaScreen extends StatefulWidget {
  const HawalaScreen({super.key});

  @override
  State<HawalaScreen> createState() => _HawalaScreenState();
}

class _HawalaScreenState extends State<HawalaScreen> {
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final AddHawalaController addHawalaController = Get.put(
    AddHawalaController(),
  );
  final SignInController signInController = Get.put(SignInController());
  final CurrencyController currencyController = Get.put(CurrencyController());
  final BranchController branchController = Get.put(BranchController());
  final HawalaCurrencyController hawalaCurrencyController = Get.put(
    HawalaCurrencyController(),
  );
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final ConversationController conversationController = Get.put(
    ConversationController(),
  );
  final ThemeController themeController = Get.find<ThemeController>();
  final GetStorage box = GetStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _dark => themeController.isDarkMode.value;
  Color get _background =>
      _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _card => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _fieldColor =>
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
  void initState() {
    super.initState();
    _resetForm();
    hawalaCurrencyController.fetchcurrency();
    currencyController.fetchCurrencyList();
    branchController.fetchallbranch();
  }

  // Preserve the original form reset, including controller/Rx field names.
  void _resetForm() {
    addHawalaController.amountController.clear();
    addHawalaController.currency.value = '';
    addHawalaController.finalAmount.value = '';
    conversationController.selectedCurrency.value = '';
    addHawalaController.senderNameController.clear();
    addHawalaController.receiverNameController.clear();
    addHawalaController.fatherNameController.clear();
    addHawalaController.idcardController.clear();
    addHawalaController.currencyID.value = '';
    addHawalaController.paidbyreceiver.value = '';
    addHawalaController.paidbysender.value = '';
    addHawalaController.branchId.value = '';
    addHawalaController.currency2.value = '';
    addHawalaController.branch.value = '';
    addHawalaController.selectedRate.value = null;
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild every background, border and input when the global theme changes.
    return Obx(() {
      final darkMode = themeController.isDarkMode.value;
      final bars = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: darkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: darkMode
            ? Brightness.light
            : Brightness.dark,
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: bars,
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
                    // Scroll clearance for BaseScreen's navigation and center action.
                    // The submit button itself stays directly below Branch.
                    padding: EdgeInsets.fromLTRB(
                      16,
                      2,
                      16,
                      MediaQuery.of(context).viewInsets.bottom > 0
                          ? 24
                          : 145 + MediaQuery.of(context).viewPadding.bottom,
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildParticipantSection(),
                      const SizedBox(height: 12),
                      _buildAmountSection(),
                      const SizedBox(height: 12),
                      _buildBranchSection(),
                      const SizedBox(height: 16),
                      _buildBottomAction(),
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
            child: Icon(icon, color: _text, size: 21),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Same Back / Title / Theme / Menu composition as Network and Orders.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            _headerButton(
              icon: Icons.arrow_back_rounded,
              onTap: mypagecontroller.goBack,
              tooltip: 'Back',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                languagesController.tr('CREATE_HAWALA'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: 20,
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
                onTap: themeController.toggleTheme,
                icon: themeController.isDarkMode.value
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
            ),
            const SizedBox(width: 9),
            _headerButton(
              icon: Icons.menu_rounded,
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              tooltip: 'Menu',
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 15),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(19),
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
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _softGreen,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: _accent),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _label(String key) {
    return Text(
      languagesController.tr(key),
      style: TextStyle(
        color: _muted,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _fieldColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 11),
          Icon(icon, color: _accent, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onChanged: onChanged,
              cursorColor: _accent,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                color: _text,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: _muted, fontSize: 12.5),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildParticipantSection() {
    return _section(
      title: languagesController.tr('SENDER_NAME'),
      icon: Icons.people_alt_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('SENDER_NAME'),
          const SizedBox(height: 7),
          _textField(
            controller: addHawalaController.senderNameController,
            hint: languagesController.tr('SENDER_NAME'),
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          _label('RECEIVER_NAME'),
          const SizedBox(height: 7),
          _textField(
            controller: addHawalaController.receiverNameController,
            hint: languagesController.tr('RECEIVER_NAME'),
            icon: Icons.person_pin_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    return _section(
      title: languagesController.tr('HAWALA_AMOUNT'),
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(flex: 3, child: _label('HAWALA_AMOUNT')),
              const SizedBox(width: 9),
              Expanded(flex: 2, child: _label('CURRENCY')),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _textField(
                  controller: addHawalaController.amountController,
                  hint: languagesController.tr('ENTER_AMOUNT'),
                  icon: Icons.payments_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  onChanged: (_) => _recalculateFinalAmount(),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(flex: 2, child: _buildCurrencySelector()),
            ],
          ),
          const SizedBox(height: 15),
          _buildFinalAmountCard(),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Material(
      color: _fieldColor,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: _showCurrencyDialog,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(() {
                  final symbol = addHawalaController.currency.value;
                  return Text(
                    symbol.isEmpty
                        ? languagesController.tr('CURRENCY')
                        : symbol,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: symbol.isEmpty ? _muted : _text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: _accent, size: 19),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
      decoration: BoxDecoration(
        color: _softGreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withOpacity(.19)),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: _accent.withOpacity(.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.savings_outlined, color: _accent, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languagesController.tr(
                    'FINAL_AMOUNT_DEDUCTED_FROM_YOUR_BALANCE',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Obx(() {
                  final amount = addHawalaController.finalAmount.value;
                  final currency = box.read('currency_code')?.toString() ?? '';
                  return Text(
                    '${amount.isEmpty ? '0.00' : amount} $currency',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _accent,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.3,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchSection() {
    return _section(
      title: languagesController.tr('BRANCH'),
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('BRANCH'),
          const SizedBox(height: 7),
          Material(
            color: _fieldColor,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              onTap: _showBranchDialog,
              borderRadius: BorderRadius.circular(13),
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_city_outlined,
                      color: _accent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(() {
                        final branch = addHawalaController.branch.value;
                        return Text(
                          branch.isEmpty
                              ? languagesController.tr('BRANCH')
                              : branch,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: branch.isEmpty ? _muted : _text,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 21,
                      color: _accent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Submit sits immediately below the Branch card and scrolls with the form.
  // The ListView's bottom padding keeps it clear of BaseScreen navigation.
  Widget _buildBottomAction() {
    return Obx(() {
      final busy = addHawalaController.isLoading.value;

      return SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: busy ? null : _submitHawala,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            disabledBackgroundColor: _accent.withOpacity(.48),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: busy
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    Text(languagesController.tr('PLEASE_WAIT')),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 19),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        languagesController.tr('CONFIRM_AND_SUBMIT'),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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

  // Keep the original exchange-rate calculation exactly the same.
  void _recalculateFinalAmount() {
    final selected = addHawalaController.selectedRate.value;

    if (selected == null || addHawalaController.currency.value.isEmpty) {
      addHawalaController.finalAmount.value = '0.00';
      return;
    }

    final input = _toDouble(addHawalaController.amountController.text.trim());
    final dAmount = _toDouble(selected.amount);
    final sRate = _toDouble(selected.sellRate);
    var result = 0.0;

    if (dAmount > 0 && sRate > 0) {
      result = (input / dAmount) * sRate;
    }

    addHawalaController.finalAmount.value = result.toStringAsFixed(2);
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> _uniqueRates() {
    final List<dynamic> rates =
        (hawalaCurrencyController.hawalafilteredcurrency.value.data?.rates
            as List?) ??
        <dynamic>[];
    final Map<String, dynamic> uniqueByToId = {};
    for (final rate in rates) {
      final toId = ((rate?.toCurrency?.id) ?? '').toString();
      if (toId.isEmpty) continue;
      uniqueByToId.putIfAbsent(toId, () => rate);
    }
    return uniqueByToId;
  }

  Widget _sheetHeader(String title, IconData icon, BuildContext sheetContext) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _softGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _accent, size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: _muted),
          onPressed: () => Navigator.pop(sheetContext),
        ),
      ],
    );
  }

  Widget _sheetOption({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? _softGreen : _fieldColor,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: selected ? _accent.withOpacity(.40) : _border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: _softGreen,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: _accent, size: 19),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _muted, fontSize: 10.5),
                        ),
                      ],
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, color: _accent, size: 20)
                else
                  Icon(Icons.chevron_right_rounded, color: _muted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCurrencyDialog() async {
    hawalaCurrencyController.fetchcurrency();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        bottom: false,
        child: Container(
          height: MediaQuery.of(sheetContext).size.height * .64,
          padding: const EdgeInsets.fromLTRB(16, 11, 16, 17),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              _sheetHeader(
                languagesController.tr('CURRENCY'),
                Icons.currency_exchange_rounded,
                sheetContext,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Obx(() {
                  if (hawalaCurrencyController.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(color: _accent),
                    );
                  }

                  final entries = _uniqueRates().entries.toList();
                  if (entries.isEmpty) {
                    return Center(
                      child: Text(
                        languagesController.tr('NO_DATA_FOUND'),
                        style: TextStyle(color: _muted, fontSize: 13),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final rate = entry.value;
                      final symbol = (rate?.toCurrency?.symbol ?? '')
                          .toString();
                      final code = (rate?.toCurrency?.code ?? '').toString();
                      final sellRate = (rate?.sellRate ?? '').toString();
                      final amount = (rate?.amount ?? '').toString();
                      final selected =
                          addHawalaController.currencyID.value == entry.key;

                      return _sheetOption(
                        title: code.isEmpty ? symbol : code,
                        subtitle: '$amount / $sellRate',
                        icon: Icons.currency_exchange_rounded,
                        selected: selected,
                        onTap: () {
                          addHawalaController.currencyID.value = entry.key;
                          addHawalaController.currency.value = symbol;
                          addHawalaController.selectedRate.value = rate;
                          _recalculateFinalAmount();
                          Navigator.pop(sheetContext);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBranchDialog() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        bottom: false,
        child: Container(
          height: MediaQuery.of(sheetContext).size.height * .64,
          padding: const EdgeInsets.fromLTRB(16, 11, 16, 17),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              _sheetHeader(
                languagesController.tr('BRANCH'),
                Icons.location_on_outlined,
                sheetContext,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Obx(() {
                  if (branchController.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(color: _accent),
                    );
                  }
                  final branches =
                      branchController.allbranch.value.data?.hawalabranches ??
                      [];
                  if (branches.isEmpty) {
                    return Center(
                      child: Text(
                        languagesController.tr('NO_DATA_FOUND'),
                        style: TextStyle(color: _muted, fontSize: 13),
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: branches.length,
                    itemBuilder: (context, index) {
                      final data = branches[index];
                      final selected =
                          addHawalaController.branchId.value ==
                          data.id.toString();
                      final address = data.address?.toString() ?? '';
                      return _sheetOption(
                        title: data.name.toString(),
                        subtitle: address,
                        icon: Icons.location_city_outlined,
                        selected: selected,
                        onTap: () {
                          addHawalaController.branch.value = data.name
                              .toString();
                          addHawalaController.branchId.value = data.id
                              .toString();
                          Navigator.pop(sheetContext);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitHawala() async {
    final hasSender = addHawalaController.senderNameController.text.isNotEmpty;
    final hasReceiver =
        addHawalaController.receiverNameController.text.isNotEmpty;
    final hasAmount = addHawalaController.amountController.text.isNotEmpty;
    final hasBranch = addHawalaController.branchId.value.isNotEmpty;
    final hasCurrency = addHawalaController.currencyID.value.isNotEmpty;

    if (!hasSender ||
        !hasReceiver ||
        !hasAmount ||
        !hasBranch ||
        !hasCurrency) {
      Fluttertoast.showToast(
        msg: languagesController.tr('FILL_DATA_CORRECTLY'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16,
      );
      return;
    }

    final success = await addHawalaController.createhawala();
    if (success) {
      Get.find<Mypagecontroller>().goBack();
    }
  }
}
