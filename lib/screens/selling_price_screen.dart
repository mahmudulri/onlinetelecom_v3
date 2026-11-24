import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:onlinetelecom/controllers/categories_controller.dart';
import 'package:onlinetelecom/controllers/delete_selling_price_controller.dart';
import 'package:onlinetelecom/controllers/only_service_controller.dart';
import 'package:onlinetelecom/controllers/selling_price_controller.dart';
import 'package:onlinetelecom/controllers/update_selling_price_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/models/service_category_model.dart';
import 'package:onlinetelecom/screens/create_selling_price_screen.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Colors used by this screen, its dialogs and the service picker.
/// Kept independent of the old turquoise palette.
class _SellingPalette {
  const _SellingPalette(this.isDark);

  final bool isDark;

  Color get background =>
      isDark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get surface => isDark ? AppColors.darkCard : AppColors.lightSurface;
  Color get input =>
      isDark ? AppColors.darkInputBackground : const Color(0xFFF5F9F6);
  Color get text =>
      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get muted =>
      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get border => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get primary => AppColors.primaryColor;
  Color get green => const Color(0xFF199A57);
  Color get softGreen =>
      isDark ? const Color(0xFF1B3628) : const Color(0xFFE9F7EF);
  Color get softRed =>
      isDark ? const Color(0xFF3D292B) : const Color(0xFFFFEFF0);
  Color get red => const Color(0xFFE45B62);
}

class SellingPriceScreen extends StatefulWidget {
  const SellingPriceScreen({super.key});

  @override
  State<SellingPriceScreen> createState() => _SellingPriceScreenState();
}

class _SellingPriceScreenState extends State<SellingPriceScreen> {
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final SellingPriceController sellingPriceController = Get.put(
    SellingPriceController(),
  );
  final UpdateSellingPriceController updateSellingPriceController = Get.put(
    UpdateSellingPriceController(),
  );
  final CategorisListController categorisListController =
      Get.find<CategorisListController>();
  final OnlyServiceController serviceController = Get.put(
    OnlyServiceController(),
  );
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final ThemeController themeController = Get.find<ThemeController>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  late final List<Map<String, String>> commissionType;
  String _query = '';

  _SellingPalette get _c => _SellingPalette(themeController.isDarkMode.value);

