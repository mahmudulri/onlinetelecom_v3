import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:onlinetelecom/controllers/add_selling_price_controller.dart';
import 'package:onlinetelecom/controllers/categories_controller.dart';
import 'package:onlinetelecom/controllers/only_service_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/models/service_category_model.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Online Telecom • Create Selling Price.
/// UI-only refresh. Original controllers, API calls and service selection flow
/// are retained. Designed to sit above the BaseScreen floating bottom nav.
class CreateSellingPriceScreen extends StatefulWidget {
  const CreateSellingPriceScreen({super.key});

  @override
  State<CreateSellingPriceScreen> createState() =>
      _CreateSellingPriceScreenState();
}

class _CreateSellingPriceScreenState extends State<CreateSellingPriceScreen> {
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final CategorisListController categorisListController =
      Get.find<CategorisListController>();
  final AddSellingPriceController addSellingPriceController = Get.put(
    AddSellingPriceController(),
  );
  final OnlyServiceController serviceController = Get.put(
    OnlyServiceController(),
  );
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final ThemeController themeController = Get.find<ThemeController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Map<String, String>> commissionType;

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
      _dark ? const Color(0xFF1D3829) : const Color(0xFFEAF8EE);

  @override
  void initState() {
    super.initState();
    commissionType = [
      {'name': languagesController.tr('PERCENTAGE'), 'value': 'percentage'},
      {'name': languagesController.tr('FIXED'), 'value': 'fixed'},
    ];

    if (serviceController.allservices.value.data?.services.isEmpty ?? true) {
      serviceController.fetchservices();
    }
    if (categorisListController
            .allcategorieslist
            .value
            .data
            ?.servicecategories
            ?.isEmpty ??
        true) {
      categorisListController.fetchcategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
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
          resizeToAvoidBottomInset: true,
          backgroundColor: _background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 20),
                    children: [
                      _buildSectionTitle(
                        languagesController.tr('AMOUNT'),
                        Icons.payments_outlined,
                      ),
                      const SizedBox(height: 9),
                      _buildAmountField(),
                      const SizedBox(height: 19),
                      _buildSectionTitle(
                        languagesController.tr('COMMISSION_TYPE'),
                        Icons.percent_rounded,
                      ),
                      const SizedBox(height: 9),
                      _buildCommissionSelector(),
                      const SizedBox(height: 19),
                      _buildSectionTitle(
                        languagesController.tr('SERVICE'),
                        Icons.widgets_outlined,
                      ),
                      const SizedBox(height: 9),
                      _buildServiceSelector(),
                      const SizedBox(height: 12),
                      _buildBottomAction(),
                      const SizedBox(height: 12),
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
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 42,
            height: 42,
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
    // Same button order/size as Network, Change Balance and Orders pages.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Directionality(
        textDirection: TextDirection.ltr,
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
                languagesController.tr('CREATE_SELLING_PRICE'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => _headerButton(
                tooltip: themeController.isDarkMode.value
                    ? 'Light mode'
                    : 'Dark mode',
                icon: themeController.isDarkMode.value
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                onTap: themeController.toggleTheme,
              ),
            ),
            const SizedBox(width: 9),
            _headerButton(
              tooltip: 'Menu',
              icon: Icons.menu_rounded,
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 29,
          height: 29,
          decoration: BoxDecoration(
            color: _softGreen,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: _accent, size: 16),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _fieldDecoration({bool selected = false}) {
    return BoxDecoration(
      color: _input,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: selected ? _accent.withOpacity(.65) : _border),
    );
  }

  Widget _buildAmountField() {
    return Container(
      height: 54,
      decoration: _fieldDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: _accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: addSellingPriceController.amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              cursorColor: _accent,
              style: TextStyle(
                color: _text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: languagesController.tr('ENTER_AMOUNT'),
                hintStyle: TextStyle(color: _muted, fontSize: 12.5),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionSelector() {
    return Obx(() {
      final selected =
          addSellingPriceController.commissiontype.value.isNotEmpty;
      final label = addSellingPriceController.commitype.value.toString();
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showCommissionTypeDialog,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 53,
            decoration: _fieldDecoration(selected: selected),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.percent_rounded, color: _accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label.isEmpty
                        ? languagesController.tr('COMMISSION_TYPE')
                        : label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? _text : _muted,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _muted,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildServiceSelector() {
    return Obx(() {
      final isSelected = addSellingPriceController.serviceidcontroller.text
          .trim()
          .isNotEmpty;
      final logo = addSellingPriceController.logolink.value.toString();
      final serviceName = addSellingPriceController.serviceName.value
          .toString();
      final category = addSellingPriceController.catName.value.toString();

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showServiceDialog,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 89),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _accent.withOpacity(.45) : _border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 57,
                  height: 57,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _softGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: isSelected
                      ? _companyLogo(logo, 27)
                      : Icon(Icons.apps_rounded, size: 25, color: _accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isSelected
                            ? serviceName
                            : languagesController.tr('SERVICE'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? _text : _muted,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                      if (isSelected && category.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _muted, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _softGreen,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    isSelected
                        ? Icons.edit_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _accent,
                    size: 19,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _companyLogo(String url, double iconSize) {
    if (url.isEmpty || url == 'null') {
      return Icon(Icons.business_rounded, color: _accent, size: iconSize);
    }
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.business_rounded, color: _accent, size: iconSize),
    );
  }

  Widget _buildBottomAction() {
    final media = MediaQuery.of(context);
    final keyboardVisible = media.viewInsets.bottom > 0;
    // BaseScreen uses an overlay bottom navigation with a raised center button.
    // Keep the form action above it, but avoid the extra gap with the keyboard.
    final bottomClearance = keyboardVisible
        ? 12.0
        : 76.0 + 38.0 + media.viewPadding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, bottomClearance),
      decoration: BoxDecoration(
        color: _background,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Obx(() {
        final loading = addSellingPriceController.isLoading.value;
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: loading ? null : _createSellingPrice,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              disabledBackgroundColor: _accent.withOpacity(.42),
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: loading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        languagesController.tr('PLEASE_WAIT'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 19),
                      const SizedBox(width: 9),
                      Flexible(
                        child: Text(
                          languagesController.tr('CREATE_NOW'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      }),
    );
  }

  void _createSellingPrice() {
    final hasAmount =
        addSellingPriceController.amountController.text.isNotEmpty;
    final hasCommissionType =
        addSellingPriceController.commissiontype.value.isNotEmpty;
    final hasService =
        addSellingPriceController.serviceidcontroller.text.isNotEmpty;

    if (hasAmount && hasCommissionType && hasService) {
      addSellingPriceController.createnow();
      return;
    }

    Fluttertoast.showToast(
      msg: languagesController.tr('FILL_DATA_CORRECTLY'),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16,
    );
  }

  void _showCommissionTypeDialog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Obx(() {
        // Observe the shared theme while the sheet is open.
        final isDark = themeController.isDarkMode.value;
        final sheetColor = isDark ? AppColors.darkCard : AppColors.lightSurface;
        final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
        final primaryText = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        return SafeArea(
          bottom: false,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              16,
              11,
              16,
              20 + MediaQuery.of(sheetContext).viewPadding.bottom,
            ),
            decoration: BoxDecoration(
              color: sheetColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              border: Border.all(color: border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 39,
                  height: 4,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        languagesController.tr('COMMISSION_TYPE'),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: primaryText,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: Icon(Icons.close_rounded, color: primaryText),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ...commissionType.map((item) {
                  final selected =
                      addSellingPriceController.commissiontype.value ==
                      item['value'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Material(
                      color: selected
                          ? (isDark
                                ? const Color(0xFF1D3829)
                                : const Color(0xFFEAF8EE))
                          : (isDark
                                ? AppColors.darkInputBackground
                                : const Color(0xFFF7FAF8)),
                      borderRadius: BorderRadius.circular(13),
                      child: InkWell(
                        onTap: () {
                          addSellingPriceController.commitype.value =
                              item['name'] ?? '';
                          addSellingPriceController.commissiontype.value =
                              item['value'] ?? '';
                          Navigator.pop(sheetContext);
                        },
                        borderRadius: BorderRadius.circular(13),
                        child: Container(
                          height: 54,
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: selected
                                  ? _accent.withOpacity(.5)
                                  : border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['value'] == 'percentage'
                                    ? Icons.percent_rounded
                                    : Icons.payments_outlined,
                                size: 19,
                                color: _accent,
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Text(
                                  item['name'] ?? '',
                                  style: TextStyle(
                                    color: primaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Icon(
                                selected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: selected ? _accent : border,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showServiceDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 38),
        child: const ServiceBox(),
      ),
    );
  }
}

/// Public widget preserved for callers elsewhere in the project.
class ServiceBox extends StatelessWidget {
  const ServiceBox({super.key});

  OnlyServiceController get serviceController =>
      Get.find<OnlyServiceController>();
  CategorisListController get categorisListController =>
      Get.find<CategorisListController>();
  AddSellingPriceController get addSellingPriceController =>
      Get.find<AddSellingPriceController>();
  LanguagesController get languagesController =>
      Get.find<LanguagesController>();
  ThemeController get themeController => Get.find<ThemeController>();

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
      final isDark = themeController.isDarkMode.value;
      final bg = isDark ? AppColors.darkCard : AppColors.lightSurface;
      final tile = isDark
          ? AppColors.darkInputBackground
          : const Color(0xFFF7FAF8);
      final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
      final text = isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary;
      final muted = isDark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary;
      final accent = AppColors.primaryColor;
      final services = serviceController.allservices.value.data?.services ?? [];

      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .76,
        ),
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(.11),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.apps_rounded, size: 20, color: accent),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    languagesController.tr('SERVICE'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: muted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: serviceController.isLoading.value
                  ? Center(child: CircularProgressIndicator(color: accent))
                  : services.isEmpty
                  ? Center(
                      child: Text(
                        languagesController.tr('NO_DATA_FOUND'),
                        style: TextStyle(color: muted, fontSize: 13),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, bounds) {
                        final columns = bounds.maxWidth < 320 ? 2 : 3;
                        return GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 5),
                          itemCount: services.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                mainAxisExtent: 129,
                              ),
                          itemBuilder: (context, index) {
                            final service = services[index];
                            final company = service.company;
                            final companyName =
                                company?.companyName?.toString() ?? '';
                            final logo = company?.companyLogo?.toString() ?? '';
                            final category = _categoryNameFor(
                              service.serviceCategoryId?.toString() ?? '',
                            );
                            final selectedId = addSellingPriceController
                                .serviceidcontroller
                                .text;
                            final selected =
                                selectedId == service.id.toString();
                            return Material(
                              color: selected
                                  ? (isDark
                                        ? const Color(0xFF1D3829)
                                        : const Color(0xFFEAF8EE))
                                  : tile,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  addSellingPriceController
                                      .serviceidcontroller
                                      .text = service.id
                                      .toString();
                                  addSellingPriceController.catName.value =
                                      category;
                                  addSellingPriceController.logolink.value =
                                      logo;
                                  addSellingPriceController.serviceName.value =
                                      companyName;
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? accent.withOpacity(.50)
                                          : border,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.darkCard
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: logo.isEmpty || logo == 'null'
                                            ? Icon(
                                                Icons.business_rounded,
                                                color: accent,
                                                size: 22,
                                              )
                                            : Image.network(
                                                logo,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                      Icons.business_rounded,
                                                      color: accent,
                                                      size: 22,
                                                    ),
                                              ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        companyName,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: text,
                                          height: 1.15,
                                          fontSize: 10.8,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      if (category.isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          category,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: muted,
                                            fontSize: 9.1,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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
