import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'package:onlinetelecom/controllers/dashboard_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/helpers/money_format_helper.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Financial Report — compact ledger layout with full-width report rows.
/// No intro banner, language changer, or two-column metric grid.
/// All dashboard data bindings and money formatting are preserved.
class FinancialScreen extends StatelessWidget {
  FinancialScreen({super.key});

  final LanguagesController languagesController =
      Get.find<LanguagesController>();
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final GetStorage box = GetStorage();
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
      _dark ? const Color(0xFF1D3829) : const Color(0xFFEAF8EF);

  String _currencyCode() {
    final value = box.read('currency_code');
    final code = value?.toString().trim() ?? '';
    if (code.isEmpty || code.toLowerCase() == 'null') return '--';
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final dashboardData = dashboardController.alldashboardData.value.data;
      final currencyCode = _currencyCode();
      final formattedDate = DateFormat('dd MMM yyyy').format(DateTime.now());
      final media = MediaQuery.of(context);
      // The parent BaseScreen has an extended nav bar and raised center button.
      // Reserve its clearance inside the scrollable body, not under a footer.
      final bottomClearance = media.viewInsets.bottom > 0
          ? 24.0
          : 76.0 + 38.0 + media.viewPadding.bottom;

      final systemBars = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemBars,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: const DrawerWidget(),
          backgroundColor: _background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16, 3, 16, bottomClearance),
                    children: [
                      _buildBalanceSummary(
                        balance:
                            dashboardController.userBalanceController.balance,
                        currencyCode: currencyCode,
                        formattedDate: formattedDate,
                      ),
                      const SizedBox(height: 24),
                      _buildReportHeading(),
                      const SizedBox(height: 12),
                      _buildLedger(
                        currencyCode: currencyCode,
                        totalSoldAmount: dashboardData?.totalSoldAmount,
                        totalRevenue: dashboardData?.totalRevenue,
                        loanBalance: dashboardData?.loanBalance,
                        commission: dashboardData?.userInfo?.totalearning,
                      ),
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
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: _text, size: 21),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 15),
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
              languagesController.tr('FINANCIAL_REPORT'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _headerButton(
            icon: _dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            onTap: themeController.toggleTheme,
            tooltip: _dark ? 'Light mode' : 'Dark mode',
          ),
          const SizedBox(width: 9),
          _headerButton(
            icon: Icons.menu_rounded,
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            tooltip: 'Menu',
          ),
        ],
      ),
    );
  }

  /// A quiet, information-first balance summary (not a decorative intro card).
  Widget _buildBalanceSummary({
    required dynamic balance,
    required String currencyCode,
    required String formattedDate,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .06 : .025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 5,
            height: 103,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF16A34A), Color(0xFF0D7C3B)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 33,
                      height: 33,
                      decoration: BoxDecoration(
                        color: _softGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 18,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        languagesController.tr('BALANCE'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  formatMoney(balance),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _text,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.7,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyCode,
                  style: TextStyle(
                    color: _accent,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportHeading() {
    return Row(
      children: [
        Container(
          height: 22,
          width: 4,
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            languagesController.tr('FINANCIAL_REPORT'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// Rows are intentionally sequential and full-width (not a grid).
  Widget _buildLedger({
    required String currencyCode,
    required dynamic totalSoldAmount,
    required dynamic totalRevenue,
    required dynamic loanBalance,
    required dynamic commission,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .055 : .018),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _ledgerRow(
            icon: Icons.shopping_bag_outlined,
            label: languagesController.tr('SALE'),
            value: totalSoldAmount,
            currencyCode: currencyCode,
            color: const Color(0xFF159957),
          ),
          _rowDivider(),
          _ledgerRow(
            icon: Icons.call_made_rounded,
            label: languagesController.tr('DEBIT'),
            // Preserve the original screen's data source for Debit.
            value: totalSoldAmount,
            currencyCode: currencyCode,
            color: const Color(0xFF4B8EC9),
          ),
          _rowDivider(),
          _ledgerRow(
            icon: Icons.trending_up_rounded,
            label: languagesController.tr('PROFIT'),
            value: totalRevenue,
            currencyCode: currencyCode,
            color: const Color(0xFF12A67A),
          ),
          _rowDivider(),
          _ledgerRow(
            icon: Icons.account_balance_outlined,
            label: languagesController.tr('LOAN_BALANCE'),
            value: loanBalance,
            currencyCode: currencyCode,
            color: const Color(0xFF9B70C5),
          ),
          _rowDivider(),
          _ledgerRow(
            icon: Icons.workspace_premium_outlined,
            label: languagesController.tr('COMISSION'),
            value: commission,
            currencyCode: currencyCode,
            color: const Color(0xFFD39032),
          ),
        ],
      ),
    );
  }

  Widget _rowDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 70, right: 17),
      child: Divider(height: 1, thickness: 1, color: _border),
    );
  }

  Widget _ledgerRow({
    required IconData icon,
    required String label,
    required dynamic value,
    required String currencyCode,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(_dark ? .18 : .09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 13,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatMoney(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  currencyCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: color,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