  @override
  void initState() {
    super.initState();
    commissionType = [
      {'name': languagesController.tr('PERCENTAGE'), 'value': 'percentage'},
      {'name': languagesController.tr('FIXED'), 'value': 'fixed'},
    ];
    categorisListController.fetchcategories();
    sellingPriceController.fetchpriceData();
    serviceController.fetchservices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    sellingPriceController.fetchpriceData();
    serviceController.fetchservices();
    categorisListController.fetchcategories();
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final c = _c;
      final dark = themeController.isDarkMode.value;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: c.background,
          systemNavigationBarIconBrightness: dark
              ? Brightness.light
              : Brightness.dark,
        ),
        child: Scaffold(
          key: _scaffoldKey,
          drawer: const DrawerWidget(),
          backgroundColor: c.background,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(c),
                _buildControls(c),
                const SizedBox(height: 12),
                Expanded(child: _buildPricingList(c)),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(_SellingPalette c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          _headerButton(
            c,
            Icons.arrow_back_rounded,
            'Back',
            () => mypagecontroller.goBack(),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              languagesController.tr('SELLING_PRICE'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: c.text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _headerButton(
            c,
            themeController.isDarkMode.value
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            'Change theme',
            themeController.toggleTheme,
          ),
          const SizedBox(width: 8),
          _headerButton(
            c,
            Icons.menu_rounded,
            'Menu',
            () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _headerButton(
    _SellingPalette c,
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            height: 42,
            width: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Icon(icon, color: c.text, size: 21),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(_SellingPalette c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              // Only the TextField paints the surface and border. There is no
              // outer decorated Container, so no nested/double background.
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value.trim()),
                cursorColor: c.green,
                textInputAction: TextInputAction.search,
                style: TextStyle(
                  color: c.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: c.surface,
                  hoverColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: c.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: c.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: c.green, width: 1.3),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: c.green,
                    size: 21,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 43,
                    minHeight: 42,
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: c.muted,
                            size: 18,
                          ),
                        ),
                  hintText: languagesController.tr('SEARCH'),
                  hintStyle: TextStyle(color: c.muted, fontSize: 12.5),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Material(
            color: c.primary,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => mypagecontroller.changePage(
                CreateSellingPriceScreen(),
                isMainPage: false,
              ),
              child: Container(
                height: 48,
                constraints: const BoxConstraints(maxWidth: 145),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        languagesController.tr('CREATE_NEW'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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
    );
  }

  Widget _buildPricingList(_SellingPalette c) {
    return Obx(() {
      final loading =
          sellingPriceController.isLoading.value ||
          serviceController.isLoading.value;
      final all =
          sellingPriceController.allpricelist.value.data?.pricings ?? [];

      if (loading && all.isEmpty) {
        return Center(child: CircularProgressIndicator(color: c.green));
      }

      final query = _query.toLowerCase();
      final visible = query.isEmpty
          ? all.toList()
          : all.where((item) {
              final service = _findServiceById(
                item.serviceId?.toString() ?? '',
              );
              final companyName =
                  service?.company?.companyName?.toString() ?? '';
              final category = _findCategoryName(
                item.service?.serviceCategoryId?.toString() ??
                    service?.serviceCategoryId?.toString() ??
                    '',
              );
              final commission = item.commissionType?.toString() ?? '';
              final searchableText = [
                companyName,
                category,
                commission,
                item.amount?.toString() ?? '',
              ].join(' ').toLowerCase();
              return searchableText.contains(query);
            }).toList();

      if (visible.isEmpty) {
        return RefreshIndicator(
          color: c.green,
          onRefresh: _refreshData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              70,
              16,
              110 + MediaQuery.of(context).viewPadding.bottom,
            ),
            children: [
              Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: c.softGreen,
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: Icon(
                      Icons.price_change_outlined,
                      size: 31,
                      color: c.green,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    languagesController.tr('NO_DATA_FOUND'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: c.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: c.green,
        onRefresh: _refreshData,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            2,
            16,
            114 + MediaQuery.of(context).viewPadding.bottom,
          ),
          itemCount: visible.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _buildPricingCard(visible[index], c),
        ),
      );
    });
  }

  Widget _buildPricingCard(dynamic data, _SellingPalette c) {
    final service = _findServiceById(data.serviceId?.toString() ?? '');
    final companyName = service?.company?.companyName?.toString() ?? '';
    final logo = service?.company?.companyLogo?.toString() ?? '';
    final categoryName = _findCategoryName(
      data.service?.serviceCategoryId?.toString() ??
          service?.serviceCategoryId?.toString() ??
          '',
    );
    final commission = data.commissionType?.toString() == 'percentage'
        ? languagesController.tr('PERCENTAGE')
        : languagesController.tr('FIXED');
    final amount = data.amount?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 9, 10),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(c.isDark ? 0.18 : 0.055),
            blurRadius: 11,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 45,
            width: 45,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: c.input,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: c.border),
            ),
            child: logo.trim().isNotEmpty && logo != 'null'
                ? Image.network(
                    logo,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.business_rounded, size: 22, color: c.green),
                  )
                : Icon(Icons.business_rounded, size: 22, color: c.green),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  companyName.isNotEmpty
                      ? companyName
                      : languagesController.tr('SERVICE'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (categoryName.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.muted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: c.softGreen,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    commission,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.green,
                      fontWeight: FontWeight.w700,
                      fontSize: 9.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          SizedBox(
            width: 94,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  languagesController.tr('AMOUNT'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.muted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 22,
                  width: 94,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        amount,
                        maxLines: 1,
                        style: TextStyle(
                          color: c.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionIcon(
                      c,
                      Icons.edit_outlined,
                      c.green,
                      c.softGreen,
                      'Edit',
                      () => _openUpdateDialog(data),
                    ),
                    const SizedBox(width: 6),
                    _actionIcon(
                      c,
                      Icons.delete_outline_rounded,
                      c.red,
                      c.softRed,
                      'Delete',
                      () => _showDeleteDialog(data.id?.toString() ?? ''),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(
    _SellingPalette c,
    IconData icon,
    Color color,
    Color background,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(
            height: 29,
            width: 32,
            child: Icon(icon, color: color, size: 17),
          ),
        ),
      ),
    );
  }

  dynamic _findServiceById(String serviceId) {
    try {
      return serviceController.allservices.value.data?.services.firstWhere(
        (service) => service.id.toString() == serviceId,
      );
    } catch (_) {
      return null;
    }
  }

  String _findCategoryName(String categoryId) {
    try {
      final category = categorisListController
          .allcategorieslist
          .value
          .data
          ?.servicecategories
          ?.firstWhere(
            (cat) => cat.id.toString() == categoryId,
            orElse: () => Servicecategory(categoryName: ''),
          );
      return category?.categoryName?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  // Initialize every form field from the clicked row. This avoids accidentally
  // updating an item with the previous item's service/commission selections.
  void _openUpdateDialog(dynamic data) {
    final service = _findServiceById(data.serviceId?.toString() ?? '');
    final type = data.commissionType?.toString() ?? 'fixed';

    updateSellingPriceController.amountController.text =
        data.amount?.toString() ?? '';
    updateSellingPriceController.commissiontype.value = type;
    updateSellingPriceController.commitype.value = type == 'percentage'
        ? languagesController.tr('PERCENTAGE')
        : languagesController.tr('FIXED');
    updateSellingPriceController.serviceidcontroller.text =
        data.serviceId?.toString() ?? '';
    updateSellingPriceController.serviceName.value =
        service?.company?.companyName?.toString() ?? '';
    updateSellingPriceController.logolink.value =
        service?.company?.companyLogo?.toString() ?? '';
    updateSellingPriceController.catName.value = _findCategoryName(
      data.service?.serviceCategoryId?.toString() ??
          service?.serviceCategoryId?.toString() ??
          '',
    );

    _showUpdateDialog(data);
  }

  void _showUpdateDialog(dynamic data) {
    showDialog(
      context: context,
      builder: (dialogContext) => Obx(() {
        final c = _c;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(dialogContext).size.height * .78,
            ),
            padding: const EdgeInsets.fromLTRB(17, 17, 17, 18),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: c.border),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 41,
                        height: 41,
                        decoration: BoxDecoration(
                          color: c.softGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit_note_rounded,
                          size: 24,
                          color: c.green,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          languagesController.tr('SELLING_PRICE'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: c.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: Icon(Icons.close_rounded, color: c.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _fieldTitle(c, languagesController.tr('AMOUNT')),
                  const SizedBox(height: 7),
                  Container(
                    height: 49,
                    decoration: BoxDecoration(
                      color: c.input,
                      border: Border.all(color: c.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: updateSellingPriceController.amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      cursorColor: c.green,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.payments_outlined,
                          color: c.green,
                          size: 20,
                        ),
                        hintText: languagesController.tr('ENTER_AMOUNT'),
                        hintStyle: TextStyle(color: c.muted, fontSize: 12),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _fieldTitle(c, languagesController.tr('COMMISSION_TYPE')),
                  const SizedBox(height: 7),
                  Material(
                    color: c.input,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _showCommissionTypeDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 49,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: c.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.tune_rounded, size: 19, color: c.green),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                updateSellingPriceController.commitype.value,
                                style: TextStyle(
                                  color: c.text,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: c.muted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  _fieldTitle(c, languagesController.tr('SERVICE')),
                  const SizedBox(height: 7),
                  Material(
                    color: c.input,
                    borderRadius: BorderRadius.circular(13),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(13),
                      onTap: () => showDialog(
                        context: dialogContext,
                        builder: (context) => Dialog(
                          insetPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 35,
                          ),
                          backgroundColor: Colors.transparent,
                          child: UpdateServiceBox(),
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          border: Border.all(color: c.border),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: c.surface,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: _serviceLogo(
                                updateSellingPriceController.logolink.value,
                                c,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    updateSellingPriceController
                                            .serviceName
                                            .value
                                            .isEmpty
                                        ? languagesController.tr('SERVICE')
                                        : updateSellingPriceController
                                              .serviceName
                                              .value,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: c.text,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (updateSellingPriceController
                                      .catName
                                      .value
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      updateSellingPriceController
                                          .catName
                                          .value,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: c.muted,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.swap_horiz_rounded,
                              color: c.green,
                              size: 23,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: c.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      onPressed: updateSellingPriceController.isLoading.value
                          ? null
                          : () {
                              if (updateSellingPriceController
                                      .amountController
                                      .text
                                      .trim()
                                      .isNotEmpty &&
                                  updateSellingPriceController
                                      .commissiontype
                                      .value
                                      .isNotEmpty &&
                                  updateSellingPriceController
                                      .serviceidcontroller
                                      .text
                                      .isNotEmpty) {
                                updateSellingPriceController.updatenow(
                                  data.id.toString(),
                                );
                              } else {
                                Fluttertoast.showToast(
                                  msg: languagesController.tr(
                                    'FILL_DATA_CORRECTLY',
                                  ),
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: c.red,
                                  textColor: Colors.white,
                                  fontSize: 14,
                                );
                              }
                            },
                      icon: updateSellingPriceController.isLoading.value
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 19,
                            ),
                      label: Text(
                        updateSellingPriceController.isLoading.value
                            ? languagesController.tr('PLEASE_WAIT')
                            : languagesController.tr('UPDATE_NOW'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _fieldTitle(_SellingPalette c, String label) {
    return Text(
      label,
      style: TextStyle(
        color: c.text,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _serviceLogo(String url, _SellingPalette c) {
    if (url.trim().isEmpty || url == 'null') {
      return Icon(Icons.business_outlined, size: 21, color: c.green);
    }
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.business_outlined, size: 21, color: c.green),
    );
  }

  void _showCommissionTypeDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Obx(() {
        final c = _c;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: c.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: commissionType.map((item) {
                final selected =
                    updateSellingPriceController.commissiontype.value ==
                    item['value'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Material(
                    color: selected ? c.softGreen : c.input,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        updateSellingPriceController.commitype.value =
                            item['name'] ?? '';
                        updateSellingPriceController.commissiontype.value =
                            item['value'] ?? '';
                        Navigator.pop(dialogContext);
                      },
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? c.green : c.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['name'] ?? '',
                                style: TextStyle(
                                  color: selected ? c.green : c.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (selected)
                              Icon(
                                Icons.check_circle_rounded,
                                size: 20,
                                color: c.green,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }),
    );
  }

  void _showDeleteDialog(String priceId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: DeleteDialog(priceID: priceId),
      ),
    );
  }
}

class DeleteDialog extends StatelessWidget {
  DeleteDialog({super.key, required this.priceID});

  final String priceID;
  final DeleteSellingPriceController controller = Get.put(
    DeleteSellingPriceController(),
  );
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final c = _SellingPalette(themeController.isDarkMode.value);
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(19, 23, 19, 19),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: c.softRed,
                borderRadius: BorderRadius.circular(21),
              ),
              child: Icon(Icons.delete_outline_rounded, color: c.red, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              languagesController.tr('DO_YOU_WANT_TO_DELETE'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.text,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: c.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              controller.deleteprice(priceID);
                              Navigator.pop(context);
                            },
                      child: Text(
                        controller.isLoading.value
                            ? languagesController.tr('PLEASE_WAIT')
                            : languagesController.tr('YES'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 45,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: c.border),
                        foregroundColor: c.text,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        languagesController.tr('NO'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class UpdateServiceBox extends StatelessWidget {
  UpdateServiceBox({super.key});

  final OnlyServiceController serviceController = Get.put(
    OnlyServiceController(),
  );
  final CategorisListController categorisListController =
      Get.find<CategorisListController>();
  final UpdateSellingPriceController updateSellingPriceController = Get.put(
    UpdateSellingPriceController(),
  );
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final ThemeController themeController = Get.find<ThemeController>();

  String _categoryNameFor(String categoryId) {
    try {
      final category = categorisListController
          .allcategorieslist
          .value
          .data
          ?.servicecategories
          ?.firstWhere(
            (cat) => cat.id.toString() == categoryId,
            orElse: () => Servicecategory(categoryName: ''),
          );
      return category?.categoryName?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final c = _SellingPalette(themeController.isDarkMode.value);
      final services = serviceController.allservices.value.data?.services ?? [];
      final loading = serviceController.isLoading.value;
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .75,
        ),
        padding: const EdgeInsets.fromLTRB(14, 15, 14, 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: c.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    color: c.softGreen,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(Icons.apps_rounded, color: c.green, size: 20),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    languagesController.tr('SERVICE'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: c.muted),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Flexible(
              child: loading
                  ? Center(child: CircularProgressIndicator(color: c.green))
                  : services.isEmpty
                  ? Center(
                      child: Text(
                        languagesController.tr('NO_DATA_FOUND'),
                        style: TextStyle(color: c.muted, fontSize: 13),
                      ),
                    )
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: services.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 9,
                            mainAxisSpacing: 9,
                            childAspectRatio: 1.42,
                          ),
                      itemBuilder: (context, index) {
                        final data = services[index];
                        final categoryName = _categoryNameFor(
                          data.serviceCategoryId?.toString() ?? '',
                        );
                        final companyLogo =
                            data.company?.companyLogo?.toString() ?? '';
                        final companyName =
                            data.company?.companyName?.toString() ?? '';
                        final isSelected =
                            updateSellingPriceController
                                .serviceidcontroller
                                .text ==
                            data.id.toString();
                        return Material(
                          color: isSelected ? c.softGreen : c.input,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              updateSellingPriceController
                                  .serviceidcontroller
                                  .text = data.id
                                  .toString();
                              updateSellingPriceController.catName.value =
                                  categoryName;
                              updateSellingPriceController.logolink.value =
                                  companyLogo;
                              updateSellingPriceController.serviceName.value =
                                  companyName;
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? c.green : c.border,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 38,
                                    width: 48,
                                    child:
                                        companyLogo.isNotEmpty &&
                                            companyLogo != 'null'
                                        ? Image.network(
                                            companyLogo,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.business_rounded,
                                              color: c.green,
                                              size: 24,
                                            ),
                                          )
                                        : Icon(
                                            Icons.business_rounded,
                                            color: c.green,
                                            size: 24,
                                          ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    companyName,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: c.text,
                                      fontSize: 11.2,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (categoryName.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      categoryName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: c.muted,
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }
}
