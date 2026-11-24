import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:onlinetelecom/controllers/dashboard_controller.dart';
import 'package:onlinetelecom/controllers/drawer_controller.dart';
import 'package:onlinetelecom/controllers/order_list_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/helpers/capture_image_helper.dart';
import 'package:onlinetelecom/helpers/localtime_helper.dart';
import 'package:onlinetelecom/helpers/share_image_helper.dart';
import 'package:onlinetelecom/screens/order_details_screen.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/contact_dialogbox.dart';
import 'package:onlinetelecom/widgets/logoutbox.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Orders: compact, card-first layout. Preserves the existing API, filters,
/// pagination and order-details navigation.
class Orders extends StatefulWidget {
  const Orders({super.key});
  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final OrderlistController orderlistController =
      Get.find<OrderlistController>();
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final MyDrawerController drawerController = Get.put(MyDrawerController());
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final ThemeController themeController = Get.find<ThemeController>();
  final GetStorage box = GetStorage();
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RxString selectedDate = ''.obs;
  final NumberFormat _money = NumberFormat.currency(
    locale: 'en_US',
    symbol: '',
    decimalDigits: 2,
  );
  Timer? _debounce;
  String defaultValue = '';
  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _field =>
      _dark ? AppColors.darkInputBackground : AppColors.lightSurface;
  Color get _foreground => Theme.of(context).colorScheme.onSurface;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _primary => Theme.of(context).colorScheme.primary;
  static const Color _pendingColor = Color(0xFFCF931E);
  static const Color _confirmedColor = Color(0xFF18A56A);
  static const Color _rejectedColor = Color(0xFFE05B64);
  @override
  void initState() {
    super.initState();
    // The order-list service reads these values from GetStorage.
    box.write('date', '');
    box.write('orderstatus', '');
    box.write('search_target', '');
    orderlistController.finalList.clear();
    orderlistController.initialpage = 1;
    orderlistController.fetchOrderlistdata();
    scrollController.addListener(_loadMore);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    scrollController.removeListener(_loadMore);
    scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value.isEmpty
          ? DateTime.now()
          : DateTime.tryParse(selectedDate.value) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (dialogContext, child) => Theme(
        data: Theme.of(dialogContext).copyWith(
          colorScheme: Theme.of(dialogContext).colorScheme.copyWith(
            primary: _primary,
            onPrimary: Colors.white,
            surface: _surface,
            onSurface: _foreground,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final date = DateFormat('yyyy-MM-dd').format(picked);
    selectedDate.value = date;
    box.write('date', 'selected_date=$date');
    await _reloadOrders();
  }

  Future<void> _reloadOrders() async {
    // Retain the same pagination reset behavior as the original screen.
    orderlistController.finalList.clear();
    orderlistController.initialpage = 1;
    orderlistController.fetchOrderlistdata();
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  void _loadMore() {
    if (!scrollController.hasClients || orderlistController.isLoading.value) {
      return;
    }
    final totalItems =
        orderlistController.allorderlist.value.payload?.pagination.totalItems ??
        0;
    if (orderlistController.finalList.length >= totalItems) return;
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 80) {
      orderlistController.initialpage++;
      orderlistController.fetchOrderlistdata();
    }
  }

  void _changeStatus(String value) {
    if (defaultValue == value) return;
    setState(() => defaultValue = value);
    box.write('orderstatus', value);
    _reloadOrders();
  }

  Future<void> _clearFilters() async {
    _debounce?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    _searchController.clear();
    setState(() => defaultValue = '');
    selectedDate.value = '';
    box.write('date', '');
    box.write('orderstatus', '');
    box.write('search_target', '');
    await _reloadOrders();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      box.write('search_target', value.trim());
      _reloadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final overlay = SystemUiOverlayStyle(
      statusBarColor: _bg,
      statusBarIconBrightness: _dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: _dark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: _bg,
      systemNavigationBarIconBrightness: _dark
          ? Brightness.light
          : Brightness.dark,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Obx(() {
        if (dashboardController.deactiveStatus.value.trim().toLowerCase() ==
            'deactivated') {
          return _buildDeactivatedScreen();
        }
        return Scaffold(
          key: _scaffoldKey,
          drawer: const DrawerWidget(),
          resizeToAvoidBottomInset: false,
          backgroundColor: _bg,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchAndFilters(),
                Expanded(
                  child: RefreshIndicator(
                    color: _primary,
                    onRefresh: _reloadOrders,
                    child: _buildOrdersList(),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _headerIcon({
    required Widget icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
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
            child: icon,
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
          _headerIcon(
            tooltip: 'Menu',
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            icon: Icon(Icons.menu_rounded, size: 22, color: _foreground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    languagesController.tr('ORDERS'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _foreground,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.4,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Obx(() {
                  final count = orderlistController.finalList.length;
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _primary,
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
                color: _foreground,
              ),
            ),
          ),
          const SizedBox(width: 9),
          _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
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
          color: _primary.withOpacity(.11),
          border: Border.all(color: _primary.withOpacity(.22), width: 1.5),
        ),
        child: hasPhoto
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.person_rounded, size: 24, color: _primary),
              )
            : Icon(Icons.person_rounded, size: 24, color: _primary),
      );
    });
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 47,
                  // A single InputDecorator owns both the fill and rounded
                  // border, preventing a second themed layer at the corners.
                  child: TextField(
                    controller: _searchController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.search,
                    cursorColor: _primary,
                    onChanged: _onSearchChanged,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(
                      color: _foreground,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: _field,
                      hintText: languagesController.tr('SEARCH_BY_PHOENUMBER'),
                      hintStyle: TextStyle(color: _muted, fontSize: 12),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: _primary,
                        size: 21,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 45,
                        minHeight: 43,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: _border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: _border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: _primary, width: 1.2),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: _border),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              _dateButton(),
            ],
          ),
          const SizedBox(height: 11),
          SizedBox(
            height: 34,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _statusChip('', 'ALL'),
                        const SizedBox(width: 6),
                        _statusChip('order_status=0', 'PENDING'),
                        const SizedBox(width: 6),
                        _statusChip('order_status=1', 'CONFIRMED'),
                        const SizedBox(width: 6),
                        _statusChip('order_status=2', 'REJECTED'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: _surface,
                  borderRadius: BorderRadius.circular(11),
                  child: InkWell(
                    onTap: _clearFilters,
                    borderRadius: BorderRadius.circular(11),
                    child: Container(
                      height: 34,
                      width: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: _border),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        Icons.filter_alt_off_outlined,
                        size: 18,
                        color: _muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateButton() {
    return Obx(() {
      final date = selectedDate.value;
      final active = date.isNotEmpty;
      String shown = languagesController.tr('DATE');
      if (active) {
        final parsed = DateTime.tryParse(date);
        shown = parsed == null ? date : DateFormat('dd MMM').format(parsed);
      }
      return Material(
        color: active ? _primary.withOpacity(.10) : _surface,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _selectDate(context),
          child: Container(
            height: 47,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(
              border: Border.all(
                color: active ? _primary.withOpacity(.4) : _border,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_rounded, color: _primary, size: 17),
                const SizedBox(width: 7),
                Text(
                  shown,
                  style: TextStyle(
                    color: active ? _primary : _foreground,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _statusChip(String value, String textKey) {
    final selected = defaultValue == value;
    final tint = value == 'order_status=0'
        ? _pendingColor
        : value == 'order_status=1'
        ? _confirmedColor
        : value == 'order_status=2'
        ? _rejectedColor
        : _primary;
    return Material(
      color: selected ? tint.withOpacity(_dark ? .18 : .10) : _surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _changeStatus(value),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? tint.withOpacity(.55) : _border,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            languagesController.tr(textKey),
            style: TextStyle(
              color: selected ? tint : _muted,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return Obx(() {
      final items = orderlistController.finalList;
      final loading = orderlistController.isLoading.value;
      if (loading && items.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator(color: _primary)),
            ),
          ],
        );
      }
      if (items.isEmpty) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 38),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 57,
                    height: 57,
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: _primary,
                      size: 27,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    languagesController.tr('NO_DATA_FOUND'),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
      return ListView.separated(
        controller: scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 1, 16, 28),
        itemCount: items.length + (loading ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 9),
        itemBuilder: (_, index) {
          if (index >= items.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(color: _primary)),
            );
          }
          return _buildOrderCard(items[index]);
        },
      );
    });
  }

  Color _statusColor(String status) {
    if (status == '0') return _pendingColor;
    if (status == '1') return _confirmedColor;
    return _rejectedColor;
  }

  String _statusLabel(String status) {
    return status == '0'
        ? languagesController.tr('PENDING')
        : status == '1'
        ? languagesController.tr('CONFIRMED')
        : languagesController.tr('REJECTED');
  }

  String _shortDate(dynamic date) {
    if (date == null) return '';
    try {
      return DateFormat(
        'dd MMM yyyy',
      ).format(DateTime.parse(date.toString()).toLocal());
    } catch (_) {
      return date.toString();
    }
  }

  /// Compact order card: visual structure is intentionally different from the
  /// old multi-row order card. Tap still opens the existing OrderDetailsScreen.
  Widget _buildOrderCard(dynamic data) {
    final status = data.status.toString();
    final accent = _statusColor(status);
    final phone = data.rechargebleAccount?.toString() ?? '';
    final bundleTitle = data.bundle?.bundleTitle?.toString() ?? '';
    final logo = data.bundle?.service?.company?.companyLogo?.toString() ?? '';
    final buyingPrice =
        double.tryParse(data.bundle?.buyingPrice.toString() ?? '0') ?? 0;
    final sellingPrice =
        double.tryParse(data.bundle?.sellingPrice.toString() ?? '0') ?? 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openOrderDetails(data),
        borderRadius: BorderRadius.circular(19),
        child: Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_dark ? .09 : .035),
                blurRadius: 13,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Stack(
              children: [
                Positioned(
                  top: 13,
                  bottom: 13,
                  left: 0,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(3),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(13, 11, 12, 11),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tag_rounded, size: 12, color: _muted),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              '${languagesController.tr('ORDER_ID')} #${data.id}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _muted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _shortDate(data.createdAt),
                            maxLines: 1,
                            style: TextStyle(
                              color: _muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            height: 37,
                            width: 37,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(color: _border),
                            ),
                            child: logo.isNotEmpty && logo != 'null'
                                ? Image.network(
                                    logo,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.sim_card_rounded,
                                      color: _primary,
                                      size: 21,
                                    ),
                                  )
                                : Icon(
                                    Icons.sim_card_rounded,
                                    color: _primary,
                                    size: 21,
                                  ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  phone.isEmpty ? '-' : phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _foreground,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (bundleTitle.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    bundleTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(_dark ? .16 : .09),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _statusLabel(status),
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Expanded(
                            child: _compactPrice(
                              label: languagesController.tr('BUY'),
                              amount: buyingPrice,
                              color: _primary,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: _compactPrice(
                              label: languagesController.tr('SELL'),
                              amount: sellingPrice,
                              color: const Color(0xFF3994D5),
                            ),
                          ),
                        ],
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
  }

  Widget _compactPrice({
    required String label,
    required double amount,
    required Color color,
  }) {
    final currency = box.read('currency_code')?.toString() ?? '';
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(_dark ? .10 : .06),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              '${_money.format(amount)}${currency.isEmpty ? '' : ' $currency'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _foreground,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openOrderDetails(dynamic data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(
          createDate: data.createdAt.toString(),
          status: data.status.toString(),
          rejectReason: data.rejectReason.toString(),
          companyName:
              data.bundle?.service?.company?.companyName?.toString() ?? '',
          bundleTitle: data.bundle?.bundleTitle?.toString() ?? '',
          rechargebleAccount: data.rechargebleAccount?.toString() ?? '',
          validityType: data.bundle?.validityType?.toString() ?? '',
          sellingPrice: data.bundle?.sellingPrice?.toString() ?? '',
          buyingPrice: data.bundle?.buyingPrice?.toString() ?? '',
          orderID: data.id?.toString() ?? '',
          resellerName:
              dashboardController
                  .alldashboardData
                  .value
                  .data
                  ?.userInfo
                  ?.contactName
                  ?.toString() ??
              '',
          resellerPhone:
              dashboardController.alldashboardData.value.data?.userInfo?.phone
                  ?.toString() ??
              '',
          companyLogo:
              data.bundle?.service?.company?.companyLogo?.toString() ?? '',
        ),
      ),
    );
  }

  Widget _buildDeactivatedScreen() {
    return Scaffold(
      backgroundColor: _bg,
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
                    color: _rejectedColor.withOpacity(.11),
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: const Icon(
                    Icons.block_rounded,
                    color: _rejectedColor,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  dashboardController.deactiveStatus.toString(),
                  style: TextStyle(
                    color: _foreground,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 7),
                Text(
                  dashboardController.deactivateMessage.toString(),
                  style: TextStyle(color: _muted, fontSize: 13, height: 1.45),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 47,
                  child: ElevatedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        content: const ContactDialogBox(),
                      ),
                    ),
                    icon: const Icon(Icons.support_agent_rounded, size: 19),
                    label: Text(languagesController.tr('CONTACTUS')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                    style: const TextStyle(color: _rejectedColor),
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

/// Retained for callers that still use the original order receipt dialog.
/// Save/share actions and the original constructor parameters are preserved.
class DetailsDialog extends StatelessWidget {
  DetailsDialog({
    super.key,
    this.status,
    this.bundletitle,
    this.phoneNumber,
    this.sellingPrice,
    this.orderId,
    this.imagelink,
    this.date,
  });
  final String? status;
  final String? bundletitle;
  final String? phoneNumber;
  final String? sellingPrice;
  final String? orderId;
  final String? imagelink;
  final String? date;
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final GetStorage box = GetStorage();
  final GlobalKey catpureKey = GlobalKey();
  final GlobalKey shareKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkCard : AppColors.lightSurface;
    final background = dark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final muted = dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
    final state = status.toString();
    final stateColor = state == '0'
        ? const Color(0xFFCF931E)
        : state == '1'
        ? const Color(0xFF18A56A)
        : const Color(0xFFE05B64);
    final stateText = state == '0'
        ? languagesController.tr('PENDING')
        : state == '1'
        ? languagesController.tr('CONFIRMED')
        : languagesController.tr('REJECTED');
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 610),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: catpureKey,
                child: RepaintBoundary(
                  key: shareKey,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            color: stateColor.withOpacity(.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            state == '0'
                                ? Icons.schedule_rounded
                                : state == '1'
                                ? Icons.check_circle_outline_rounded
                                : Icons.cancel_outlined,
                            color: stateColor,
                            size: 29,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          stateText,
                          style: TextStyle(
                            color: stateColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _dialogRow(
                          languagesController.tr('BUNDLE_TITLE'),
                          bundletitle.toString(),
                          textColor,
                          muted,
                        ),
                        const SizedBox(height: 12),
                        _dialogRow(
                          languagesController.tr('PHONENUMBER'),
                          phoneNumber.toString(),
                          textColor,
                          muted,
                        ),
                        const SizedBox(height: 12),
                        _dialogRow(
                          languagesController.tr('SELLING_PRICE'),
                          '${sellingPrice.toString()} ${box.read('currency_code')?.toString() ?? ''}',
                          textColor,
                          muted,
                        ),
                        const SizedBox(height: 12),
                        _dialogRow(
                          languagesController.tr('ORDER_ID'),
                          orderId.toString(),
                          textColor,
                          muted,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              if (imagelink != null &&
                                  imagelink!.trim().isNotEmpty) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Image.network(
                                    imagelink!,
                                    height: 41,
                                    width: 41,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox(width: 41, height: 41),
                                  ),
                                ),
                                const SizedBox(width: 9),
                              ],
                              Expanded(
                                child: Column(
                                  children: [
                                    _dialogRow(
                                      languagesController.tr('DATE'),
                                      convertToDate(date.toString()),
                                      textColor,
                                      muted,
                                    ),
                                    const SizedBox(height: 6),
                                    _dialogRow(
                                      languagesController.tr('TIME'),
                                      convertToLocalTime(date.toString()),
                                      textColor,
                                      muted,
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
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => capturePng(catpureKey),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: border),
                    foregroundColor: textColor,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    languagesController.tr('SAVE_TO_GALLERY'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => captureImageFromWidgetAsFile(shareKey),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    languagesController.tr('SHARE'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                languagesController.tr('CLOSE'),
                style: TextStyle(color: muted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value, Color textColor, Color muted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: textColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
