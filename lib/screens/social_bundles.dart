import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';

import 'package:onlinetelecom/controllers/bundle_controller.dart';
import 'package:onlinetelecom/controllers/confirm_pin_controller.dart';
import 'package:onlinetelecom/controllers/service_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/helpers/price.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Online Telecom — communication packages / social bundles.
///
/// This screen keeps the existing controller sources, pagination, refresh,
/// bundleID storage and PIN-confirmed placeOrder() workflow unchanged.
class SocialBundles extends StatefulWidget {
  const SocialBundles({super.key});

  @override
  State<SocialBundles> createState() => _SocialBundlesState();
}

class _SocialBundlesState extends State<SocialBundles> {
  final ServiceController serviceController = Get.find<ServiceController>();
  final BundleController bundleController = Get.find<BundleController>();
  final ConfirmPinController confirmPinController =
      Get.find<ConfirmPinController>();
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final ThemeController themeController = Get.find<ThemeController>();
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final GetStorage box = GetStorage();
  final ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _dark => themeController.isDarkMode.value;
  Color get _background =>
      _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _soft =>
      _dark ? AppColors.darkInputBackground : const Color(0xFFF0F8F2);
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _accent => AppColors.primaryColor;
  static const Color _buyColor = Color(0xFFDB5964);

  @override
  void initState() {
    super.initState();
    confirmPinController.numberController.clear();
    bundleController.finalList.clear();
    bundleController.initialpage = 1;
    scrollController.addListener(_loadMoreBundles);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      serviceController.fetchservices();
      bundleController.fetchallbundles();
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_loadMoreBundles);
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreBundles() async {
    if (!scrollController.hasClients || bundleController.isLoading.value) {
      return;
    }
    final reachedBottom =
        scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 80;
    if (!reachedBottom) return;

    final totalPages =
        bundleController.allbundleslist.value.payload?.pagination.totalPages ??
        0;
    if (totalPages <= 0 || bundleController.initialpage >= totalPages) {
      return;
    }
    bundleController.initialpage++;
    await bundleController.fetchallbundles();
  }

