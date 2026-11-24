import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:onlinetelecom/controllers/dashboard_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Online Telecom — Account Profile.
/// Flat identity layout + distinctive financial ledger (not an intro/banner).
/// Existing dashboard bindings and the public ProfileBox API are preserved.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DashboardController dashboardController =
      Get.find<DashboardController>();
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
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _primary => AppColors.primaryColor;
  Color get _greenTint =>
      _dark ? const Color(0xFF203B2A) : const Color(0xFFEAF7EF);

  String _safeValue(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.toLowerCase() == 'null' ? '' : text;
  }

  String _moneyValue(dynamic value) {
    final currency = _safeValue(box.read('currency_code'));
    final amount = _safeValue(value);
    if (amount.isEmpty) return currency;
    if (currency.isEmpty) return amount;
    return '$amount $currency';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final dashboardData = dashboardController.alldashboardData.value.data;
      final userInfo = dashboardData?.userInfo;
      final imageUrl = _safeValue(userInfo?.profileImageUrl);
      final name = _safeValue(userInfo?.resellerName);
      final email = _safeValue(userInfo?.email);
      final phone = _safeValue(userInfo?.phone);

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
      final bottomSpacing = media.viewInsets.bottom > 0
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
                    padding: EdgeInsets.fromLTRB(16, 2, 16, bottomSpacing),
                    children: [
                      _buildIdentityPanel(
                        imageUrl: imageUrl,
                        name: name,
                        email: email,
                        phone: phone,
                      ),
                      const SizedBox(height: 22),
                      _buildFinancialTitle(),
                      const SizedBox(height: 11),
                      _buildBalanceSpotlight(_moneyValue(userInfo?.balance)),
                      const SizedBox(height: 12),
                      _buildFinancialLedger(
                        loan: _moneyValue(userInfo?.loanBalance),
                        sold: _moneyValue(dashboardData?.totalSoldAmount),
                        revenue: _moneyValue(dashboardData?.totalRevenue),
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
    required String tooltip,
    required VoidCallback onTap,
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
              languagesController.tr('PROFILE'),
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
            tooltip: _dark ? 'Light mode' : 'Dark mode',
            icon: _dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            onTap: themeController.toggleTheme,
          ),
          const SizedBox(width: 9),
          _headerButton(
            tooltip: 'Menu',
            icon: Icons.menu_rounded,
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }

  /// Unlike the old large gradient hero, this is a flat identity document
  /// with a discreet left accent and individually readable contact lines.
  Widget _buildIdentityPanel({
    required String imageUrl,
    required String name,
    required String email,
    required String phone,
  }) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .12 : .035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: _primary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 17, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildAvatar(imageUrl),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _greenTint,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Text(
                                  languagesController.tr('PROFILE'),
                                  style: TextStyle(
                                    color: _primary,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: .5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                name.isEmpty ? '—' : name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1.14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (email.isNotEmpty || phone.isNotEmpty) ...[
                      const SizedBox(height: 17),
                      Container(height: 1, color: _border),
                      const SizedBox(height: 13),
                      if (email.isNotEmpty)
                        _contactLine(Icons.mail_outline_rounded, email),
                      if (email.isNotEmpty && phone.isNotEmpty)
                        const SizedBox(height: 11),
                      if (phone.isNotEmpty)
                        _contactLine(Icons.phone_iphone_rounded, phone),
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

  Widget _buildAvatar(String url) {
    return Container(
      width: 78,
      height: 78,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _greenTint,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primary.withOpacity(.12)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: url.isEmpty
            ? _avatarFallback()
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarFallback(),
              ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: _greenTint,
      child: Icon(Icons.person_rounded, color: _primary, size: 41),
    );
  }

  Widget _contactLine(IconData icon, String value) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _greenTint,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: _primary, size: 15),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialTitle() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            languagesController.tr('BALANCE'),
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        Icon(Icons.account_balance_wallet_outlined, color: _muted, size: 19),
      ],
    );
  }

  /// Main balance is prominent but uses no large gradient hero or banner.
  Widget _buildBalanceSpotlight(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 16, 16, 17),
      decoration: BoxDecoration(
        color: _greenTint,
        border: Border.all(color: _primary.withOpacity(.17)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languagesController.tr('BALANCE'),
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value.isEmpty ? '—' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w800,
                    fontSize: 21,
                    letterSpacing: -.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_outward_rounded, color: _primary, size: 21),
        ],
      ),
    );
  }

  /// One continuous financial ledger instead of repeated independent cards.
  Widget _buildFinancialLedger({
    required String loan,
    required String sold,
    required String revenue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _ledgerLine(
            index: '01',
            icon: Icons.account_balance_outlined,
            label: languagesController.tr('LOAN_BALANCE'),
            value: loan,
            accent: const Color(0xFF8D69B3),
          ),
          _ledgerDivider(),
          _ledgerLine(
            index: '02',
            icon: Icons.receipt_long_outlined,
            label: languagesController.tr('TOTAL_SOLD_AMOUNT'),
            value: sold,
            accent: const Color(0xFF268DBB),
          ),
          _ledgerDivider(),
          _ledgerLine(
            index: '03',
            icon: Icons.trending_up_rounded,
            label: languagesController.tr('TOTAL_REVENUE'),
            value: revenue,
            accent: const Color(0xFF24A46B),
          ),
        ],
      ),
    );
  }

  Widget _ledgerDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: _border),
    );
  }

  Widget _ledgerLine({
    required String index,
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 41,
            height: 41,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withOpacity(_dark ? .15 : .09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '—' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Text(
            index,
            style: TextStyle(
              color: _muted.withOpacity(.55),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Retained for other screens importing ProfileBox from this Dart file.
/// Updated to match the same global theme and flat ledger appearance.
class ProfileBox extends StatelessWidget {
  const ProfileBox({
    super.key,
    required this.boxName,
    required this.data,
    required this.icon,
    this.highlight = false,
  });

  final String boxName;
  final String data;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ThemeController theme = Get.find<ThemeController>();
    return Obx(() {
      final dark = theme.isDarkMode.value;
      final surface = dark ? AppColors.darkCard : AppColors.lightSurface;
      final text = dark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary;
      final muted = dark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary;
      final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
      final background = highlight
          ? (dark ? const Color(0xFF203B2A) : const Color(0xFFEAF7EF))
          : surface;
      return Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(.11),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                boxName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                data,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: text,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
