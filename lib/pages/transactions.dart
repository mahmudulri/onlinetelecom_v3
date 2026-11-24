import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'package:onlinetelecom/controllers/dashboard_controller.dart';
import 'package:onlinetelecom/controllers/transaction_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final RxString selectedOrderStatus = ''.obs;
  final RxString selectedCategoryType = ''.obs;
  final RxString selectedPurposeType = ''.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  final List<Map<String, String>> orderStatus = const [
    {'titleKey': 'CREDIT', 'value': 'credit'},
    {'titleKey': 'DEBIT', 'value': 'debit'},
  ];

  final List<Map<String, String>> categoryType = const [
    {'titleKey': 'ADMIN_TO_RESELLER', 'value': 'admin-reseller'},
    {'titleKey': 'RESELLER_TO_ADMIN', 'value': 'reseller-subreseller'},
  ];

  final List<Map<String, String>> purposeType = const [
    {'titleKey': 'ORDER', 'value': 'order'},
    {'titleKey': 'MONEY_TRANSFER', 'value': 'money'},
  ];

  final GetStorage box = GetStorage();
  final TransactionController transactionController =
      Get.find<TransactionController>();
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  // Retained as part of the existing page's dependencies.
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final NumberFormat amountFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '',
    decimalDigits: 2,
  );

  bool isFilterOpen = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _background =>
      _isDark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _surface => _isDark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _fieldSurface =>
      _isDark ? AppColors.darkInputBackground : AppColors.lightBackground;
  Color get _textColor => Theme.of(context).colorScheme.onSurface;
  Color get _muted =>
      _isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _primary => Theme.of(context).colorScheme.primary;

  static const Color _debit = Color(0xFFE05A6C);
  static const Color _credit = Color(0xFF16A36A);

  @override
  void initState() {
    super.initState();

    box.write('transactiontype', '');
    box.write('category', '');
    box.write('purpose', '');
    box.write('startdate', '');
    box.write('enddate', '');

    transactionController.fetchTransactionData();
  }

  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (dialogContext, child) => Theme(
        data: Theme.of(dialogContext).copyWith(
          colorScheme: Theme.of(dialogContext).colorScheme.copyWith(
            primary: _primary,
            onPrimary: Colors.white,
            surface: _surface,
            onSurface: _textColor,
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;
    startDate.value = picked;
    box.write(
      'startdate',
      '&filter_startdate=${DateFormat('yyyy-MM-dd').format(picked)}',
    );

    if (endDate.value != null && endDate.value!.isBefore(picked)) {
      endDate.value = null;
      box.write('enddate', '');
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    if (startDate.value == null) {
      Get.snackbar(
        languagesController.tr('WARNING'),
        languagesController.tr('SELECT_START_DATE_FIRST'),
        snackPosition: SnackPosition.TOP,
        backgroundColor: _primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? startDate.value!,
      firstDate: startDate.value!,
      lastDate: DateTime(2100),
      builder: (dialogContext, child) => Theme(
        data: Theme.of(dialogContext).copyWith(
          colorScheme: Theme.of(dialogContext).colorScheme.copyWith(
            primary: _primary,
            onPrimary: Colors.white,
            surface: _surface,
            onSurface: _textColor,
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;
    endDate.value = picked;
    box.write(
      'enddate',
      '&filter_enddate=${DateFormat('yyyy-MM-dd').format(picked)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _isDark ? Brightness.light : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness,
        statusBarBrightness: _isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: brightness,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const DrawerWidget(),
        resizeToAvoidBottomInset: false,
        backgroundColor: _background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 7, 16, 0),
                child: _buildHeader(),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildFilterSection(),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: RefreshIndicator(
                  color: _primary,
                  onRefresh: () async {
                    transactionController.fetchTransactionData();
                    await Future<void>.delayed(
                      const Duration(milliseconds: 450),
                    );
                  },
                  child: _buildTransactionList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _headerIcon(
          icon: Icons.menu_rounded,
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            languagesController.tr('TRANSACTIONS'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _textColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
        ),

        const SizedBox(width: 8),
        Obx(
          () => _headerIcon(
            icon: themeController.isDarkMode.value
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            onTap: themeController.toggleTheme,
          ),
        ),
        const SizedBox(width: 7),
        _buildProfileAvatar(),
      ],
    );
  }

  Widget _headerIcon({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 43,
          width: 43,
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _textColor, size: 21),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Obx(() {
      final profileImageUrl = dashboardController
          .alldashboardData
          .value
          .data
          ?.userInfo
          ?.profileImageUrl;
      final hasImage = profileImageUrl != null && profileImageUrl.isNotEmpty;

      return Container(
        height: 39,
        width: 39,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _primary.withOpacity(0.4), width: 1.3),
        ),
        child: ClipOval(
          child: hasImage
              ? Image.network(
                  profileImageUrl.toString(),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.person_rounded, color: _primary),
                )
              : ColoredBox(
                  color: _fieldSurface,
                  child: Icon(Icons.person_rounded, color: _primary, size: 22),
                ),
        ),
      );
    });
  }

  Widget _buildFilterSection() {
    final borderRadius = BorderRadius.circular(19);

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: borderRadius,
        border: Border.all(color: _border),
        boxShadow: _isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF163C24).withOpacity(0.045),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => isFilterOpen = !isFilterOpen),
              borderRadius: borderRadius,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 10, 12, 10),
                child: Row(
                  children: [
                    Container(
                      height: 37,
                      width: 37,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(_isDark ? 0.16 : 0.09),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: _primary,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        languagesController.tr('FILTER_TRANSACTION'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _textColor,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isFilterOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _muted,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isFilterOpen
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(13, 0, 13, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Divider(color: _border, height: 12),
                        _filterLabel(languagesController.tr('TYPE')),
                        const SizedBox(height: 5),
                        _buildDropdown(
                          selectedValue: selectedOrderStatus,
                          items: orderStatus,
                          onChanged: (value) {
                            selectedOrderStatus.value = value ?? '';
                            box.write(
                              'transactiontype',
                              value == null || value.isEmpty
                                  ? ''
                                  : '&filter_transactiontype=$value',
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _filterGroup(
                                languagesController.tr('SELECT_CATEGORY'),
                                _buildDropdown(
                                  selectedValue: selectedCategoryType,
                                  items: categoryType,
                                  onChanged: (value) {
                                    selectedCategoryType.value = value ?? '';
                                    box.write(
                                      'category',
                                      value == null || value.isEmpty
                                          ? ''
                                          : '&filter_transactioncategory=$value',
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: _filterGroup(
                                languagesController.tr('SELECT_PURPOSE'),
                                _buildDropdown(
                                  selectedValue: selectedPurposeType,
                                  items: purposeType,
                                  onChanged: (value) {
                                    selectedPurposeType.value = value ?? '';
                                    box.write(
                                      'purpose',
                                      value == null || value.isEmpty
                                          ? ''
                                          : '&filter_transactionpurpose=$value',
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _dateBox(
                                date: startDate,
                                placeholder: languagesController.tr(
                                  'START_DATE',
                                ),
                                onTap: () => pickStartDate(context),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: _dateBox(
                                date: endDate,
                                placeholder: languagesController.tr('END_DATE'),
                                onTap: () => pickEndDate(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _filterButton(
                                label: languagesController.tr('APPLY_FILTER'),
                                filled: true,
                                onTap: () => transactionController
                                    .fetchTransactionData(),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: _filterButton(
                                label: languagesController.tr('REMOVE_FILTER'),
                                filled: false,
                                onTap: _removeFilter,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _filterGroup(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_filterLabel(label), const SizedBox(height: 5), child],
    );
  }

  Widget _filterLabel(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: _muted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDropdown({
    required RxString selectedValue,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _fieldSurface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _border),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue.value.isEmpty ? null : selectedValue.value,
            isExpanded: true,
            isDense: true,
            dropdownColor: _surface,
            borderRadius: BorderRadius.circular(12),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _primary,
              size: 19,
            ),
            hint: Text(
              languagesController.tr('ALL'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _muted, fontSize: 12),
            ),
            items: [
              DropdownMenuItem<String>(
                value: '',
                child: Text(
                  languagesController.tr('ALL'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _textColor, fontSize: 12),
                ),
              ),
              ...items.map(
                (data) => DropdownMenuItem<String>(
                  value: data['value'],
                  child: Text(
                    languagesController.tr(data['titleKey']!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _textColor, fontSize: 12),
                  ),
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _dateBox({
    required Rx<DateTime?> date,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    return Material(
      color: _fieldSurface,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: 43,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(
                  () => Text(
                    date.value == null
                        ? placeholder
                        : DateFormat('yyyy/MM/dd').format(date.value!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: date.value == null ? _muted : _textColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.calendar_month_outlined, size: 17, color: _primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterButton({
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 42,
      child: Material(
        color: filled ? _primary : _fieldSurface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: filled ? _primary : _border),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: filled ? Colors.white : _textColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _removeFilter() {
    selectedOrderStatus.value = '';
    selectedCategoryType.value = '';
    selectedPurposeType.value = '';
    startDate.value = null;
    endDate.value = null;

    box.write('transactiontype', '');
    box.write('category', '');
    box.write('purpose', '');
    box.write('startdate', '');
    box.write('enddate', '');
    transactionController.fetchTransactionData();
  }

  Widget _buildTransactionList() {
    return Obx(() {
      if (transactionController.isLoading.value) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator(color: _primary)),
            ),
          ],
        );
      }

      final transactions =
          transactionController
              .alltransactionlist
              .value
              .data
              ?.resellerBalanceTransactions ??
          [];

      if (transactions.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 42),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: _primary,
                      size: 27,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    languagesController.tr('NO_DATA_FOUND'),
                    style: TextStyle(
                      color: _muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      return ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 25),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, index) => _buildTransactionCard(transactions[index]),
      );
    });
  }

  Widget _buildTransactionCard(dynamic data) {
    final bool isDebit = data.status.toString().toLowerCase() == 'debit';
    final Color accent = isDebit ? _debit : _credit;
    final String resellerName = data.reseller?.resellerName?.toString() ?? '';
    final String dateText = _formatTransactionDate(data.createdAt);
    final double amount = double.tryParse(data.amount.toString()) ?? 0;
    final String currencyCode = box.read('currency_code')?.toString() ?? '';

    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: () => _showTransactionDialog(data),
        borderRadius: BorderRadius.circular(17),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: _border),
            boxShadow: _isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF25392B).withOpacity(.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // Very subtle glossy highlight. No extra row or height.
              Positioned(
                top: 1,
                left: 16,
                right: 16,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _isDark
                            ? Colors.white.withOpacity(0.07)
                            : Colors.white.withOpacity(0.9),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 11,
                ),
                child: Row(
                  // Keep the icon/name physically left and the amount/badge
                  // physically right, even when the app language is RTL.
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accent.withOpacity(_isDark ? 0.20 : 0.14),
                            accent.withOpacity(_isDark ? 0.09 : 0.055),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        isDebit
                            ? Icons.north_east_rounded
                            : Icons.south_west_rounded,
                        color: accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            resellerName,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: _textColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            dateText,
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: _muted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Text(
                                    amountFormatter.format(amount),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: _textColor,
                                    ),
                                  ),
                                  if (currencyCode.isNotEmpty) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      currencyCode,
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(_isDark ? 0.16 : 0.09),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              isDebit
                                  ? languagesController.tr('DEBIT')
                                  : languagesController.tr('CREDIT'),
                              style: TextStyle(
                                color: accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
      ),
    );
  }

  String _formatTransactionDate(dynamic createdAt) {
    if (createdAt == null || createdAt.toString().isEmpty) return '-';
    try {
      final parsedDate = DateTime.parse(createdAt.toString()).toLocal();
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (_) {
      return createdAt.toString();
    }
  }

  String _formatTransactionTime(dynamic createdAt) {
    if (createdAt == null || createdAt.toString().isEmpty) return '-';
    try {
      final parsedDate = DateTime.parse(createdAt.toString()).toLocal();
      return DateFormat('hh:mm a').format(parsedDate);
    } catch (_) {
      return '-';
    }
  }

  void _showTransactionDialog(dynamic data) {
    final bool isDebit = data.status.toString().toLowerCase() == 'debit';
    final Color accent = isDebit ? _debit : _credit;
    final String resellerName = data.reseller?.resellerName?.toString() ?? '';
    final double amount = double.tryParse(data.amount.toString()) ?? 0;
    final String currencyCode = box.read('currency_code')?.toString() ?? '';
    final String dateText = _formatTransactionDate(data.createdAt);
    final String timeText = _formatTransactionTime(data.createdAt);

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _border),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 23, 20, 20),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(_isDark ? 0.12 : 0.075),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _surface,
                            ),
                            child: Icon(
                              isDebit
                                  ? Icons.north_east_rounded
                                  : Icons.south_west_rounded,
                              color: accent,
                              size: 25,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  amountFormatter.format(amount),
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (currencyCode.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    currencyCode,
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isDebit
                                  ? languagesController.tr('DEBIT')
                                  : languagesController.tr('CREDIT'),
                              style: TextStyle(
                                color: accent,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 13, 18, 7),
                      child: Column(
                        children: [
                          _buildDialogRow(
                            icon: Icons.person_outline_rounded,
                            label: languagesController.tr('NAME'),
                            value: resellerName.isEmpty ? '-' : resellerName,
                          ),
                          _dialogDivider(),
                          _buildDialogRow(
                            icon: Icons.calendar_today_outlined,
                            label: languagesController.tr('DATE'),
                            value: dateText,
                          ),
                          _dialogDivider(),
                          _buildDialogRow(
                            icon: Icons.access_time_rounded,
                            label: languagesController.tr('TIME'),
                            value: timeText,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 5, 18, 18),
                      child: SizedBox(
                        height: 44,
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: _fieldSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            languagesController.tr('CLOSE'),
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dialogDivider() =>
      Divider(height: 18, thickness: .65, color: _border);

  Widget _buildDialogRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: _fieldSurface,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: _primary, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _textColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
