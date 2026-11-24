import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:onlinetelecom/controllers/change_status_controller.dart';
import 'package:onlinetelecom/controllers/commission_group_controller.dart';
import 'package:onlinetelecom/controllers/dashboard_controller.dart';
import 'package:onlinetelecom/controllers/delete_sub_resellercontroller.dart';
import 'package:onlinetelecom/controllers/drawer_controller.dart';
import 'package:onlinetelecom/controllers/set_commission_group_controller.dart';
import 'package:onlinetelecom/controllers/sub_reseller_controller.dart';
import 'package:onlinetelecom/controllers/subreseller_details_controller.dart';
import 'package:onlinetelecom/global_controller/font_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/screens/add_new_user.dart';
import 'package:onlinetelecom/screens/change_balance.dart';
import 'package:onlinetelecom/screens/set_password.dart';
import 'package:onlinetelecom/screens/set_subreseller_pin.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/contact_dialogbox.dart';
import 'package:onlinetelecom/widgets/custom_text.dart';
import 'package:onlinetelecom/widgets/drawer.dart';
import 'package:onlinetelecom/widgets/logoutbox.dart';

class Network extends StatefulWidget {
  const Network({super.key});

  @override
  State<Network> createState() => _NetworkState();
}

// Retain the public controller references exposed by the original screen.
final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
final SubresellerController subresellercontroller =
    Get.find<SubresellerController>();
final LanguagesController languagesController = Get.put(LanguagesController());
final SubresellerDetailsController detailsController =
    Get.find<SubresellerDetailsController>();
final DeleteSubResellerController deleteSubResellerController = Get.put(
  DeleteSubResellerController(),
);
final ChangeStatusController changeStatusController = Get.put(
  ChangeStatusController(),
);
final CommissionGroupController commissionlistController =
    Get.find<CommissionGroupController>();
final SetCommissionGroupController commissionGroupController = Get.put(
  SetCommissionGroupController(),
);

class _NetworkState extends State<Network> {
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final MyDrawerController drawerController = Get.put(MyDrawerController());

  final GetStorage box = GetStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController phoneSearchController = TextEditingController();
  final TextEditingController nameSearchController = TextEditingController();

  String? _expandedResellerId;

  // Reading the shared ThemeController directly keeps this page in sync even
  // when its parent route does not immediately rebuild its inherited ThemeData.
  bool get _dark => themeController.isDarkMode.value;
  Color get _background =>
      _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _surface => _dark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get _surfaceRaised => _dark ? AppColors.darkCard : Colors.white;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _accent => AppColors.primaryColor;
  Color get _subtleGreen =>
      _dark ? const Color(0xFF1E3628) : const Color(0xFFEAF8EF);

  @override
  void initState() {
    super.initState();
    phoneSearchController.addListener(_updateSearch);
    nameSearchController.addListener(_updateSearch);
    subresellercontroller.fetchSubReseller();
    commissionlistController.fetchGrouplist();
  }

