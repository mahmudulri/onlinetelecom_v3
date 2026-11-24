import 'dart:async';
import 'package:onlinetelecom/controllers/bundle_controller.dart';
import 'package:onlinetelecom/controllers/service_controller.dart';
import 'package:onlinetelecom/controllers/categories_controller.dart';
import 'package:onlinetelecom/controllers/company_controller.dart';
import 'package:onlinetelecom/controllers/conversation_controller.dart';
import 'package:onlinetelecom/controllers/country_list_controller.dart';
import 'package:onlinetelecom/controllers/custom_recharge_controller.dart';
import 'package:onlinetelecom/controllers/dashboard_controller.dart';
import 'package:onlinetelecom/controllers/drawer_controller.dart';
import 'package:onlinetelecom/controllers/notifications_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/models/country_list_model.dart';
import 'package:onlinetelecom/pages/notification_details_page.dart';
import 'package:onlinetelecom/screens/all_notifications_page.dart';
import 'package:onlinetelecom/screens/commission_transfer_screen.dart';
import 'package:onlinetelecom/screens/country_selection.dart';
import 'package:onlinetelecom/screens/credit_transfer.dart';
import 'package:onlinetelecom/screens/financial_screen.dart';
import 'package:onlinetelecom/screens/hawala_list_screen.dart';
import 'package:onlinetelecom/screens/hawala_rates_screen.dart';
import 'package:onlinetelecom/screens/loan_screen.dart';
import 'package:onlinetelecom/screens/receipts_screen.dart';
import 'package:onlinetelecom/screens/recharge_screen.dart';
import 'package:onlinetelecom/screens/service_screen.dart';
import 'package:onlinetelecom/screens/withdraw_screen.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/widgets/accounting_pin_pad.dart';
import 'package:onlinetelecom/widgets/contact_dialogbox.dart';
import 'package:onlinetelecom/widgets/custom_text.dart';
import 'package:onlinetelecom/widgets/logoutbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import '../models/service_category_model.dart';
import '../widgets/drawer.dart';

class Homepages extends StatefulWidget {
  const Homepages({super.key});

  @override
  State<Homepages> createState() => _HomepagesState();
}