  Future<void> _pullRefresh() async {
    bundleController.finalList.clear();
    bundleController.initialpage = 1;
    await bundleController.fetchallbundles();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final darkMode = themeController.isDarkMode.value;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: darkMode
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: darkMode ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: _background,
          systemNavigationBarIconBrightness: darkMode
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
                const SizedBox(height: 3),
                Expanded(child: _buildBundleList()),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
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
              languagesController.tr('COMMUNICATION_PACKAGES'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _headerButton(
            tooltip: themeController.isDarkMode.value
                ? 'Light mode'
                : 'Dark mode',
            icon: themeController.isDarkMode.value
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            onTap: themeController.toggleTheme,
          ),
          const SizedBox(width: 8),
          _headerButton(
            tooltip: 'Menu',
            icon: Icons.menu_rounded,
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _headerButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Icon(icon, color: _text, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildBundleList() {
    final media = MediaQuery.of(context);
    final bottomClearance = media.viewInsets.bottom > 0
        ? 22.0
        : 90.0 + media.viewPadding.bottom;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final bundles = bundleController.finalList;
        final isLoading = bundleController.isLoading.value;

        if (isLoading && bundles.isEmpty) {
          return Center(child: CircularProgressIndicator(color: _accent));
        }

        if (bundles.isEmpty) {
          return RefreshIndicator(
            color: _accent,
            onRefresh: _pullRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(0, 78, 0, bottomClearance),
              children: [
                Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _soft,
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: _border),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: _accent,
                      size: 29,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
          color: _accent,
          onRefresh: _pullRefresh,
          child: ListView.separated(
            controller: scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(1, 3, 1, bottomClearance),
            itemCount: bundles.length + (isLoading ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index >= bundles.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: SizedBox(
                      height: 21,
                      width: 21,
                      child: CircularProgressIndicator(
                        color: _accent,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                );
              }
              return _buildBundleCard(bundles[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCompanyLogo(String url, {double size = 45}) {
    final hasLogo = url.trim().isNotEmpty && url.trim() != 'null';
    return Container(
      height: size,
      width: size,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(13),
      ),
      child: hasLogo
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (context, url) => Center(
                child: SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: _accent,
                  ),
                ),
              ),
              errorWidget: (context, url, error) =>
                  Icon(Icons.sim_card_outlined, color: _accent, size: 22),
            )
          : Icon(Icons.sim_card_outlined, color: _accent, size: 22),
    );
  }

  Widget _buildBundleCard(dynamic data) {
    final companyName = data.service?.company?.companyName?.toString() ?? '';
    final logo = data.service?.company?.companyLogo?.toString() ?? '';
    final title = data.bundleTitle?.toString() ?? '';
    final buyingPrice = data.buyingPrice?.toString() ?? '';
    final sellingPrice = data.sellingPrice?.toString() ?? '';
    final validity = data.validityType?.toString() ?? '';
    final currency = box.read('currency_code')?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
        boxShadow: _dark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF164B2B).withOpacity(.042),
                  blurRadius: 11,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(17),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            box.write('bundleID', data.id.toString());
            _showBundleDialog(
              companyName: companyName,
              title: title,
              validity: validity,
              buyingPrice: buyingPrice,
              sellingPrice: sellingPrice,
              imageLink: logo,
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildCompanyLogo(logo),
                    const SizedBox(width: 10),
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
                              fontSize: 12.5,
                              height: 1.16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (companyName.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              companyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _muted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (validity.trim().isNotEmpty && validity != 'null') ...[
                      const SizedBox(width: 7),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 80),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _soft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _validityText(validity),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _accent,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: _compactPrice(
                        label: languagesController.tr('BUY'),
                        price: buyingPrice,
                        currency: currency,
                        accent: _buyColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _compactPrice(
                        label: languagesController.tr('SALE'),
                        price: sellingPrice,
                        currency: currency,
                        accent: _accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _compactPrice({
    required String label,
    required String price,
    required String currency,
    required Color accent,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: accent.withOpacity(_dark ? .13 : .065),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: accent,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PriceTextView(
                      price: price,
                      textStyle: TextStyle(
                        color: _text,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (currency.isNotEmpty) ...[
                      const SizedBox(width: 3),
                      Text(
                        currency,
                        maxLines: 1,
                        style: TextStyle(
                          color: accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _validityText(String? value) {
    switch (value?.toLowerCase()) {
      case 'unlimited':
        return languagesController.tr('UNLIMITED');
      case 'monthly':
        return languagesController.tr('MONTHLY');
      case 'weekly':
        return languagesController.tr('WEEKLY');
      case 'daily':
        return languagesController.tr('DAILY');
      case 'hourly':
        return languagesController.tr('HOURLY');
      case 'nightly':
        return languagesController.tr('NIGHTLY');
      default:
        return value ?? '';
    }
  }

  void _showBundleDialog({
    required String companyName,
    required String title,
    required String validity,
    required String buyingPrice,
    required String sellingPrice,
    required String imageLink,
  }) {
    // Every new order requires fresh confirmation details.
    confirmPinController.numberController.clear();
    confirmPinController.pinController.clear();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 22,
          ),
          child: SocialdialogBox(
            companyname: companyName,
            title: title,
            validity: validity,
            buyingprice: buyingPrice,
            sellingprice: sellingPrice,
            imagelink: imageLink,
          ),
        );
      },
    );
  }
}

/// Existing public dialog name and constructor retained for external callers.
class SocialdialogBox extends StatefulWidget {
  const SocialdialogBox({
    super.key,
    this.title,
    this.validity,
    this.buyingprice,
    this.sellingprice,
    this.imagelink,
    this.companyname,
  });

  final String? companyname;
  final String? title;
  final String? validity;
  final String? buyingprice;
  final String? sellingprice;
  final String? imagelink;

  @override
  State<SocialdialogBox> createState() => _SocialdialogBoxState();
}

class _SocialdialogBoxState extends State<SocialdialogBox> {
  final ConfirmPinController confirmPinController =
      Get.find<ConfirmPinController>();
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final ThemeController themeController = Get.find<ThemeController>();
  final GetStorage box = GetStorage();

  bool _showPin = false;

  bool get _dark => themeController.isDarkMode.value;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _input =>
      _dark ? AppColors.darkInputBackground : AppColors.lightSurface;
  Color get _soft =>
      _dark ? AppColors.darkInputBackground : const Color(0xFFF0F8F2);
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _accent => AppColors.primaryColor;
  static const Color _buyColor = Color(0xFFDB5964);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Observe both theme and order-loading state inside the dialog itself.
      final dark = themeController.isDarkMode.value;
      final isLoading = confirmPinController.isLoading.value;
      final screen = MediaQuery.of(context);
      final maxHeight = (screen.size.height - screen.viewInsets.bottom - 56)
          .clamp(260.0, 620.0)
          .toDouble();

      return Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkCard : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: _border),
        ),
        clipBehavior: Clip.antiAlias,
        child: isLoading
            ? SizedBox(
                height: 225,
                child: Center(
                  child: Lottie.asset(
                    'assets/loties/recharge.json',
                    width: 165,
                    height: 165,
                  ),
                ),
              )
            : SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogHeader(context),
                    const SizedBox(height: 16),
                    _buildPricingSummary(),
                    const SizedBox(height: 18),
                    _inputLabel(languagesController.tr('ENTER_ID')),
                    const SizedBox(height: 7),
                    _textField(
                      controller: confirmPinController.numberController,
                      hint: languagesController.tr('ENTER_ID'),
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    _inputLabel(languagesController.tr('PIN')),
                    const SizedBox(height: 7),
                    _textField(
                      controller: confirmPinController.pinController,
                      hint: languagesController.tr('PIN'),
                      icon: Icons.lock_outline_rounded,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      obscureText: !_showPin,
                      maxLength: 4,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      suffixIcon: IconButton(
                        tooltip: _showPin ? 'Hide PIN' : 'Show PIN',
                        icon: Icon(
                          _showPin
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: _muted,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _showPin = !_showPin),
                      ),
                      onSubmitted: (_) => _submitOrder(context),
                    ),
                    const SizedBox(height: 21),
                    _buildActions(context),
                  ],
                ),
              ),
      );
    });
  }

  Widget _buildDialogHeader(BuildContext context) {
    final logo = widget.imagelink?.toString() ?? '';
    final hasLogo = logo.trim().isNotEmpty && logo != 'null';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          width: 50,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _soft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: hasLogo
              ? CachedNetworkImage(
                  imageUrl: logo,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) =>
                      Icon(Icons.sim_card_outlined, color: _accent, size: 23),
                )
              : Icon(Icons.sim_card_outlined, color: _accent, size: 23),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.companyname ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _muted,
                  fontSize: 11.5,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if ((widget.validity ?? '').isNotEmpty) ...[
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _soft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _validityText(widget.validity),
                    style: TextStyle(
                      color: _accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: _soft,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => Navigator.pop(context),
            child: SizedBox(
              width: 31,
              height: 31,
              child: Icon(Icons.close_rounded, color: _muted, size: 19),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSummary() {
    final currency = box.read('currency_code')?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          _summaryRow(
            label: languagesController.tr('BUY'),
            price: widget.buyingprice?.toString() ?? '',
            currency: currency,
            color: _buyColor,
            icon: Icons.shopping_bag_outlined,
          ),
          Divider(height: 1, thickness: 1, color: _border),
          _summaryRow(
            label: languagesController.tr('SALE'),
            price: widget.sellingprice?.toString() ?? '',
            currency: currency,
            color: _accent,
            icon: Icons.sell_outlined,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    required String price,
    required String currency,
    required Color color,
    required IconData icon,
  }) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 9),
          Text(
            label,
            style: TextStyle(
              color: _muted,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PriceTextView(
                      price: price,
                      textStyle: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (currency.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        currency,
                        style: TextStyle(
                          color: color,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputLabel(String text) {
    return Text(
      text,
      style: TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w700),
    );
  }

  /// ONE background and ONE OutlineInputBorder on each field (no wrapper
  /// container, no nested colored surface, no Material shadow).
  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required TextInputAction textInputAction,
    bool obscureText = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    ValueChanged<String>? onSubmitted,
  }) {
    return SizedBox(
      height: 49,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        cursorColor: _accent,
        style: TextStyle(
          color: _text,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: _input,
          counterText: '',
          hintText: hint,
          hintStyle: TextStyle(color: _muted, fontSize: 12.5),
          prefixIcon: Icon(icon, color: _accent, size: 19),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 43,
            minHeight: 44,
          ),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _accent, width: 1.3),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 47,
            child: ElevatedButton.icon(
              onPressed: () => _submitOrder(context),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: Text(
                languagesController.tr('CONFIRMATION'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 47,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _border),
                foregroundColor: _text,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
    );
  }

  void _submitOrder(BuildContext context) {
    if (confirmPinController.isLoading.value) return;

    if (confirmPinController.numberController.text.trim().isEmpty) {
      _showToast(languagesController.tr('ENTER_ID'));
      return;
    }
    if (confirmPinController.pinController.text.trim().isEmpty) {
      _showToast(languagesController.tr('ENTER_YOUR_PIN'));
      return;
    }

    // Keep the original server-side PIN verification and order flow.
    confirmPinController.placeOrder(context);
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  String _validityText(String? value) {
    switch (value?.toLowerCase()) {
      case 'unlimited':
        return languagesController.tr('UNLIMITED');
      case 'monthly':
        return languagesController.tr('MONTHLY');
      case 'weekly':
        return languagesController.tr('WEEKLY');
      case 'daily':
        return languagesController.tr('DAILY');
      case 'hourly':
        return languagesController.tr('HOURLY');
      case 'nightly':
        return languagesController.tr('NIGHTLY');
      default:
        return value ?? '';
    }
  }
}
