import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import 'package:onlinetelecom/controllers/company_controller.dart';
import 'package:onlinetelecom/controllers/conversation_controller.dart';
import 'package:onlinetelecom/controllers/currency_controller.dart';
import 'package:onlinetelecom/controllers/custom_history_controller.dart';
import 'package:onlinetelecom/controllers/custom_recharge_controller.dart';
import 'package:onlinetelecom/controllers/dashboard_controller.dart';
import 'package:onlinetelecom/controllers/recharge_config_controller.dart';
import 'package:onlinetelecom/global_controller/afghan_recharge_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Afghanistan Recharge / Credit Transfer.
/// Theme-aware UI with one scrollable body (form + paginated history).
/// The existing recharge, conversion, company matching and order APIs remain.
class CreditTransfer extends StatefulWidget {
  const CreditTransfer({super.key});

  @override
  State<CreditTransfer> createState() => _CreditTransferState();
}

class _CreditTransferState extends State<CreditTransfer> {
  final CustomHistoryController customhistoryController =
      Get.find<CustomHistoryController>();
  final CurrencyController currencyController = Get.find<CurrencyController>();
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final CustomRechargeController customRechargeController = Get.put(
    CustomRechargeController(),
  );
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final CompanyController companyController = Get.find<CompanyController>();
  final ConversationController conversationController = Get.put(
    ConversationController(),
  );
  final AfghanRechargeController controller =
      Get.find<AfghanRechargeController>();
  final RechargeConfigController configController =
      Get.find<RechargeConfigController>();
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final ThemeController themeController = Get.find<ThemeController>();
  final GetStorage box = GetStorage();
  final ScrollController scrollController = ScrollController();
  final RxList<bool> expandedIndices = <bool>[].obs;
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
      _dark ? const Color(0xFF1C3728) : const Color(0xFFEAF8EF);

  @override
  void initState() {
    super.initState();

    // Original screen's initialization and fetch sequence.
    configController.fetchrechargeConfig();
    controller.reset();
    conversationController.resetConversion();
    customRechargeController.amountController.clear();
    customRechargeController.numberController.clear();
    currencyController.fetchCurrencyList();
    customhistoryController.finalList.clear();
    customhistoryController.initialpage = 1;
    customhistoryController.fetchHistory();

    scrollController.addListener(_loadMoreHistory);
    customRechargeController.numberController.addListener(
      _matchCompanyFromPhone,
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(_loadMoreHistory);
    scrollController.dispose();
    customRechargeController.numberController.removeListener(
      _matchCompanyFromPhone,
    );
    super.dispose();
  }

  void _matchCompanyFromPhone() {
    companyController.matchCompanyByPhoneNumber(
      customRechargeController.numberController.text,
    );
  }

  void _loadMoreHistory() {
    if (!scrollController.hasClients ||
        customhistoryController.isLoading.value) {
      return;
    }
    final pagination =
        customhistoryController.allorderlist.value.payload?.pagination;
    final totalPages = pagination?.totalPages ?? 0;
    final currentPage = customhistoryController.initialpage;
    if (totalPages <= 0 || currentPage >= totalPages) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 80) {
      customhistoryController.initialpage++;
      customhistoryController.fetchHistory();
    }
  }

