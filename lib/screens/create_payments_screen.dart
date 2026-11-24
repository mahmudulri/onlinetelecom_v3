import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'package:onlinetelecom/controllers/add_payment_controller.dart';
import 'package:onlinetelecom/controllers/currency_controller.dart';
import 'package:onlinetelecom/controllers/payment_method_controller.dart';
import 'package:onlinetelecom/controllers/payment_type_controller.dart';
import 'package:onlinetelecom/controllers/sign_in_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/models/payment_method_model.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Add New Receipt, restyled using the shared Online Telecom green theme.
/// Existing controllers, method selection, attachments, and addNow() remain.
class CreatePaymentsScreen extends StatefulWidget {
  const CreatePaymentsScreen({super.key});

  @override
  State<CreatePaymentsScreen> createState() => _CreatePaymentsScreenState();
}

class _CreatePaymentsScreenState extends State<CreatePaymentsScreen> {
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final SignInController signInController = Get.put(SignInController());
  final CurrencyController currencyController = Get.put(CurrencyController());
  final PaymentMethodController paymentMethodController = Get.put(
    PaymentMethodController(),
  );
  final PaymentTypeController paymentTypeController = Get.put(
    PaymentTypeController(),
  );
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final AddPaymentController addPaymentController = Get.put(
    AddPaymentController(),
  );
  final ThemeController themeController = Get.find<ThemeController>();
  final GetStorage box = GetStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Rx<DateTime?> mydate;
  final RxString selectedMethod = ''.obs;
  final RxString selectedType = ''.obs;
  final RxString selectedcurrency = ''.obs;

  bool get _dark => themeController.isDarkMode.value;
  Color get _background =>
      _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _card => _dark ? AppColors.darkCard : AppColors.lightSurface;
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
  void initState() {
    super.initState();
    final now = DateTime.now();
    mydate = Rx<DateTime?>(now);
    addPaymentController.selectedDate.value = DateFormat(
      'yyyy-MM-dd',
    ).format(now);
    paymentMethodController.fetchmethods();
    currencyController.fetchCurrencyList();
    paymentTypeController.fetchtypes();
    selectedcurrency.value = (box.read('currency_code') ?? '').toString();
    addPaymentController.currencyID.value = (box.read('countryID') ?? '')
        .toString();
  }

  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: mydate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (dialogContext, child) => Theme(
        data: Theme.of(dialogContext).copyWith(
          colorScheme: Theme.of(dialogContext).colorScheme.copyWith(
            primary: _accent,
            onPrimary: Colors.white,
            surface: _card,
            onSurface: _text,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    mydate.value = picked;
    addPaymentController.selectedDate.value = DateFormat(
      'yyyy-MM-dd',
    ).format(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = themeController.isDarkMode.value;
      final bars = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: isDarkMode
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
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 25),
                    children: [
                      _buildPaymentDetailsSection(),
                      const SizedBox(height: 12),
                      _buildReferenceSection(),
                      const SizedBox(height: 12),
                      _buildAttachmentsSection(),
                      const SizedBox(height: 12),
                      _buildBottomAction(),
                      const SizedBox(height: 18),
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
      child: Row(
        children: [
          _headerButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onTap: mypagecontroller.goBack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              languagesController.tr('ADD_NEW_RECEIPT'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 19.5,
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
            tooltip: 'Menu',
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .06 : .018),
            blurRadius: 15,
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _accent, size: 19),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _fieldLabel(String title, {bool optional = false}) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _text,
            ),
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          Text(
            '(${languagesController.tr('OPTIONAL')})',
            style: TextStyle(fontSize: 10.5, color: _muted),
          ),
        ],
      ],
    );
  }