  void _updateSearch() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    phoneSearchController.removeListener(_updateSearch);
    nameSearchController.removeListener(_updateSearch);
    phoneSearchController.dispose();
    nameSearchController.dispose();
    super.dispose();
  }

  Future<void> _refreshNetwork() async {
    subresellercontroller.fetchSubReseller();
    commissionlistController.fetchGrouplist();
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  @override
  Widget build(BuildContext context) {
    // The entire screen observes the saved/shared GetX theme flag. This also
    // updates the system bars, not just individual card colors.
    return Obx(() {
      final isDarkMode = themeController.isDarkMode.value;
      final overlay = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDarkMode
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        systemNavigationBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
      );

      final deactivated =
          dashboardController.deactiveStatus.value.trim().toLowerCase() ==
          'deactivated';

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay,
        child: deactivated
            ? _buildDeactivatedScreen()
            : Scaffold(
                key: _scaffoldKey,
                drawer: const DrawerWidget(),
                backgroundColor: _background,
                resizeToAvoidBottomInset: true,
                body: SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildControlBlock(),
                      const SizedBox(height: 14),
                      Expanded(
                        child: RefreshIndicator(
                          color: _accent,
                          onRefresh: _refreshNetwork,
                          child: _buildNetworkList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    });
  }

  // Header sizing, spacing and ordering match the Orders screen.
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
              tooltip: 'Menu',
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              icon: Icon(Icons.menu_rounded, size: 22, color: _text),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      languagesController.tr('NETWORK'),
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
                  const SizedBox(width: 7),
                  Obx(() {
                    final resellers =
                        subresellercontroller
                            .allsubresellerData
                            .value
                            .data
                            ?.resellers ??
                        [];
                    final count = resellers.length;
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(.10),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _accent,
                        ),
                      ),
                    );
                  }),
                ],
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
            _profileAvatar(),
          ],
        ),
      ),
    );
  }

  Widget _profileAvatar() {
    return Obx(() {
      final url =
          dashboardController
              .alldashboardData
              .value
              .data
              ?.userInfo
              ?.profileImageUrl
              ?.toString() ??
          '';
      final hasPhoto = url.isNotEmpty && url != 'null';

      return Container(
        width: 40,
        height: 40,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _accent.withOpacity(.11),
          border: Border.all(color: _accent.withOpacity(.22), width: 1.5),
        ),
        child: hasPhoto
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.person_rounded, size: 24, color: _accent),
              )
            : Icon(Icons.person_rounded, size: 24, color: _accent),
      );
    });
  }

  Widget _buildControlBlock() {
    // A compact "search + create" cockpit, not a large add-user banner.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: _surfaceRaised,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_dark ? .09 : .027),
              blurRadius: 20,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _searchField(
                      controller: nameSearchController,
                      hint: languagesController.tr('SEARCH_BY_NAME'),
                      icon: Icons.person_search_outlined,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 7),
                    _searchField(
                      controller: phoneSearchController,
                      hint: languagesController.tr('SEARCH_BY_PHOENUMBER'),
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => mypagecontroller.changePage(
                    AddNewUser(),
                    isMainPage: false,
                  ),
                  borderRadius: BorderRadius.circular(17),
                  child: Ink(
                    width: 99,
                    height: 91,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF16A34A), Color(0xFF0B7636)],
                      ),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 32,
                          width: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white.withOpacity(.20),
                            border: Border.all(
                              color: Colors.white.withOpacity(.18),
                            ),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: NText(
                              text: languagesController.tr('ADD_USER'),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    final usePersianFont = box.read('language')?.toString() == 'Fa';
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: _dark ? AppColors.darkInputBackground : const Color(0xFFF6FAF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 9),
          Icon(icon, size: 17, color: _accent),
          const SizedBox(width: 7),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: _accent,
              style: TextStyle(
                color: _text,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                fontFamily: usePersianFont
                    ? Get.find<FontController>().currentFont
                    : null,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintMaxLines: 1,
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(
                  color: _muted,
                  fontSize: 11.5,
                  fontFamily: usePersianFont
                      ? Get.find<FontController>().currentFont
                      : null,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            InkWell(
              onTap: controller.clear,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Icon(Icons.close_rounded, size: 16, color: _muted),
              ),
            ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildNetworkList() {
    return Obx(() {
      if (subresellercontroller.isLoading.value) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator(color: _accent)),
            ),
          ],
        );
      }

      final resellers =
          subresellercontroller.allsubresellerData.value.data?.resellers ?? [];
      final nameQuery = nameSearchController.text.trim().toLowerCase();
      final phoneQuery = phoneSearchController.text.trim().toLowerCase();
      final filtered = resellers.where((data) {
        final name = data.contactName?.toString().toLowerCase() ?? '';
        final phone = data.phone?.toString().toLowerCase() ?? '';
        return name.contains(nameQuery) && phone.contains(phoneQuery);
      }).toList();

      if (filtered.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 45),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: _subtleGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.people_alt_outlined,
                      color: _accent,
                      size: 29,
                    ),
                  ),
                  const SizedBox(height: 13),
                  NText(
                    text: languagesController.tr('NO_DATA_FOUND'),
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.fromLTRB(16, 3, 16, 28),
        itemCount: filtered.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(3, 0, 3, 4),
              child: Row(
                children: [
                  Container(
                    height: 18,
                    width: 3,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NText(
                      text: languagesController.tr('NETWORK'),
                      color: _muted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _subtleGreen,
                    ),
                    child: Text(
                      '${filtered.length}',
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
          return _buildResellerCard(filtered[index - 1]);
        },
      );
    });
  }

  Widget _buildResellerCard(dynamic data) {
    final id = data.id?.toString() ?? '';
    final isExpanded = _expandedResellerId == id;
    final isActive = data.status.toString() == '1';
    final statusColor = isActive
        ? const Color(0xFF14A34A)
        : const Color(0xFFDB5264);
    final imageUrl = data.profileImageUrl?.toString() ?? '';
    final name = data.contactName?.toString() ?? '';
    final phone = data.phone?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: _surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? _accent.withOpacity(.40) : _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .10 : .022),
            blurRadius: 11,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedResellerId = null;
                    } else {
                      _expandedResellerId = id;
                      detailsController.fetchSubResellerDetails(id);
                    }
                  });
                },
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      Container(
                        height: 66,
                        width: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [statusColor, statusColor.withOpacity(.33)],
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Container(
                        width: 41,
                        height: 41,
                        decoration: BoxDecoration(
                          color: _subtleGreen,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: imageUrl.isNotEmpty && imageUrl != 'null'
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _resellerPlaceholder(),
                                )
                              : _resellerPlaceholder(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NText(
                              text: name,
                              color: _text,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone_rounded,
                                  size: 12,
                                  color: _muted,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: NText(
                                    text: phone,
                                    color: _muted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 6,
                            width: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          NText(
                            text: isActive
                                ? languagesController.tr('ACTIVE')
                                : languagesController.tr('DEACTIVE'),
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            maxLines: 1,
                          ),
                        ],
                      ),
                      const SizedBox(width: 7),
                      InkWell(
                        onTap: () => _showActionDialog(data),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: _subtleGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.more_horiz_rounded,
                            size: 21,
                            color: _accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 220),
                        turns: isExpanded ? .5 : 0,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _muted,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 7),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        children: [
                          Divider(height: 18, color: _border),
                          _buildExpandedDetails(),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resellerPlaceholder() => Container(
    alignment: Alignment.center,
    color: _subtleGreen,
    child: Icon(Icons.person_rounded, size: 24, color: _accent),
  );

  Widget _buildExpandedDetails() {
    return Obx(() {
      if (detailsController.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator(color: _accent)),
        );
      }
      final reseller =
          detailsController.allsubresellerDetailsData.value.data?.reseller;
      if (reseller == null) return const SizedBox();
      final currency = box.read('currency_code')?.toString() ?? '';

      return Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 7,
            crossAxisSpacing: 7,
            childAspectRatio: 2.48,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _statCard(
                languagesController.tr('TODAY_ORDER'),
                reseller.todayOrders.toString(),
                Icons.today_outlined,
                const Color(0xFF4B7FE1),
              ),
              _statCard(
                languagesController.tr('TOTAL_ORDER'),
                reseller.totalOrders.toString(),
                Icons.receipt_long_outlined,
                const Color(0xFF8C61D9),
              ),
              _statCard(
                languagesController.tr('TOTAL_SALE'),
                '${reseller.totalSale} $currency',
                Icons.trending_up_rounded,
                const Color(0xFF16A34A),
              ),
              _statCard(
                languagesController.tr('TODAY_SALE'),
                '${reseller.todaySale} $currency',
                Icons.payments_outlined,
                const Color(0xFF1C9BAA),
              ),
              _statCard(
                languagesController.tr('TOTAL_PROFIT'),
                '${reseller.totalProfit} $currency',
                Icons.stacked_line_chart,
                const Color(0xFFD09123),
              ),
              _statCard(
                languagesController.tr('TODAY_PROFIT'),
                '${reseller.todayProfit} $currency',
                Icons.auto_graph_rounded,
                const Color(0xFFE27391),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF177A40), Color(0xFF159F4A)],
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NText(
                    text: languagesController.tr('ACCOUNT_BALANCE'),
                    color: Colors.white.withOpacity(.86),
                    fontSize: 11.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Flexible(
                  child: NText(
                    text: '${reseller.balance} $currency',
                    color: Colors.white,
                    fontSize: 13.3,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _dark ? AppColors.darkInputBackground : const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            height: 29,
            width: 29,
            decoration: BoxDecoration(
              color: color.withOpacity(.13),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NText(
                  text: label,
                  color: _muted,
                  fontSize: 9.2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                NText(
                  text: value,
                  color: _text,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showActionDialog(dynamic data) {
    final isActive = data.status.toString() == '1';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 15),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * .87,
          ),
          decoration: BoxDecoration(
            color: _surfaceRaised,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: _border),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 39,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: _subtleGreen,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.manage_accounts_rounded,
                        size: 22,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NText(
                            text: data.contactName?.toString() ?? '',
                            color: _text,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          NText(
                            text: data.phone?.toString() ?? '',
                            color: _muted,
                            fontSize: 11.5,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: Icon(Icons.close_rounded, color: _muted),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                _actionTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: languagesController.tr('CHANGE_BALANCE'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    mypagecontroller.changePage(
                      ChangeBalance(subID: data.id.toString()),
                      isMainPage: false,
                    );
                  },
                ),
                _actionTile(
                  icon: Icons.lock_reset_rounded,
                  title: languagesController.tr('SET_PASSWORD'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    mypagecontroller.changePage(
                      SetPassword(subID: data.id.toString()),
                      isMainPage: false,
                    );
                  },
                ),
                _actionTile(
                  icon: Icons.percent_rounded,
                  title: languagesController.tr('SET_COMMISSION_GROUP'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showCommissionGroups(data);
                  },
                ),
                _actionTile(
                  icon: Icons.password_rounded,
                  title: languagesController.tr('SET_PIN'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    mypagecontroller.changePage(
                      SetSubresellerPin(subID: data.id.toString()),
                      isMainPage: false,
                    );
                  },
                ),
                _actionTile(
                  icon: isActive
                      ? Icons.pause_circle_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  title: isActive
                      ? languagesController.tr('DEACTIVE')
                      : languagesController.tr('ACTIVE'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    changeStatusController.channgestatus(data.id.toString());
                  },
                ),
                _actionTile(
                  icon: Icons.delete_outline_rounded,
                  title: languagesController.tr('DELETE'),
                  isDanger: true,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    deleteSubResellerController.deletesub(data.id.toString());
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 43,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: NText(
                      text: languagesController.tr('CLOSE'),
                      color: _text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final color = isDanger ? const Color(0xFFE05263) : _accent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isDanger
            ? (_dark ? const Color(0xFF311C23) : const Color(0xFFFFF3F4))
            : (_dark ? AppColors.darkInputBackground : const Color(0xFFF8FBF9)),
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            height: 49,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: isDanger ? color.withOpacity(.15) : _border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: color.withOpacity(.12),
                  ),
                  child: Icon(icon, color: color, size: 19),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: NText(
                    text: title,
                    color: isDanger ? color : _text,
                    fontSize: 12.7,
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDanger ? color : _muted,
                  size: 19,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCommissionGroups(dynamic data) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * .76,
          ),
          decoration: BoxDecoration(
            color: _surfaceRaised,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),
              NText(
                text: languagesController.tr('SET_COMMISSION_GROUP'),
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              const SizedBox(height: 14),
              Flexible(
                child: Obx(() {
                  if (commissionlistController.isLoading.value) {
                    return SizedBox(
                      height: 175,
                      child: Center(
                        child: CircularProgressIndicator(color: _accent),
                      ),
                    );
                  }
                  final groups =
                      commissionlistController
                          .allgrouplist
                          .value
                          .data
                          ?.groups ??
                      [];
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 7),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      final selected =
                          data.subResellerCommissionGroupId.toString() ==
                          group.id.toString();
                      return Material(
                        color: selected ? _subtleGreen : _surface,
                        borderRadius: BorderRadius.circular(13),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(13),
                          onTap: () async {
                            Navigator.pop(sheetContext);
                            await commissionGroupController.setgroup(
                              data.id.toString(),
                              group.id.toString(),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: selected
                                    ? _accent.withOpacity(.33)
                                    : _border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  selected
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  color: selected ? _accent : _muted,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      NText(
                                        text: group.groupName ?? '',
                                        color: _text,
                                        fontSize: 12.7,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      const SizedBox(height: 3),
                                      NText(
                                        text:
                                            '${group.amount} ${group.commissionType == 'percentage' ? '%' : ''}',
                                        color: _muted,
                                        fontSize: 11,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: _muted,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildDeactivatedScreen() {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: const Color(0xFFDF5666).withOpacity(.12),
                  ),
                  child: const Icon(
                    Icons.block_rounded,
                    color: Color(0xFFDF5666),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 17),
                NText(
                  text: dashboardController.deactiveStatus.toString(),
                  color: _text,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                NText(
                  text: dashboardController.deactivateMessage.toString(),
                  color: _muted,
                  fontSize: 13,
                  textAlign: TextAlign.center,
                  height: 1.45,
                ),
                const SizedBox(height: 23),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          contentPadding: EdgeInsets.zero,
                          content: const ContactDialogBox(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                    ),
                    label: NText(
                      text: languagesController.tr('CONTACTUS'),
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        content: LogoutDialogBox(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                    );
                  },
                  child: NText(
                    text: languagesController.tr('LOGOUT'),
                    color: const Color(0xFFDF5666),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