class _HomepagesState extends State<Homepages> {
  final DashboardController dashboardController = Get.put(
    DashboardController(),
  );

  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );

  final MyDrawerController drawerController = Get.put(MyDrawerController());

  final NotificationController notificationController = Get.put(
    NotificationController(),
  );

  final CountryListController countryListController = Get.put(
    CountryListController(),
  );

  final CategorisListController categorisListController =
      Get.find<CategorisListController>();

  final CompanyController companyController = Get.find<CompanyController>();

  final ConversationController conversationController = Get.put(
    ConversationController(),
  );

  final CustomRechargeController customRechargeController = Get.put(
    CustomRechargeController(),
  );

  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();

  final GetStorage box = GetStorage();

  final ThemeController themeController = Get.find<ThemeController>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Dashboard API advertisements: no extra request/controller is needed.
  final PageController _advertisementPageController = PageController();
  Timer? _advertisementTimer;
  int _currentAdvertisementIndex = 0;

  final NumberFormat _balanceFormatter = NumberFormat.currency(
    locale: 'en_US',

    symbol: '',

    decimalDigits: 2,
  );

  final List<Color> serviceIconBackgrounds = const [
    Color(0xFFF2ECFF),

    Color(0xFFFFECEC),

    Color(0xFFEAF2FF),

    Color(0xFFE8F8F2),

    Color(0xFFE8FAFC),

    Color(0xFFFFF4DC),
  ];

  final List<String> fallbackServiceIcons = const [
    "assets/icons/credit-transfer.png",

    "assets/icons/social-bundles.png",
    "assets/icons/credit-transfer.png",

    "assets/icons/credit-transfer.png",

    "assets/icons/social-bundles.png",
  ];

  @override
  void initState() {
    super.initState();

    _checkForUpdate();

    notificationController.fetchData();

    companyController.fetchCompany();

    countryListController.fetchCountryData();

    dashboardController.fetchDashboardData();

    categorisListController.fetchcategories();

    // Advance only when multiple valid banners are present.
    _advertisementTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_advertisementPageController.hasClients) return;

      final banners =
          dashboardController
              .alldashboardData
              .value
              .data
              ?.advertisementSliders ??
          [];
      final validCount = banners.where((banner) {
        final url = banner.adSliderImageUrl?.trim() ?? '';
        return url.isNotEmpty && url.toLowerCase() != 'null';
      }).length;
      if (validCount < 2) return;

      final visiblePage = _advertisementPageController.page?.round() ?? 0;
      final nextPage = (visiblePage + 1) % validCount;
      _advertisementPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _advertisementTimer?.cancel();
    _advertisementPageController.dispose();
    super.dispose();
  }

  Future<void> _checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await _update();
      }
    } catch (error) {
      debugPrint("Update check error: $error");
    }
  }

  Future<void> _update() async {
    try {
      await InAppUpdate.startFlexibleUpdate();

      await InAppUpdate.completeFlexibleUpdate();
    } catch (error) {
      debugPrint("Update error: $error");
    }
  }

  String get _formattedDate {
    return DateFormat("dd MMM yyyy").format(DateTime.now());
  }

  String get _formattedBalance {
    final rawBalance = dashboardController.userBalanceController.balance
        .toString();

    final value = double.tryParse(rawBalance) ?? 0;

    return _balanceFormatter.format(value);
  }

  String get _currencyCode {
    return box.read("currency_code")?.toString() ?? "";
  }

  bool get _dark => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _dark ? AppColors.darkBackground : AppColors.lightBackground;

  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;

  Color get _soft =>
      _dark ? AppColors.darkInputBackground : const Color(0xFFF0F8F2);

  Color get _text => Theme.of(context).colorScheme.onSurface;

  Color get _sub =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  Color get _line => _dark ? AppColors.darkBorder : AppColors.lightBorder;

  Color get _accent => Theme.of(context).colorScheme.primary;

  Widget _themeButton() => Obx(
    () => _topIconButton(
      onTap: themeController.toggleTheme,

      child: Icon(
        themeController.isDarkMode.value
            ? Icons.light_mode_rounded
            : Icons.dark_mode_rounded,

        color: _text,

        size: 21,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final status = _dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: status.copyWith(
        statusBarColor: Colors.transparent,

        systemNavigationBarColor: _bg,
      ),

      child: Obx(() {
        if (dashboardController.isLoading.value) {
          return Scaffold(
            backgroundColor: _bg,

            body: Center(child: CircularProgressIndicator(color: _accent)),
          );
        }

        if (dashboardController.deactiveStatus.value.trim().toLowerCase() ==
            'deactivated') {
          return _buildDeactivatedScreen(context, width);
        }

        return Scaffold(
          key: _scaffoldKey,

          drawer: DrawerWidget(),

          backgroundColor: _bg,

          body: SafeArea(
            bottom: false,

            child: RefreshIndicator(
              color: _accent,

              onRefresh: () async {
                dashboardController.fetchDashboardData();

                notificationController.fetchData();

                await Future<void>.delayed(const Duration(milliseconds: 500));
              },

              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),

                slivers: [
                  SliverToBoxAdapter(child: _buildTopBar(context)),

                  // 1. Advertisement slider, populated by DashboardDataModel.
                  SliverToBoxAdapter(child: _buildAdvertisementSlider()),

                  // 2. Compact balance card.
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(
                    child: _buildBalanceCard(width, _formattedDate),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  SliverToBoxAdapter(child: _buildRechargeAction(width)),

                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  SliverToBoxAdapter(child: _buildTransactionActionsBlock()),

                  const SliverToBoxAdapter(child: SizedBox(height: 15)),

                  SliverToBoxAdapter(child: _buildServicesBlock()),

                  const SliverToBoxAdapter(child: SizedBox(height: 150)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),

      child: Row(
        children: [
          // Menu is deliberately the FIRST item on the LEFT.
          _topIconButton(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),

            child: Icon(Icons.menu_rounded, color: _text, size: 23),
          ),

          const SizedBox(width: 12),

          Obx(() {
            final url = dashboardController
                .alldashboardData
                .value
                .data
                ?.userInfo
                ?.profileImageUrl;

            final hasPhoto = url != null && url.trim().isNotEmpty;

            return Container(
              width: 42,

              height: 42,

              padding: const EdgeInsets.all(2),

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                border: Border.all(color: _accent.withOpacity(.35), width: 1.5),
              ),

              child: ClipOval(
                child: hasPhoto
                    ? Image.network(
                        url,

                        fit: BoxFit.cover,

                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.person_rounded, color: _accent),
                      )
                    : Icon(Icons.person_rounded, color: _accent),
              ),
            );
          }),

          const SizedBox(width: 9),

          Expanded(
            child: Obx(() {
              final info = dashboardController.alldashboardData.value.data;

              final name = info?.userInfo?.resellerName?.toString() ?? '';

              final group = info?.resellerGroup?.toString() ?? '';

              return Column(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    name,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: _text,

                      fontSize: 14,

                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  if (group.trim().isNotEmpty && group != 'null') ...[
                    const SizedBox(height: 3),

                    Text(
                      group,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: _sub,

                        fontSize: 10,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),

          const SizedBox(width: 5),

          _themeButton(),

          const SizedBox(width: 7),

          Obx(() {
            final unread = notificationController.unreadlength.value;

            return _topIconButton(
              onTap: () => showNotificationPopup(context),

              child: Stack(
                clipBehavior: Clip.none,

                children: [
                  Icon(
                    Icons.notifications_none_rounded,

                    color: _text,

                    size: 22,
                  ),

                  if (unread > 0)
                    Positioned(
                      right: -7,

                      top: -7,

                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,

                          minHeight: 16,
                        ),

                        alignment: Alignment.center,

                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,

                          vertical: 1,
                        ),

                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),

                          borderRadius: BorderRadius.circular(12),

                          border: Border.all(color: _surface, width: 1.2),
                        ),

                        child: Text(
                          unread > 99 ? '99+' : '$unread',

                          style: const TextStyle(
                            color: Colors.white,

                            fontSize: 9,

                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _topIconButton({required VoidCallback onTap, required Widget child}) {
    return Material(
      color: _surface,

      borderRadius: BorderRadius.circular(13),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(13),

        child: Container(
          height: 40,

          width: 40,

          alignment: Alignment.center,

          decoration: BoxDecoration(
            border: Border.all(color: _line),

            borderRadius: BorderRadius.circular(13),
          ),

          child: child,
        ),
      ),
    );
  }

  /// Top banner. Images and titles come directly from
  /// dashboardController.alldashboardData.value.data.advertisementSliders.
  /// If the API returns no usable images, no empty banner takes up space.
  Widget _buildAdvertisementSlider() {
    final rawBanners =
        dashboardController.alldashboardData.value.data?.advertisementSliders ??
        [];
    final banners = rawBanners.where((banner) {
      final url = banner.adSliderImageUrl?.trim() ?? '';
      return url.isNotEmpty && url.toLowerCase() != 'null';
    }).toList();

    if (banners.isEmpty) return const SizedBox.shrink();

    final width = MediaQuery.sizeOf(context).width - 36;
    final height = (width / 2.55).clamp(124.0, 162.0).toDouble();
    final currentIndex = _currentAdvertisementIndex.clamp(
      0,
      banners.length - 1,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _line),
          boxShadow: _dark
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF17472B).withOpacity(.075),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _advertisementPageController,
              itemCount: banners.length,
              onPageChanged: (index) {
                if (mounted) {
                  setState(() => _currentAdvertisementIndex = index);
                }
              },
              itemBuilder: (context, index) {
                final banner = banners[index];
                final imageUrl = banner.adSliderImageUrl!.trim();
                final title = banner.advertisementTitle?.trim() ?? '';

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: height,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: _soft,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _accent,
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: _soft,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_outlined,
                          size: 36,
                          color: _accent.withOpacity(.55),
                        ),
                      ),
                    ),
                    if (title.isNotEmpty || banners.length > 1)
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xB3000000)],
                            stops: [0.48, 1.0],
                          ),
                        ),
                      ),
                    if (title.isNotEmpty)
                      Positioned(
                        left: 13,
                        right: banners.length > 1 ? 82 : 13,
                        bottom: 13,
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(color: Color(0x66000000), blurRadius: 5),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (banners.length > 1)
              Positioned(
                right: 12,
                bottom: 13,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(banners.length, (index) {
                    final selected = index == currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.only(left: 4),
                      width: selected ? 16 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            : Colors.white.withOpacity(.55),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33000000), blurRadius: 3),
                        ],
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double screenWidth, String formattedDate) {
    void openFinancialReport() {
      mypagecontroller.changePage(FinancialScreen(), isMainPage: false);
    }

    final narrow = screenWidth < 355;

    final radius = BorderRadius.circular(18);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),

      child: Container(
        width: double.infinity,

        decoration: BoxDecoration(
          borderRadius: radius,

          gradient: LinearGradient(
            begin: Alignment.topLeft,

            end: Alignment.bottomRight,

            colors: _dark
                ? [const Color(0xFF1D3525), _surface]
                : [Colors.white, const Color(0xFFF2FAF4)],
          ),

          border: Border.all(color: _dark ? _line : _accent.withOpacity(.18)),

          boxShadow: _dark
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF125F32).withOpacity(.065),

                    blurRadius: 18,

                    offset: const Offset(0, 7),
                  ),
                ],
        ),

        child: ClipRRect(
          borderRadius: radius,

          child: Stack(
            children: [
              Positioned(
                right: -38,

                top: -51,

                child: Container(
                  width: 128,

                  height: 128,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    border: Border.all(
                      color: _accent.withOpacity(_dark ? .09 : .065),

                      width: 20,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0,

                top: 15,

                bottom: 15,

                child: Container(
                  width: 3,

                  decoration: BoxDecoration(
                    color: _accent,

                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(5),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 14, 10),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Container(
                          width: 29,

                          height: 29,

                          decoration: BoxDecoration(
                            color: _accent.withOpacity(.11),

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
                              color: _text,

                              fontWeight: FontWeight.w800,

                              fontSize: 12.5,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        Text(
                          formattedDate,

                          style: TextStyle(
                            color: _sub,

                            fontSize: narrow ? 9 : 10,

                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [
                        Expanded(
                          child: Text(
                            _formattedBalance,

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,

                            style: TextStyle(
                              color: _text,

                              fontSize: narrow ? 24 : 27,

                              height: 1.05,

                              fontWeight: FontWeight.w900,

                              letterSpacing: -0.8,
                            ),
                          ),
                        ),

                        if (_currencyCode.isNotEmpty) ...[
                          const SizedBox(width: 7),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),

                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,

                                vertical: 4,
                              ),

                              decoration: BoxDecoration(
                                color: _accent.withOpacity(.11),

                                borderRadius: BorderRadius.circular(7),
                              ),

                              child: Text(
                                _currencyCode,

                                style: TextStyle(
                                  color: _accent,

                                  fontWeight: FontWeight.w800,

                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 7),

                    Align(
                      alignment: Alignment.centerRight,

                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: narrow ? 210 : 254,
                        ),

                        child: Material(
                          color: _accent.withOpacity(_dark ? .22 : .095),

                          borderRadius: BorderRadius.circular(10),

                          child: InkWell(
                            onTap: openFinancialReport,

                            borderRadius: BorderRadius.circular(10),

                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,

                                vertical: 5,
                              ),

                              child: Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Icon(
                                    Icons.insights_outlined,

                                    size: 15,

                                    color: _accent,
                                  ),

                                  const SizedBox(width: 6),

                                  Flexible(
                                    child: Text(
                                      languagesController.tr(
                                        'FINANCIAL_REPORT',
                                      ),

                                      maxLines: 1,

                                      overflow: TextOverflow.ellipsis,

                                      style: TextStyle(
                                        color: _accent,

                                        fontSize: 10.5,

                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 5),

                                  Icon(
                                    Icons.arrow_forward_ios_rounded,

                                    color: _accent,

                                    size: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildRechargeAction(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),

      child: Material(
        color: _soft,

        borderRadius: BorderRadius.circular(17),

        child: InkWell(
          onTap: _openAfghanistanRecharge,

          borderRadius: BorderRadius.circular(17),

          child: Container(
            width: double.infinity,

            padding: const EdgeInsets.fromLTRB(13, 9, 13, 9),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),

              border: Border.all(color: _accent.withOpacity(.15)),
            ),

            child: Row(
              children: [
                Container(
                  height: 41,

                  width: 41,

                  decoration: BoxDecoration(
                    color: _accent,

                    borderRadius: BorderRadius.circular(13),
                  ),

                  child: const Icon(
                    Icons.bolt_rounded,

                    color: Colors.white,

                    size: 23,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Text(
                    languagesController.tr('AFGHANISTAN_RECHARGE'),

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      color: _text,

                      fontWeight: FontWeight.w800,

                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  height: 30,

                  width: 30,

                  alignment: Alignment.center,

                  decoration: BoxDecoration(
                    color: _surface,

                    shape: BoxShape.circle,
                  ),

                  child: Icon(
                    Icons.arrow_forward_rounded,

                    color: _accent,

                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) => Padding(
    padding: const EdgeInsets.fromLTRB(19, 0, 19, 12),

    child: Row(
      children: [
        Container(
          height: 30,

          width: 30,

          decoration: BoxDecoration(
            color: _accent.withOpacity(.10),

            borderRadius: BorderRadius.circular(9),
          ),

          child: Icon(icon, size: 17, color: _accent),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            title,

            style: TextStyle(
              fontWeight: FontWeight.w800,

              fontSize: 16,

              color: _text,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildTransactionActionsBlock() {
    final items = <_HomeAction>[
      _HomeAction(
        title: languagesController.tr("MY_ACCOUNTING"),

        iconData: Icons.account_balance_outlined,

        accentColor: AppColors.onlinetelecomTurquoise,

        iconBackground: const Color(0xFFE8FAFC),

        onTap: () {
          AccountingPinPad.show(context);

          // dashboardController.fetchDashboardData();
        },
      ),

      _HomeAction(
        title: languagesController.tr("PAYMENT_RECEIPT_REQUEST"),

        imagePath: "assets/icons/wallet.png",

        accentColor: const Color(0xFF0FB26C),

        iconBackground: const Color(0xFFE8F8F2),

        onTap: () {
          _openProtectedPage(ReceiptsScreen());
        },
      ),

      _HomeAction(
        title: languagesController.tr("REQUES_LOAN_BALANCE"),

        imagePath: "assets/icons/transactionsicon.png",

        accentColor: const Color(0xFF3D86E9),

        iconBackground: const Color(0xFFEAF2FF),

        onTap: () {
          _openProtectedPage(RequestLoanScreen());
        },
      ),

      _HomeAction(
        title: languagesController.tr("HAWALA"),

        imagePath: "assets/icons/exchange.png",

        accentColor: const Color(0xFFEF9C28),

        iconBackground: const Color(0xFFFFF4DC),

        onTap: () {
          _openProtectedPage(HawalaListScreen());
        },
      ),

      _HomeAction(
        title: languagesController.tr("HAWALA_RATES"),

        imagePath: "assets/icons/exchange-rate.png",

        accentColor: const Color(0xFF536DE5),

        iconBackground: const Color(0xFFEDF0FF),

        onTap: () {
          _openProtectedPage(HawalaCurrencyScreen());
        },
      ),

      _HomeAction(
        title: languagesController.tr("ACTIVE_CARD"),

        imagePath: "assets/icons/transactionsicon.png",

        accentColor: const Color(0xFFE35366),

        iconBackground: const Color(0xFFFFECEF),

        onTap: () {
          // _openProtectedPage(Transactions());
        },
      ),

      _HomeAction(
        title: languagesController.tr("TRANSFER_COMISSION_TO_BALANCE"),

        imagePath: "assets/icons/transactionsicon.png",

        accentColor: const Color(0xFF8A59D5),

        iconBackground: const Color(0xFFF2ECFF),

        onTap: () {
          _openProtectedPage(CommissionTransferScreen());
        },
      ),

      _HomeAction(
        title: languagesController.tr("WITHDRAW"),

        imagePath: "assets/icons/wallet.png",

        accentColor: AppColors.primarycolor2,

        iconBackground: AppColors.secondaryColor.withOpacity(0.55),

        onTap: () {
          _openProtectedPage(WithdrawScreen());
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),

      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth < 305 ? 3 : 4;

          return GridView.builder(
            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),

            padding: EdgeInsets.zero,

            itemCount: items.length,

            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,

              mainAxisExtent: 98,

              crossAxisSpacing: 7,

              mainAxisSpacing: 8,
            ),

            itemBuilder: (_, index) => _buildHomeActionItem(items[index]),
          );
        },
      ),
    );
  }

  Widget _buildHomeActionItem(_HomeAction item) {
    return Material(
      color: _surface,

      borderRadius: BorderRadius.circular(15),

      child: InkWell(
        onTap: item.onTap,

        borderRadius: BorderRadius.circular(15),

        child: Container(
          padding: const EdgeInsets.fromLTRB(5, 8, 5, 5),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),

            border: Border.all(color: _line),
          ),

          child: Column(
            children: [
              Container(
                width: 36,

                height: 36,

                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(
                  color: _dark
                      ? item.accentColor.withOpacity(.17)
                      : item.iconBackground,

                  borderRadius: BorderRadius.circular(11),
                ),

                child: item.iconData != null
                    ? Icon(item.iconData, color: item.accentColor, size: 19)
                    : Image.asset(
                        item.imagePath!,

                        fit: BoxFit.contain,

                        errorBuilder: (_, __, ___) => Icon(
                          Icons.apps_rounded,

                          color: item.accentColor,

                          size: 19,
                        ),
                      ),
              ),

              const SizedBox(height: 5),

              Expanded(
                child: Center(
                  child: Text(
                    item.title,

                    maxLines: 3,

                    overflow: TextOverflow.ellipsis,

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: _text,

                      fontSize: 9.4,

                      height: 1.08,

                      fontWeight: FontWeight.w700,
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

  Widget _buildServicesBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        _sectionTitle(languagesController.tr('SERVICES'), Icons.apps_rounded),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),

          child: Obx(() {
            if (categorisListController.isLoading.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 34),

                child: Center(child: CircularProgressIndicator(color: _accent)),
              );
            }

            final list =
                categorisListController
                    .allcategorieslist
                    .value
                    .data
                    ?.servicecategories ??
                [];

            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),

                child: Center(
                  child: Text(
                    languagesController.tr('SERVICES'),

                    style: TextStyle(color: _sub),
                  ),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth < 300 ? 2 : 3;

                return GridView.builder(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  padding: EdgeInsets.zero,

                  itemCount: list.length,

                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,

                    mainAxisExtent: 112,

                    crossAxisSpacing: 9,

                    mainAxisSpacing: 9,
                  ),

                  itemBuilder: (context, index) {
                    final data = list[index];

                    final fallback =
                        fallbackServiceIcons[index %
                            fallbackServiceIcons.length];

                    final iconBg =
                        serviceIconBackgrounds[index %
                            serviceIconBackgrounds.length];

                    final url = data.categoryImageUrl.toString();

                    return Material(
                      color: _surface,

                      borderRadius: BorderRadius.circular(17),

                      child: InkWell(
                        onTap: () => _openService(data),

                        borderRadius: BorderRadius.circular(17),

                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),

                            gradient: LinearGradient(
                              begin: Alignment.topLeft,

                              end: Alignment.bottomRight,

                              colors: _dark
                                  ? [
                                      const Color(0xFF284032),

                                      _surface,

                                      _surface,
                                    ]
                                  : [
                                      Colors.white,

                                      const Color(0xFFF4FCF7),

                                      const Color(0xFFEBF8F0),
                                    ],

                              stops: const [0.0, .58, 1.0],
                            ),

                            border: Border.all(
                              color: _dark
                                  ? Colors.white.withOpacity(.09)
                                  : _accent.withOpacity(.14),
                            ),

                            boxShadow: _dark
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF0E7137,
                                      ).withOpacity(.06),

                                      blurRadius: 11,

                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),

                            child: Stack(
                              children: [
                                // Very soft, non-interactive gloss across the upper surface.
                                Positioned(
                                  top: -37,

                                  right: -25,

                                  child: IgnorePointer(
                                    child: Container(
                                      width: 98,

                                      height: 98,

                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,

                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withOpacity(
                                              _dark ? .09 : .85,
                                            ),

                                            Colors.white.withOpacity(0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Positioned(
                                  left: 10,

                                  right: 10,

                                  top: 0,

                                  child: IgnorePointer(
                                    child: Container(
                                      height: 1,

                                      color: Colors.white.withOpacity(
                                        _dark ? .12 : .9,
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    6,

                                    9,

                                    6,

                                    6,
                                  ),

                                  child: Column(
                                    children: [
                                      Container(
                                        height: 48,

                                        width: 48,

                                        padding: const EdgeInsets.all(9),

                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,

                                            end: Alignment.bottomRight,

                                            colors: _dark
                                                ? [
                                                    _soft,

                                                    _accent.withOpacity(.14),
                                                  ]
                                                : [Colors.white, iconBg],
                                          ),

                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),

                                          border: Border.all(
                                            color: Colors.white.withOpacity(
                                              _dark ? .08 : .75,
                                            ),
                                          ),

                                          boxShadow: [
                                            BoxShadow(
                                              color: _accent.withOpacity(.075),

                                              blurRadius: 9,

                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),

                                        child:
                                            url == 'null' || url.trim().isEmpty
                                            ? Image.asset(
                                                fallback,

                                                fit: BoxFit.contain,
                                              )
                                            : Image.network(
                                                url,

                                                fit: BoxFit.contain,

                                                errorBuilder: (_, __, ___) =>
                                                    Image.asset(
                                                      fallback,

                                                      fit: BoxFit.contain,
                                                    ),
                                              ),
                                      ),

                                      const SizedBox(height: 6),

                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            data.categoryName.toString(),

                                            maxLines: 2,

                                            textAlign: TextAlign.center,

                                            overflow: TextOverflow.ellipsis,

                                            style: TextStyle(
                                              color: _text,

                                              fontWeight: FontWeight.w700,

                                              fontSize: 10.5,

                                              height: 1.12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
              },
            );
          }),
        ),
      ],
    );
  }

  void _openAfghanistanRecharge() {
    Country? afghanistan;

    if (countryListController.finalCountryList.isNotEmpty) {
      try {
        afghanistan = countryListController.finalCountryList.firstWhere(
          (country) =>
              country.countryName?.trim().toLowerCase() == "afghanistan",
        );
      } catch (_) {
        afghanistan = null;
      }

      if (afghanistan != null) {
        box.write("country_id", afghanistan.id);

        box.write("countryName", afghanistan.countryName ?? "Afghanistan");

        box.write("maxlength", afghanistan.phoneNumberLength ?? "10");

        box.write("enable_operator_lookup", afghanistan.enableOperatorLookup);

        box.write("validity_type", "");

        box.write("company_id", "");

        box.write("search_tag", "");
      }
    }

    mypagecontroller.changePage(CreditTransfer(), isMainPage: false);
  }

  void _openProtectedPage(Widget page) {
    if (dashboardController.deactiveStatus.value.trim().toLowerCase() ==
        "deactivated") {
      Get.snackbar(
        dashboardController.deactiveStatus.toString(),

        dashboardController.deactivateMessage.toString(),

        snackPosition: SnackPosition.TOP,

        backgroundColor: Colors.redAccent,

        colorText: Colors.white,

        margin: const EdgeInsets.all(12),

        duration: const Duration(seconds: 1),

        icon: const Icon(Icons.block_rounded, color: Colors.white),
      );

      return;
    }

    mypagecontroller.changePage(page, isMainPage: false);
  }

  Future<void> _openService(Servicecategory category) async {
    // Clear the previous category/country before opening a new service.
    await box.write("service_category_id", category.id);
    await box.write("catName", category.categoryName?.toString() ?? "");
    await box.write("validity_type", "");
    await box.write("search_tag", "");
    await box.write("company_id", "");
    await box.write("country_id", "");
    await box.write("countryName", "");
    await box.write("maxlength", "");
    await box.write("enable_operator_lookup", false);

    if (!mounted) return;

    // Country selection takes priority, regardless of category type.
    if (category.requiresCountrySelection == true) {
      mypagecontroller.changePage(InternetPack(), isMainPage: false);
      return;
    }

    // Social categories retain the existing service flow.
    if (category.type?.toString().trim().toLowerCase() != "nonsocial") {
      mypagecontroller.changePage(ServiceScreen(), isMainPage: false);
      return;
    }

    // A nonsocial category may go directly to the recharge screen only
    // when the category does not require the country selection screen.
    bool enableOperatorLookup = false;
    final countryIds = <String>{};
    dynamic embeddedCountry;

    for (final service in category.services ?? []) {
      final dynamic country = service.company?.country;
      final dynamic id =
          country?.id ?? service.company?.countryId ?? service.countryId;
      final idText = id?.toString().trim() ?? "";
      if (idText.isEmpty) continue;

      countryIds.add(idText);
      if (country != null) embeddedCountry = country;
    }

    // Avoid arbitrarily choosing a country when the services span more
    // than one country or provide no country information at all.
    if (countryIds.length == 1) {
      final selectedId = countryIds.single;
      dynamic fullCountry;

      // Prefer the complete country listing for phone and lookup settings.
      for (final country in countryListController.finalCountryList) {
        if (country.id?.toString() == selectedId) {
          fullCountry = country;
          break;
        }
      }

      final dynamic resolvedId =
          fullCountry?.id ?? embeddedCountry?.id ?? selectedId;
      final dynamic resolvedName =
          fullCountry?.countryName ?? embeddedCountry?.countryName ?? "";
      final dynamic resolvedLength =
          fullCountry?.phoneNumberLength ??
          embeddedCountry?.phoneNumberLength ??
          "";
      final dynamic lookupValue =
          fullCountry?.enableOperatorLookup ??
          embeddedCountry?.enableOperatorLookup ??
          false;

      enableOperatorLookup =
          lookupValue == true ||
          lookupValue?.toString().trim().toLowerCase() == "true" ||
          lookupValue?.toString() == "1";

      await box.write("country_id", resolvedId);
      await box.write("countryName", resolvedName.toString());
      await box.write("maxlength", resolvedLength.toString());
      await box.write("enable_operator_lookup", enableOperatorLookup);
    }

    // Reset the stale selected operator/bundles for this new category.
    final serviceController = Get.isRegistered<ServiceController>()
        ? Get.find<ServiceController>()
        : Get.put(ServiceController());
    final bundleController = Get.isRegistered<BundleController>()
        ? Get.find<BundleController>()
        : Get.put(BundleController());

    serviceController.reserveDigit.clear();
    bundleController.resetBundles();

    if (!mounted) return;
    mypagecontroller.changePage(
      RechargeScreen(enableOperatorLookup: enableOperatorLookup),
      isMainPage: false,
    );
  }

  Widget _buildDeactivatedScreen(BuildContext context, double screenWidth) {
    return Scaffold(
      backgroundColor: _bg,

      body: SafeArea(
        bottom: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                Container(
                  height: 76,

                  width: 76,

                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(.10),

                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.block_rounded,

                    color: Colors.redAccent,

                    size: 40,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  dashboardController.deactiveStatus.toString(),

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: _text,

                    fontSize: 20,

                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  dashboardController.deactivateMessage.toString(),

                  textAlign: TextAlign.center,

                  style: TextStyle(color: _sub, fontSize: 14, height: 1.45),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,

                  height: 50,

                  child: ElevatedButton.icon(
                    onPressed: () => showDialog(
                      context: context,

                      builder: (_) => AlertDialog(
                        contentPadding: EdgeInsets.zero,

                        content: ContactDialogBox(),
                      ),
                    ),

                    icon: const Icon(Icons.support_agent_rounded),

                    label: Text(languagesController.tr('CONTACTUS')),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,

                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 13),

                TextButton(
                  onPressed: () => showDialog(
                    context: context,

                    builder: (_) => AlertDialog(
                      contentPadding: EdgeInsets.zero,

                      content: LogoutDialogBox(),
                    ),
                  ),

                  child: Text(
                    languagesController.tr('LOGOUT'),

                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),

                IconButton(
                  onPressed: dashboardController.fetchDashboardData,

                  icon: Icon(Icons.refresh_rounded, color: _accent),
                ),

                const SizedBox(height: 15),

                _themeButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showNotificationPopup(BuildContext context) {
    showDialog(
      context: context,

      barrierColor: Colors.black.withOpacity(0.30),

      builder: (context) {
        return Dialog(
          alignment: Alignment.topRight,

          insetPadding: const EdgeInsets.only(
            top: 70,

            right: 15,

            left: 25,

            bottom: 30,
          ),

          backgroundColor: Colors.transparent,

          child: Container(
            width: MediaQuery.of(context).size.width,

            constraints: const BoxConstraints(maxHeight: 480),

            decoration: BoxDecoration(
              color: _surface,

              borderRadius: BorderRadius.circular(20),

              border: Border.all(
                color: AppColors.onlinetelecomTurquoise.withOpacity(0.09),
              ),

              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.13),

                  blurRadius: 24,

                  spreadRadius: 2,

                  offset: const Offset(0, 10),
                ),
              ],
            ),

            child: Obx(() {
              final isLoading = notificationController.isLoading.value;

              final notifications =
                  notificationController
                      .allnotificationlist
                      .value
                      .data
                      ?.notifications ??
                  [];

              return Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 15, 10, 11),

                    child: Row(
                      children: [
                        Container(
                          height: 39,

                          width: 39,

                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primarycolor2,

                                AppColors.onlinetelecomTurquoise,
                              ],
                            ),

                            borderRadius: BorderRadius.circular(11),
                          ),

                          child: const Icon(
                            Icons.notifications_none_rounded,

                            color: Colors.white,

                            size: 21,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: NText(
                            text: languagesController.tr("NOTIFICATIONS"),

                            fontSize: 17,

                            fontWeight: FontWeight.w700,

                            color: _text,
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            Get.back();
                          },

                          icon: Icon(Icons.close_rounded, color: _sub),
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 1,

                    thickness: 1,

                    color: AppColors.primaryColor.withOpacity(0.06),
                  ),

                  if (isLoading)
                    const SizedBox(
                      height: 250,

                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.onlinetelecomTurquoise,
                        ),
                      ),
                    )
                  else if (notifications.isEmpty)
                    SizedBox(
                      height: 250,

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),

                            decoration: BoxDecoration(
                              color: _soft,

                              shape: BoxShape.circle,
                            ),

                            child: Icon(
                              Icons.notifications_off_outlined,

                              size: 39,

                              color: _sub,
                            ),
                          ),

                          const SizedBox(height: 13),

                          NText(
                            text: languagesController.tr("NO_NOTIFICATIONS"),

                            fontSize: 14,

                            color: _sub,

                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,

                        padding: EdgeInsets.zero,

                        itemCount: notifications.length > 10
                            ? 10
                            : notifications.length,

                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 1,

                            thickness: 1,

                            indent: 70,

                            color: AppColors.primaryColor.withOpacity(0.055),
                          );
                        },

                        itemBuilder: (context, index) {
                          final notification = notifications[index];

                          final unread = notification.isRead == false;

                          return InkWell(
                            onTap: () async {
                              Get.back();

                              await Get.to(
                                () => NotificationDetailsPage(
                                  notification: notification,
                                ),
                              );

                              await notificationController.fetchData();
                            },

                            child: Container(
                              decoration: BoxDecoration(
                                color: unread
                                    ? AppColors.onlinetelecomBackground
                                    : _surface,

                                border: unread
                                    ? const Border(
                                        left: BorderSide(
                                          color:
                                              AppColors.onlinetelecomTurquoise,

                                          width: 3,
                                        ),
                                      )
                                    : null,
                              ),

                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,

                                vertical: 13,
                              ),

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,

                                    children: [
                                      Container(
                                        height: 43,

                                        width: 43,

                                        decoration: BoxDecoration(
                                          color: unread
                                              ? AppColors.secondaryColor
                                              : AppColors
                                                    .onlinetelecomBackground,

                                          shape: BoxShape.circle,
                                        ),

                                        child: Icon(
                                          Icons.notifications_rounded,

                                          size: 21,

                                          color: unread
                                              ? AppColors.primarycolor2
                                              : AppColors.fontColor,
                                        ),
                                      ),

                                      if (unread)
                                        Positioned(
                                          right: 1,

                                          top: 1,

                                          child: Container(
                                            height: 9,

                                            width: 9,

                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,

                                              shape: BoxShape.circle,

                                              border: Border.all(
                                                color: _surface,

                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        NText(
                                          text: notification.title ?? "",

                                          maxLines: 1,

                                          overflow: TextOverflow.ellipsis,

                                          fontSize: 14,

                                          fontWeight: unread
                                              ? FontWeight.w700
                                              : FontWeight.w600,

                                          color: _text,
                                        ),

                                        const SizedBox(height: 4),

                                        NText(
                                          text: notification.message ?? "",

                                          maxLines: 2,

                                          overflow: TextOverflow.ellipsis,

                                          fontSize: 12,

                                          height: 1.4,

                                          color: _sub,
                                        ),

                                        const SizedBox(height: 6),

                                        NText(
                                          text: notification.createdAt == null
                                              ? ""
                                              : DateFormat(
                                                  "dd MMM yyyy, hh:mm a",
                                                ).format(
                                                  notification.createdAt!
                                                      .toLocal(),
                                                ),

                                          fontSize: 10,

                                          color: _sub.withOpacity(0.80),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  Divider(
                    height: 1,

                    thickness: 1,

                    color: AppColors.primaryColor.withOpacity(0.06),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12),

                    child: SizedBox(
                      width: double.infinity,

                      height: 46,

                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();

                          await Get.to(() => const AllNotificationsPage());

                          await notificationController.fetchData();
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,

                          foregroundColor: Colors.white,

                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: NText(
                          text: languagesController.tr("VIEW_ALL"),

                          color: Colors.white,

                          fontSize: 14,

                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

class _HomeAction {
  final String title;

  final String? imagePath;

  final IconData? iconData;

  final Color accentColor;

  final Color iconBackground;

  final VoidCallback onTap;

  const _HomeAction({
    required this.title,

    this.imagePath,

    this.iconData,

    required this.accentColor,

    required this.iconBackground,

    required this.onTap,
  });
}