  BoxDecoration _fieldDecoration() => BoxDecoration(
    color: _input,
    borderRadius: BorderRadius.circular(13),
    border: Border.all(color: _border),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    int maxLines = 1,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: maxLines > 1 ? 88 : 51),
      decoration: _fieldDecoration(),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12, top: maxLines > 1 ? 14 : 0),
            child: Icon(icon, color: _accent, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: formatters,
              maxLines: maxLines,
              style: TextStyle(
                color: _text,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: _accent,
              decoration: InputDecoration(
                hintText: hint,
                filled: false,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: maxLines > 1 ? 14 : 13,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintStyle: TextStyle(color: _muted, fontSize: 12.5),
              ),
            ),
          ),
          const SizedBox(width: 11),
        ],
      ),
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _input,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          constraints: const BoxConstraints(minHeight: 51),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 19, color: _accent),
              const SizedBox(width: 9),
              Expanded(child: child),
              Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: _muted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectedValue(RxString text, String fallback) {
    return Obx(() {
      final value = text.value;
      return Text(
        value.isEmpty ? fallback : value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: value.isEmpty ? _muted : _text,
          fontSize: 12.5,
          fontWeight: value.isEmpty ? FontWeight.w500 : FontWeight.w700,
        ),
      );
    });
  }

  Widget _buildPaymentDetailsSection() {
    return _section(
      icon: Icons.account_balance_wallet_outlined,
      title: languagesController.tr('PAYMENT_METHOD'),
      children: [
        _fieldLabel(languagesController.tr('PAYMENT_METHOD')),
        const SizedBox(height: 7),
        _pickerTile(
          icon: Icons.account_balance_rounded,
          child: _selectedValue(
            selectedMethod,
            languagesController.tr('PAYMENT_METHOD'),
          ),
          onTap: showPaymentMethodBottomSheet,
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _fieldLabel(languagesController.tr('AMOUNT')),
            ),
            const SizedBox(width: 9),
            Expanded(
              flex: 2,
              child: _fieldLabel(languagesController.tr('CURRENCY')),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _textField(
                controller: addPaymentController.amountController,
                hint: languagesController.tr('AMOUNT'),
                icon: Icons.payments_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                ],
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              flex: 2,
              child: _pickerTile(
                icon: Icons.currency_exchange_rounded,
                child: _selectedValue(
                  selectedcurrency,
                  languagesController.tr('CURRENCY'),
                ),
                onTap: _showCurrencyDialog,
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        _fieldLabel(languagesController.tr('PAYMENT_TYPE')),
        const SizedBox(height: 7),
        _pickerTile(
          icon: Icons.category_outlined,
          child: _selectedValue(
            selectedType,
            languagesController.tr('PAYMENT_TYPE'),
          ),
          onTap: _showPaymentTypeDialog,
        ),
      ],
    );
  }

  Widget _buildReferenceSection() {
    return _section(
      icon: Icons.event_note_outlined,
      title: languagesController.tr('PAYMENT_DATE'),
      children: [
        _fieldLabel(languagesController.tr('PAYMENT_DATE')),
        const SizedBox(height: 7),
        _pickerTile(
          icon: Icons.calendar_month_rounded,
          child: Obx(
            () => Text(
              addPaymentController.selectedDate.value,
              style: TextStyle(
                fontSize: 12.8,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
          ),
          onTap: () => pickStartDate(context),
        ),
        const SizedBox(height: 13),
        _fieldLabel(languagesController.tr('TRACKING_CODE')),
        const SizedBox(height: 7),
        _textField(
          controller: addPaymentController.trackingCodeController,
          hint: languagesController.tr('TRACKING_CODE'),
          icon: Icons.qr_code_2_rounded,
        ),
        const SizedBox(height: 13),
        _fieldLabel(languagesController.tr('NOTES'), optional: true),
        const SizedBox(height: 7),
        _textField(
          controller: addPaymentController.noteController,
          hint: languagesController.tr('NOTES'),
          icon: Icons.edit_note_rounded,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return _section(
      icon: Icons.image_outlined,
      title: languagesController.tr('UPLOAD_IMAGES'),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              buildImageUploaderBox(
                context,
                languagesController.tr('IMAGE_ONE'),
                addPaymentController.paymentImagePath,
                () => addPaymentController.pickImage('payment'),
              ),
              const SizedBox(width: 9),
              buildImageUploaderBox(
                context,
                languagesController.tr('IMAGE_TOW'),
                addPaymentController.extraImage1Path,
                () => addPaymentController.pickImage('extra1'),
              ),
              const SizedBox(width: 9),
              buildImageUploaderBox(
                context,
                languagesController.tr('IMAGE_THREE'),
                addPaymentController.extraImage2Path,
                () => addPaymentController.pickImage('extra2'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    final media = MediaQuery.of(context);
    final keyboardVisible = media.viewInsets.bottom > 0;
    // BaseScreen has extendBody and a custom 76px nav + center action.
    // Reserve enough space so this action does not sit under those overlays.
    final bottomClearance = keyboardVisible
        ? 12.0
        : 76.0 + 38.0 + media.viewPadding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: _background,
        border: Border(top: BorderSide(color: _border)),
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, bottomClearance),
      child: Obx(() {
        final busy = addPaymentController.isLoading.value;
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: busy ? null : _submitPayment,
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
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 9),
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
                          languagesController.tr('ADD_NOW'),
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
      }),
    );
  }

  void _submitPayment() {
    final invalid =
        addPaymentController.payment_method_id.value.isEmpty ||
        addPaymentController.amountController.text.isEmpty ||
        addPaymentController.currencyID.value.isEmpty ||
        addPaymentController.selectedDate.value.isEmpty ||
        addPaymentController.trackingCodeController.text.isEmpty;
    if (invalid) {
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
    addPaymentController.addNow();
  }

  Widget _pickerDialogHeader(
    BuildContext dialogContext,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 14, 10, 11),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _softGreen,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: _accent, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _text,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(dialogContext),
            icon: Icon(Icons.close_rounded, color: _muted, size: 21),
          ),
        ],
      ),
    );
  }

  Widget _selectionOption({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool selected = false,
    String? subtitle,
  }) {
    return Material(
      color: selected ? _softGreen : _input,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? _accent.withOpacity(.5) : _border,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: _accent),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _muted, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: selected ? _accent : _muted,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: _card,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
        child: SizedBox(
          height: MediaQuery.of(dialogContext).size.height * .59,
          child: Column(
            children: [
              _pickerDialogHeader(
                dialogContext,
                languagesController.tr('CURRENCY'),
                Icons.currency_exchange_rounded,
              ),
              Expanded(
                child: Obx(() {
                  if (currencyController.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(color: _accent),
                    );
                  }
                  final currencies =
                      currencyController
                          .allcurrencylist
                          .value
                          .data
                          ?.currencies ??
                      [];
                  if (currencies.isEmpty) {
                    return Center(
                      child: Text(
                        languagesController.tr('NO_DATA_FOUND'),
                        style: TextStyle(color: _muted),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 15),
                    itemCount: currencies.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 7),
                    itemBuilder: (_, index) {
                      final data = currencies[index];
                      return _selectionOption(
                        icon: Icons.payments_outlined,
                        label: data.code?.toString() ?? '',
                        subtitle: data.symbol?.toString() ?? '',
                        selected:
                            addPaymentController.currencyID.value ==
                            data.id.toString(),
                        onTap: () {
                          addPaymentController.currencyID.value = data.id
                              .toString();
                          selectedcurrency.value = data.code.toString();
                          Navigator.pop(dialogContext);
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

  void _showPaymentTypeDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: _card,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
        child: SizedBox(
          height: MediaQuery.of(dialogContext).size.height * .53,
          child: Column(
            children: [
              _pickerDialogHeader(
                dialogContext,
                languagesController.tr('PAYMENT_TYPE'),
                Icons.category_outlined,
              ),
              Expanded(
                child: Obx(() {
                  if (paymentTypeController.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(color: _accent),
                    );
                  }
                  final types =
                      paymentTypeController.alltypes.value.data?.paymentTypes ??
                      [];
                  if (types.isEmpty) {
                    return Center(
                      child: Text(
                        languagesController.tr('NO_DATA_FOUND'),
                        style: TextStyle(color: _muted),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 15),
                    itemCount: types.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 7),
                    itemBuilder: (_, index) {
                      final data = types[index];
                      return _selectionOption(
                        icon: Icons.category_rounded,
                        label: data.name?.toString() ?? '',
                        selected:
                            addPaymentController.payment_type_id.value ==
                            data.id.toString(),
                        onTap: () {
                          addPaymentController.payment_type_id.value = data.id
                              .toString();
                          selectedType.value = data.name.toString();
                          Navigator.pop(dialogContext);
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

  void showPaymentMethodBottomSheet() {
    final RxString selectedFilter = 'All'.obs;
    final RxString temporarySelectedId =
        addPaymentController.payment_method_id.value.obs;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(.38),
      builder: (sheetContext) => SafeArea(
        bottom: false,
        child: Container(
          height: MediaQuery.of(sheetContext).size.height * .80,
          decoration: BoxDecoration(
            color: _card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 11),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              _pickerDialogHeader(
                sheetContext,
                languagesController.tr('PAYMENT_METHOD'),
                Icons.account_balance_wallet_outlined,
              ),
              Expanded(
                child: Obx(() {
                  if (paymentMethodController.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(color: _accent),
                    );
                  }
                  final List<PaymentMethod> allMethods =
                      paymentMethodController
                          .allmethods
                          .value
                          .data
                          ?.paymentMethods ??
                      <PaymentMethod>[];
                  if (allMethods.isEmpty) {
                    return Center(
                      child: Text(
                        languagesController.tr('NO_DATA_FOUND'),
                        style: TextStyle(color: _muted),
                      ),
                    );
                  }
                  final methodNames = <String>[];
                  for (final method in allMethods) {
                    final name = method.methodName?.trim() ?? '';
                    if (name.isNotEmpty && !methodNames.contains(name)) {
                      methodNames.add(name);
                    }
                  }
                  final filters = ['All', ...methodNames];
                  final filteredMethods = selectedFilter.value == 'All'
                      ? allMethods
                      : allMethods
                            .where(
                              (method) =>
                                  method.methodName?.trim() ==
                                  selectedFilter.value,
                            )
                            .toList();
                  return Column(
                    children: [
                      SizedBox(
                        height: 39,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filters.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 7),
                          itemBuilder: (_, index) {
                            final filter = filters[index];
                            final isSelected = filter == selectedFilter.value;
                            return InkWell(
                              onTap: () => selectedFilter.value = filter,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? _accent : _input,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? _accent : _border,
                                  ),
                                ),
                                child: Text(
                                  filter,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : _text,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filteredMethods.isEmpty
                            ? Center(
                                child: Text(
                                  languagesController.tr('NO_DATA_FOUND'),
                                  style: TextStyle(color: _muted),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  15,
                                  0,
                                  15,
                                  8,
                                ),
                                itemCount: filteredMethods.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (_, index) {
                                  final method = filteredMethods[index];
                                  return Obx(
                                    () => PaymentMethodSelectionCard(
                                      paymentMethod: method,
                                      isSelected:
                                          temporarySelectedId.value ==
                                          method.id?.toString(),
                                      onTap: () => temporarySelectedId.value =
                                          method.id?.toString() ?? '',
                                    ),
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          9,
                          16,
                          13 + MediaQuery.of(sheetContext).viewPadding.bottom,
                        ),
                        child: Obx(() {
                          final canContinue =
                              temporarySelectedId.value.isNotEmpty;
                          return SizedBox(
                            width: double.infinity,
                            height: 49,
                            child: ElevatedButton(
                              onPressed: canContinue
                                  ? () {
                                      PaymentMethod? selectedPaymentMethod;
                                      for (final method in allMethods) {
                                        if (method.id?.toString() ==
                                            temporarySelectedId.value) {
                                          selectedPaymentMethod = method;
                                          break;
                                        }
                                      }
                                      if (selectedPaymentMethod == null) return;
                                      addPaymentController
                                              .payment_method_id
                                              .value =
                                          selectedPaymentMethod.id
                                              ?.toString() ??
                                          '';
                                      selectedMethod.value =
                                          selectedPaymentMethod.methodName ??
                                          '';
                                      Navigator.pop(sheetContext);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accent,
                                disabledBackgroundColor: _accent.withOpacity(
                                  .24,
                                ),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Public helper retained for existing call sites.
Widget buildImageUploaderBox(
  BuildContext context,
  String label,
  RxString imagePath,
  VoidCallback onPick,
) {
  final themeController = Get.find<ThemeController>();
  return Obx(() {
    final dark = themeController.isDarkMode.value;
    final card = dark ? AppColors.darkInputBackground : const Color(0xFFF7FAF8);
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
    final muted = dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    return SizedBox(
      width: 136,
      height: 120,
      child: Stack(
        children: [
          Material(
            color: card,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 136,
                height: 120,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: imagePath.value.isNotEmpty
                    ? Image.file(
                        File(imagePath.value),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.primaryColor,
                          size: 25,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 37,
                            width: 37,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(.11),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_outlined,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: muted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          if (imagePath.value.isNotEmpty)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => imagePath.value = '',
                child: Container(
                  width: 29,
                  height: 29,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  });
}

/// Payment account information, copy-to-clipboard and Sheba warnings retained.
class PaymentMethodSelectionCard extends StatelessWidget {
  const PaymentMethodSelectionCard({
    super.key,
    required this.paymentMethod,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentMethod paymentMethod;
  final bool isSelected;
  final VoidCallback onTap;

  bool _hasValue(String? value) {
    if (value == null) return false;
    final text = value.trim();
    return text.isNotEmpty && text.toLowerCase() != 'null' && text != '.';
  }

  String _getPrimaryNumber() {
    if (_hasValue(paymentMethod.accountNumber)) {
      return paymentMethod.accountNumber!.trim();
    }
    if (_hasValue(paymentMethod.cardNumber)) {
      return paymentMethod.cardNumber!.trim();
    }
    if (_hasValue(paymentMethod.accountHolderName)) {
      return paymentMethod.accountHolderName!.trim();
    }
    return '';
  }

  bool _shouldShowShebaWarning() {
    if (!_hasValue(paymentMethod.shebaNumber)) return false;
    final sheba = paymentMethod.shebaNumber!.trim();
    if (sheba == paymentMethod.accountNumber?.trim()) return false;
    if (sheba == paymentMethod.cardNumber?.trim()) return false;
    return true;
  }

  bool _hasUsableImage() {
    final src = paymentMethod.accountImage?.trim() ?? '';
    if (src.isEmpty || !src.startsWith('http')) return false;
    final uri = Uri.tryParse(src);
    if (uri == null || uri.pathSegments.isEmpty) return false;
    return uri.pathSegments.last.trim().contains('.');
  }

  Future<void> _copyValue(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    Fluttertoast.showToast(
      msg: 'Copied',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<ThemeController>();
    final dark = theme.isDarkMode.value;
    final surface = dark ? AppColors.darkInputBackground : Colors.white;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final muted = dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final accent = AppColors.primaryColor;
    final primaryNumber = _getPrimaryNumber();

    return Material(
      color: isSelected
          ? (dark ? const Color(0xFF1D3829) : const Color(0xFFE9F7ED))
          : surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? accent.withOpacity(.65) : border,
              width: isSelected ? 1.4 : 1,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 51,
                height: 51,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: accent.withOpacity(.10),
                ),
                child: _hasUsableImage()
                    ? Image.network(
                        paymentMethod.accountImage!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) =>
                            loadingProgress == null
                            ? child
                            : Center(
                                child: SizedBox(
                                  height: 19,
                                  width: 19,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: accent,
                                  ),
                                ),
                              ),
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.account_balance_wallet_outlined,
                          color: accent,
                          size: 24,
                        ),
                      )
                    : Icon(
                        Icons.account_balance_wallet_outlined,
                        color: accent,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            paymentMethod.methodName ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: text,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (_hasValue(paymentMethod.bankName))
                          Container(
                            constraints: const BoxConstraints(maxWidth: 100),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(.09),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              paymentMethod.bankName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: accent,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_hasValue(paymentMethod.accountHolderName)) ...[
                      const SizedBox(height: 4),
                      Text(
                        paymentMethod.accountHolderName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: muted, fontSize: 10.5),
                      ),
                    ],
                    if (primaryNumber.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              primaryNumber,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: text,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _copyValue(primaryNumber),
                            icon: Icon(
                              Icons.copy_rounded,
                              size: 16,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_shouldShowShebaWarning()) ...[
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: dark
                              ? const Color(0xFF443821)
                              : const Color(0xFFFFF6DA),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFE0A51B),
                              size: 17,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                paymentMethod.shebaNumber!,
                                style: TextStyle(
                                  color: dark
                                      ? const Color(0xFFF7D88C)
                                      : const Color(0xFF8A6817),
                                  fontSize: 10.5,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_hasValue(paymentMethod.accountDetails)) ...[
                      const SizedBox(height: 6),
                      Text(
                        paymentMethod.accountDetails!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: muted, fontSize: 10.5),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected ? accent : muted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