  Future<void> _refreshHistory() async {
    expandedIndices.clear();
    customhistoryController.finalList.clear();
    customhistoryController.initialpage = 1;
    customhistoryController.fetchHistory();
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final media = MediaQuery.of(context);
      // BaseScreen draws a floating center action and a 76px navigation bar.
      // Keep the final history row scrollable above these overlays.
      final bottomClearance = media.viewInsets.bottom > 0
          ? 24.0
          : 76.0 + 38.0 + media.viewPadding.bottom;
      final overlay = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
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
                  child: RefreshIndicator(
                    color: _accent,
                    onRefresh: _refreshHistory,
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
                          sliver: SliverToBoxAdapter(
                            child: _buildRechargeForm(),
                          ),
                        ),
                        SliverToBoxAdapter(child: _buildHistoryHeading()),
                        _buildHistorySliver(),
                        SliverToBoxAdapter(
                          child: SizedBox(height: bottomClearance),
                        ),
                      ],
                    ),
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
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(14),
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
            onTap: mypagecontroller.goBack,
            tooltip: 'Back',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              languagesController.tr('AFGHANISTAN_RECHARGE'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 16, // All Online Telecom page headers: 16px.
                fontWeight: FontWeight.w800,
                letterSpacing: -.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => _headerButton(
              icon: themeController.isDarkMode.value
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              onTap: themeController.toggleTheme,
              tooltip: themeController.isDarkMode.value
                  ? 'Light mode'
                  : 'Dark mode',
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
    );
  }

  Widget _buildRechargeForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 15),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .06 : .025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Small contextual flag, not an intro/hero card.
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/afnflag.jpg',
                  width: 46,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 46,
                    height: 32,
                    alignment: Alignment.center,
                    color: _softGreen,
                    child: Icon(Icons.flag_outlined, color: _accent, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  languagesController.tr('AFGHANISTAN_RECHARGE'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _softGreen,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  'AFN',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildPhoneField(),
          const SizedBox(height: 10),
          _buildAmountField(),
          const SizedBox(height: 12),
          _buildPriceCards(),
          const SizedBox(height: 14),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      height: 53,
      decoration: BoxDecoration(
        color: _input,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.phone_outlined, color: _accent, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: customRechargeController.numberController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              cursorColor: _accent,
              style: TextStyle(
                color: _text,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
              decoration: _inputDecoration(
                languagesController.tr('PHONENUMBER'),
                hideCounter: true,
              ),
            ),
          ),
          Obx(() {
            final company = companyController.matchedCompany.value;
            final logo = company?.companyLogo ?? '';
            return Container(
              width: 39,
              height: 39,
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: _softGreen,
                borderRadius: BorderRadius.circular(11),
              ),
              child: logo.trim().isEmpty
                  ? Icon(Icons.sim_card_outlined, color: _accent, size: 20)
                  : Image.network(
                      logo,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.sim_card_outlined,
                        color: _accent,
                        size: 20,
                      ),
                    ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      height: 53,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _input,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(Icons.payments_outlined, color: _accent, size: 19),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: customRechargeController.amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: controller.calculate,
              cursorColor: _accent,
              style: TextStyle(
                color: _text,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
              decoration: _inputDecoration(languagesController.tr('AMOUNT')),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: _softGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'AFN',
              style: TextStyle(
                color: _accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {bool hideCounter = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _muted, fontSize: 12.5),
      counterText: hideCounter ? '' : null,
      isDense: true,
      filled: false,
      fillColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
    );
  }

  Widget _buildPriceCards() {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _priceCard(
              title: languagesController.tr('BUYING'),
              value: controller.buyingPrice.value.toStringAsFixed(2),
              icon: Icons.south_east_rounded,
              accent: const Color(0xFFE0A51B),
              softColor: _dark
                  ? const Color(0xFF42361E)
                  : const Color(0xFFFFF6DA),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _priceCard(
              title: languagesController.tr('SELLING'),
              value: controller.sellingPrice.value.toStringAsFixed(2),
              icon: Icons.north_east_rounded,
              accent: const Color(0xFF25B66E),
              softColor: _dark
                  ? const Color(0xFF1E4130)
                  : const Color(0xFFECF9F2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accent,
    required Color softColor,
  }) {
    final currency = box.read('currency_symbol')?.toString() ?? '';
    return Container(
      constraints: const BoxConstraints(minHeight: 83),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: _input,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 23,
                width: 23,
                decoration: BoxDecoration(
                  color: softColor,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, color: accent, size: 14),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (currency.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              currency,
              style: TextStyle(
                color: _muted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 51,
      child: ElevatedButton(
        onPressed: _submitRecharge,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.send_rounded, size: 18),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                languagesController.tr('SEND_TO_DESTINATION'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRecharge() {
    if (customRechargeController.numberController.text.isEmpty ||
        customRechargeController.amountController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: languagesController.tr('ENTER_REQUIRED_DATA'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16,
      );
      return;
    }
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: _surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(19, 21, 19, 19),
          child: Obx(() {
            if (customRechargeController.isLoading.value) {
              return SizedBox(
                height: 230,
                child: Center(
                  child: Lottie.asset(
                    'assets/loties/recharge.json',
                    height: 170,
                  ),
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _softGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.send_rounded, color: _accent, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  languagesController.tr('ARE_YOU_SURE_TO_TRANSFER'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 21),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 47,
                        child: ElevatedButton(
                          onPressed: () => customRechargeController.placeOrder(
                            dialogContext,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: Text(
                            languagesController.tr('CONFIRMATION'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 47,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _text,
                            side: BorderSide(color: _border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: Text(
                            languagesController.tr('CANCEL'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHistoryHeading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _softGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.history_rounded, color: _accent, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              languagesController.tr('HISTORY'),
              style: TextStyle(
                color: _text,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          InkWell(
            onTap: () => _refreshHistory(),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Icon(Icons.refresh_rounded, color: _accent, size: 21),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySliver() {
    return Obx(() {
      final list = customhistoryController.finalList;
      final loading = customhistoryController.isLoading.value;

      if (loading && list.isEmpty) {
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 155,
            child: Center(child: CircularProgressIndicator(color: _accent)),
          ),
        );
      }

      if (list.isEmpty) {
        return SliverToBoxAdapter(
          child: Container(
            height: 175,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: _softGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history_toggle_off_rounded,
                    color: _accent,
                    size: 27,
                  ),
                ),
                const SizedBox(height: 11),
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
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index == list.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Center(child: CircularProgressIndicator(color: _accent)),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _buildHistoryCard(list[index], index),
            );
          }, childCount: list.length + (loading ? 1 : 0)),
        ),
      );
    });
  }

  Widget _buildHistoryCard(dynamic data, int index) {
    final status = data.status.toString();
    final Color statusColor = status == '0'
        ? const Color(0xFFE0A51B)
        : status == '1'
        ? const Color(0xFF23B26D)
        : const Color(0xFFE05263);
    final Color statusSoftColor = status == '0'
        ? (_dark ? const Color(0xFF3D321D) : const Color(0xFFFFF6DA))
        : status == '1'
        ? (_dark ? const Color(0xFF1C3D2C) : const Color(0xFFECF9F2))
        : (_dark ? const Color(0xFF44272F) : const Color(0xFFFFF0F2));
    final statusText = status == '0'
        ? languagesController.tr('PENDING')
        : status == '1'
        ? languagesController.tr('SUCCESS')
        : languagesController.tr('REJECTED');
    final createdAt = DateTime.tryParse(data.createdAt.toString());
    final String companyLogo =
        data.bundle?.service?.company?.companyLogo?.toString() ?? '';
    final validLogo = companyLogo != 'null' && companyLogo.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .045 : .02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey('credit_transfer_history_$index'),
          initiallyExpanded: index < expandedIndices.length
              ? expandedIndices[index]
              : false,
          onExpansionChanged: (expanded) {
            if (index >= expandedIndices.length) {
              expandedIndices.addAll(
                List<bool>.filled(index + 1 - expandedIndices.length, false),
              );
            }
            expandedIndices[index] = expanded;
          },
          iconColor: _accent,
          collapsedIconColor: _muted,
          tilePadding: const EdgeInsets.fromLTRB(11, 2, 9, 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: _softGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: validLogo
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.network(
                      companyLogo,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.sim_card_outlined,
                        color: _accent,
                        size: 22,
                      ),
                    ),
                  )
                : Icon(Icons.sim_card_outlined, color: _accent, size: 22),
          ),
          title: Text(
            data.bundle?.bundleTitle?.toString() ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              data.rechargebleAccount?.toString() ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: statusSoftColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _input,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                children: [
                  _historyDetailRow(
                    languagesController.tr('TRANSFER_STATUS'),
                    statusText,
                    valueColor: statusColor,
                  ),
                  const SizedBox(height: 10),
                  _historyDetailRow(
                    languagesController.tr('AMOUNT'),
                    '${data.bundle?.amount ?? ''} ${box.read('currency_code') ?? ''}',
                  ),
                  const SizedBox(height: 10),
                  _historyDetailRow(
                    languagesController.tr('DATE'),
                    createdAt == null
                        ? ''
                        : DateFormat('yyyy-MM-dd').format(createdAt),
                  ),
                  const SizedBox(height: 10),
                  _historyDetailRow(
                    languagesController.tr('TIME'),
                    createdAt == null
                        ? ''
                        : DateFormat('hh:mm a').format(createdAt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor ?? _text,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
