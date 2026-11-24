import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'package:onlinetelecom/controllers/loanlist_controller.dart';
import 'package:onlinetelecom/controllers/request_loan_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Loan Request / History — Online Telecom green theme.
/// Retains all original API calls, translation keys, and loan data fields.
/// No Directionality widget or intro/banner card.
class RequestLoanScreen extends StatefulWidget {
  const RequestLoanScreen({super.key});

  @override
  State<RequestLoanScreen> createState() => _RequestLoanScreenState();
}

class _RequestLoanScreenState extends State<RequestLoanScreen> {
  final LoanlistController loanlistController = Get.put(LoanlistController());
  final RequestLoanController requestLoanController = Get.put(
    RequestLoanController(),
  );
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final ThemeController themeController = Get.find<ThemeController>();
  final GetStorage box = GetStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _dark => themeController.isDarkMode.value;
  Color get _background =>
      _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _field =>
      _dark ? AppColors.darkInputBackground : const Color(0xFFF5F9F6);
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _green => AppColors.primaryColor;
  Color get _greenSoft =>
      _dark ? const Color(0xFF203D2B) : const Color(0xFFEAF7EE);

  @override
  void initState() {
    super.initState();
    loanlistController.fetchLoan();
  }

  Future<void> _refreshLoans() async {
    loanlistController.fetchLoan();
    // The existing controller begins its fetch without returning a Future.
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final darkMode = themeController.isDarkMode.value;
      final statusBarStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: darkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: darkMode
            ? Brightness.light
            : Brightness.dark,
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: statusBarStyle,
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
                _buildRequestButton(),
                const SizedBox(height: 15),
                Expanded(child: _buildLoanList()),
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
            child: Icon(icon, color: _text, size: 21),
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
              languagesController.tr('LOAN_REQUEST'),
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

  Widget _buildRequestButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 53,
        child: ElevatedButton.icon(
          onPressed: _showLoanRequestDialog,
          icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
          label: Text(
            languagesController.tr('ADD_NEW_REQUEST'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: _green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoanList() {
    final media = MediaQuery.of(context);
    final bottomPadding = media.viewInsets.bottom > 0
        ? 24.0
        : 76.0 + 38.0 + media.viewPadding.bottom;

    return Obx(() {
      final loans =
          loanlistController.allloanlist.value.data?.balances?.data ?? [];
      final loading = loanlistController.isLoading.value;

      if (loading && loans.isEmpty) {
        return Center(
          child: CircularProgressIndicator(color: _green, strokeWidth: 2.6),
        );
      }

      if (loans.isEmpty) {
        return RefreshIndicator(
          onRefresh: _refreshLoans,
          color: _green,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 60, 16, bottomPadding),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _greenSoft,
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: _green,
                        size: 31,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      languagesController.tr('NO_DATA_FOUND'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: _green,
        onRefresh: _refreshLoans,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
          itemCount: loans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, index) => _buildLoanRow(loans[index]),
        ),
      );
    });
  }

  /// Statement-style row: colored rail, amount / status, and compact metadata.
  Widget _buildLoanRow(dynamic data) {
    final status = data.status?.toString() ?? '';
    final statusColor = _statusColor(status);
    final amount = data.amount?.toString() ?? '';
    final symbol = data.currency?.symbol?.toString() ?? '';
    final currencyCode = data.currency?.code?.toString() ?? '';
    final balance = data.remainingBalance?.toString() ?? '';
    final transactionType = data.transactionType?.toString() ?? '';
    final description = data.description?.toString() ?? '';
    final createdAt = _formatDate(data.createdAt?.toString());

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent rail follows the dynamic row height, including long notes.
            Container(width: 4, color: statusColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            color: _greenSoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 18,
                            color: _green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languagesController.tr('AMOUNT'),
                                style: TextStyle(color: _muted, fontSize: 10),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$amount $symbol'.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _text,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(_dark ? .16 : .10),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            _statusText(status),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Container(
                      decoration: BoxDecoration(
                        color: _field,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          _detailLine(
                            languagesController.tr('TRANSACTION_TYPE'),
                            transactionType,
                          ),
                          const SizedBox(height: 8),
                          _detailLine(
                            languagesController.tr('REMAINING_BALANCE'),
                            '$balance $currencyCode'.trim(),
                            valueColor: _green,
                          ),
                        ],
                      ),
                    ),
                    if (description.isNotEmpty &&
                        description.toLowerCase() != 'null') ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.sticky_note_2_outlined,
                            size: 15,
                            color: _muted,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: _muted, fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (createdAt.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: _muted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            createdAt,
                            style: TextStyle(
                              color: _muted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailLine(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: _muted, fontSize: 11)),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor ?? _text,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  void _showLoanRequestDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Obx(() {
          // Preserve dark-mode colors even when the dialog is open.
          // Observe the global theme while the dialog is open.
          final isDarkMode = themeController.isDarkMode.value;
          final busy = requestLoanController.isLoading.value;
          return Dialog(
            backgroundColor: isDarkMode
                ? AppColors.darkCard
                : AppColors.lightSurface,
            surfaceTintColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(23),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                18,
                17,
                18,
                MediaQuery.of(dialogContext).viewInsets.bottom > 0 ? 15 : 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _greenSoft,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          Icons.request_quote_outlined,
                          color: _green,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          languagesController.tr('ENTER_LOAN_AMOUNT'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: _text,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: busy
                            ? null
                            : () => Navigator.pop(dialogContext),
                        icon: Icon(Icons.close_rounded, color: _muted),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 19),
                  Text(
                    languagesController.tr('AMOUNT'),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: _muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 53,
                    decoration: BoxDecoration(
                      color: _field,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(Icons.payments_outlined, size: 19, color: _green),
                        const SizedBox(width: 9),
                        Expanded(
                          child: TextField(
                            controller: requestLoanController.amountController,
                            enabled: !busy,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            cursorColor: _green,
                            style: TextStyle(
                              color: _text,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              hintText: languagesController.tr('ENTER_AMOUNT'),
                              hintStyle: TextStyle(color: _muted, fontSize: 12),
                              filled: false,
                              fillColor: Colors.transparent,
                              isDense: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _greenSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            box.read('currency_code')?.toString() ?? '',
                            style: TextStyle(
                              color: _green,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: busy
                              ? null
                              : () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _text,
                            side: BorderSide(color: _border),
                            minimumSize: const Size.fromHeight(49),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: Text(
                            languagesController.tr('CANCEL'),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: busy ? null : _submitLoanRequest,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(49),
                            elevation: 0,
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _green.withOpacity(.45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
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
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Flexible(
                                      child: Text(
                                        languagesController.tr('PLEASE_WAIT'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  languagesController.tr('SUBMIT'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _submitLoanRequest() {
    if (requestLoanController.amountController.text.isEmpty) {
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

    requestLoanController.requestloan();
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate == 'null' || rawDate.trim().isEmpty) {
      return '';
    }
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    return DateFormat('dd MMM yyyy').format(parsed);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFE1A22B);
      case 'completed':
        return const Color(0xFF16A36A);
      default:
        return const Color(0xFFE35E69);
    }
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return languagesController.tr('PENDING');
      case 'completed':
        return languagesController.tr('COMPLETED');
      default:
        return languagesController.tr('ROLLBACKED');
    }
  }
}
