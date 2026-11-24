import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:onlinetelecom/controllers/withdrawlist_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

import 'create_withdraw_screen.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final WithdrawlistController withdrawlistController = Get.put(
    WithdrawlistController(),
  );
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final ThemeController themeController = Get.find<ThemeController>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Set<String> _expandedRecordIds = <String>{};

  static const Color _green = AppColors.primaryColor;
  static const Color _positive = Color(0xFF1D9F5A);
  static const Color _pending = Color(0xFFC78B2C);
  static const Color _negative = Color(0xFFDB6570);

  bool get _dark => themeController.isDarkMode.value;
  Color get _background =>
      _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _subtle =>
      _dark ? AppColors.darkInputBackground : const Color(0xFFF4F8F5);
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;

  @override
  void initState() {
    super.initState();
    withdrawlistController.fetchlist();
  }

  Future<void> _refreshWithdrawals() async {
    // Keep the original public controller method and refresh behavior.
    withdrawlistController.fetchlist();
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = themeController.isDarkMode.value;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: _background,
          systemNavigationBarIconBrightness: isDarkMode
              ? Brightness.light
              : Brightness.dark,
        ),
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
                _buildCreateAction(),
                const SizedBox(height: 14),
                Expanded(child: _buildWithdrawals()),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          _headerAction(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onTap: mypagecontroller.goBack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              languagesController.tr('WITHDRAW'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.25,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _headerAction(
            icon: themeController.isDarkMode.value
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            tooltip: themeController.isDarkMode.value
                ? 'Light mode'
                : 'Dark mode',
            onTap: themeController.toggleTheme,
          ),
          const SizedBox(width: 8),
          _headerAction(
            icon: Icons.menu_rounded,
            tooltip: 'Menu',
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _headerAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            height: 42,
            width: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _border),
            ),
            child: Icon(icon, color: _text, size: 21),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAction() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: _green,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => mypagecontroller.changePage(
            CreateWithdrawScreen(),
            isMainPage: false,
          ),
          child: SizedBox(
            height: 52,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    height: 31,
                    width: 31,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_card_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      languagesController.tr('NEW_WITHDRAW_REQUEST'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawals() {
    final media = MediaQuery.of(context);
    final bottomSpace = media.viewInsets.bottom > 0
        ? 24.0
        : 76.0 + 38.0 + media.viewPadding.bottom;

    return Obx(() {
      if (withdrawlistController.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: _green));
      }

      final requests =
          withdrawlistController.allwithdrawlist.value.data?.withdrawRequests ??
          [];

      if (requests.isEmpty) {
        return RefreshIndicator(
          color: _green,
          onRefresh: _refreshWithdrawals,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 82, 16, bottomSpace),
            children: [
              Center(
                child: Container(
                  height: 64,
                  width: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _subtle,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: _green,
                    size: 29,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                languagesController.tr('NO_DATA_FOUND'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: _green,
        onRefresh: _refreshWithdrawals,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16, 1, 16, bottomSpace),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 9),
          itemBuilder: (_, index) => _buildWithdrawCard(requests[index]),
        ),
      );
    });
  }

  String _safeText(dynamic value, {String fallback = '—'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return fallback;
    return text;
  }

  String _requestKey(dynamic request) {
    // Use object identity so this UI never depends on an optional model ID.
    return '${identityHashCode(request)}';
  }

  Widget _buildWithdrawCard(dynamic request) {
    final status = request.status?.toString() ?? '';
    final statusColor = _statusColor(status);
    final statusFill = statusColor.withOpacity(_dark ? 0.14 : 0.085);
    final amount = _safeText(request.amount);
    final commission = _safeText(request.commissionAmount);
    final netAmount = _safeText(request.netAmount);
    final bank = request.bankDetails;
    final hasBank = bank != null;
    final key = _requestKey(request);
    final expanded = _expandedRecordIds.contains(key);

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? 0.16 : 0.045),
            blurRadius: 13,
            spreadRadius: -3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Narrow side stripe gives status context without a large status icon.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: statusColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(13, 12, 13, 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                languagesController.tr('NET_AMOUNT'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 142),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusFill,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _statusIcon(status),
                                    size: 12,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      _statusText(status),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          netAmount,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _text,
                            fontSize: 20,
                            letterSpacing: -0.45,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 11),
                        Container(height: 1, color: _border),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _smallAmount(
                                title: languagesController.tr('AMOUNT'),
                                amount: amount,
                                dotColor: _green,
                              ),
                            ),
                            Container(
                              height: 29,
                              width: 1,
                              color: _border,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 13,
                              ),
                            ),
                            Expanded(
                              child: _smallAmount(
                                title: languagesController.tr('COMMISSION'),
                                amount: commission,
                                dotColor: _pending,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasBank) ...[
            Container(height: 1, color: _border),
            _bankDisclosure(
              bank: bank,
              expanded: expanded,
              onTap: () {
                setState(() {
                  if (expanded) {
                    _expandedRecordIds.remove(key);
                  } else {
                    _expandedRecordIds.add(key);
                  }
                });
              },
            ),
            if (expanded) _bankDetails(request),
          ],
        ],
      ),
    );
  }

  Widget _smallAmount({
    required String title,
    required String amount,
    required Color dotColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                amount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bankDisclosure({
    required dynamic bank,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.account_balance_outlined, size: 16, color: _green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${languagesController.tr('BANK_DETAILS')} · ${_safeText(bank.bankName)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: _green,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bankDetails(dynamic request) {
    final bank = request.bankDetails;
    final iban = _safeText(bank.iban, fallback: '');
    return Container(
      color: _subtle,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      child: Column(
        children: [
          _bankInfoRow(
            languagesController.tr('BANK_NAME'),
            _safeText(bank.bankName),
          ),
          const SizedBox(height: 9),
          _bankInfoRow(
            languagesController.tr('ACCOUNT_HOLDER'),
            _safeText(bank.accountHolderName),
          ),
          const SizedBox(height: 9),
          _bankInfoRow(
            languagesController.tr('ACCOUNT_NUMBER'),
            _safeText(bank.accountNumber),
          ),
          if (iban.isNotEmpty) ...[
            const SizedBox(height: 9),
            _bankInfoRow(languagesController.tr('IBAN'), iban),
          ],
          const SizedBox(height: 11),
          Container(height: 1, color: _border),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _dateCell(
                  title: languagesController.tr('CREATED'),
                  date: _formatDate(request.createdAt),
                  icon: Icons.calendar_month_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateCell(
                  title: languagesController.tr('UPDATED'),
                  date: _formatDate(request.updatedAt),
                  icon: Icons.update_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bankInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(label, style: TextStyle(color: _muted, fontSize: 10.8)),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            softWrap: true,
            style: TextStyle(
              color: _text,
              fontSize: 10.8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateCell({
    required String title,
    required String date,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: _green, size: 15),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _muted, fontSize: 9.5),
              ),
              const SizedBox(height: 3),
              Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: 10.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'N/A';
    if (value is DateTime) return DateFormat('dd MMM yyyy').format(value);
    final text = value.toString();
    final parsed = DateTime.tryParse(text);
    return parsed == null ? text : DateFormat('dd MMM yyyy').format(parsed);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return _positive;
      case 'pending':
        return _pending;
      case 'rejected':
      case 'cancelled':
      case 'canceled':
        return _negative;
      default:
        return _green;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      case 'rejected':
      case 'cancelled':
      case 'canceled':
        return Icons.highlight_off_rounded;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  String _statusText(String status) {
    if (status.isEmpty) return '';
    switch (status.toLowerCase()) {
      case 'pending':
        return languagesController.tr('PENDING');
      case 'completed':
        return languagesController.tr('COMPLETED');
      case 'rejected':
        return languagesController.tr('REJECTED');
      default:
        return status.toUpperCase();
    }
  }
}
