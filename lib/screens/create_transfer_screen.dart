import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:onlinetelecom/controllers/add_selling_price_controller.dart';
import 'package:onlinetelecom/controllers/categories_controller.dart';
import 'package:onlinetelecom/controllers/create_transfer_controller.dart';
import 'package:onlinetelecom/controllers/dashboard_controller.dart';
import 'package:onlinetelecom/controllers/only_service_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/models/service_category_model.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Online Telecom — Create Commission Transfer.
/// All existing transfer controllers, commission amount and submission logic
/// are retained. The action scrolls with the form above BaseScreen navigation.
class CreateTransferScreen extends StatefulWidget {
  const CreateTransferScreen({super.key});

  @override
  State<CreateTransferScreen> createState() => _CreateTransferScreenState();
}

class _CreateTransferScreenState extends State<CreateTransferScreen> {
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final CreateTransferController controller = Get.put(
    CreateTransferController(),
  );
  final ThemeController themeController = Get.find<ThemeController>();
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
      _dark ? const Color(0xFF1D3829) : const Color(0xFFEAF8EE);

  @override
  void initState() {
    super.initState();
    // Exactly as in the original screen: start a new request with no amount.
    controller.amountController.clear();
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
      final media = MediaQuery.of(context);
      // The enclosing BaseScreen draws a 76px bottom bar plus a raised
      // central action button above the body (extendBody: true).
      // Keep enough *scrollable* clearance instead of fixing Submit at bottom.
      final bottomClearance = media.viewInsets.bottom > 0
          ? 22.0
          : 76.0 + 38.0 + media.viewPadding.bottom;

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
                    padding: EdgeInsets.fromLTRB(16, 2, 16, bottomClearance),
                    children: [_buildTransferForm()],
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
                languagesController.tr('CREATE_TRANSFER_REQUEST'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.35,
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

  Widget _buildTransferForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 16, 15, 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .06 : .025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _softGreen,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(Icons.payments_outlined, color: _accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  languagesController.tr('AMOUNT'),
                  style: TextStyle(
                    color: _text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            languagesController.tr('AMOUNT'),
            style: TextStyle(
              color: _muted,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _buildAmountBox(),
          const SizedBox(height: 13),
          _buildAvailableCommissionCard(),
          const SizedBox(height: 19),
          _buildCreateButton(),
        ],
      ),
    );
  }

  Widget _buildAmountBox() {
    return Container(
      height: 57,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: _input,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: _accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              textInputAction: TextInputAction.done,
              cursorColor: _accent,
              style: TextStyle(
                color: _text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                hintText: languagesController.tr('AMOUNT'),
                hintStyle: TextStyle(
                  color: _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                filled: false,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableCommissionCard() {
    return Obx(() {
      // Same source of truth and ALL-fill behavior as the original screen.
      final totalEarning =
          dashboardController
              .alldashboardData
              .value
              .data
              ?.userInfo
              ?.totalearning
              ?.toString() ??
          '0';
      return Container(
        padding: const EdgeInsets.fromLTRB(13, 13, 11, 13),
        decoration: BoxDecoration(
          color: _softGreen,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _accent.withOpacity(.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _accent.withOpacity(.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(Icons.savings_outlined, size: 20, color: _accent),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                totalEarning,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: _accent,
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                onTap: () {
                  controller.amountController.text = totalEarning;
                  controller.amountController.selection =
                      TextSelection.fromPosition(
                        TextPosition(
                          offset: controller.amountController.text.length,
                        ),
                      );
                },
                borderRadius: BorderRadius.circular(11),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Text(
                    languagesController.tr('ALL'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCreateButton() {
    return Obx(() {
      final busy = controller.isLoading.value;
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: busy ? null : _submitTransfer,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _accent.withOpacity(.45),
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: busy
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        languagesController.tr('PLEASE_WAIT'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
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
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  // Preserve original validation and transfer submission behavior.
  void _submitTransfer() {
    if (controller.amountController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: languagesController.tr('FILL_DATA_CORRECTLY'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16,
      );
      return;
    }
    controller.createnow();
  }
}

/// Public widget preserved for callers elsewhere in the project.
class ServiceBox extends StatelessWidget {
  ServiceBox({super.key});

  final OnlyServiceController serviceController = Get.put(
    OnlyServiceController(),
  );
  final CategorisListController categorisListController =
      Get.find<CategorisListController>();
  final AddSellingPriceController addSellingPriceController = Get.put(
    AddSellingPriceController(),
  );
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
