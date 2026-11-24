import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:onlinetelecom/controllers/bundle_controller.dart';
import 'package:onlinetelecom/controllers/country_list_controller.dart';
import 'package:onlinetelecom/controllers/service_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/models/country_list_model.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

import 'recharge_screen.dart';

/// Online Telecom — simple country selection with the shared light/dark theme.
/// The existing country selection, local storage and RechargeScreen flow
/// are retained without changes to the API controllers.
class InternetPack extends StatefulWidget {
  const InternetPack({super.key});

  @override
  State<InternetPack> createState() => _InternetPackState();
}

class _InternetPackState extends State<InternetPack> {
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final CountryListController countrylistController = Get.put(
    CountryListController(),
  );
  final BundleController bundleController = Get.put(BundleController());
  final ServiceController serviceController = Get.put(ServiceController());
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
  Color get _accent => AppColors.primaryColor;
  Color get _softGreen =>
      _dark ? const Color(0xFF1C3828) : const Color(0xFFEAF8EF);

  Future<void> _refreshCountries() async {
    await countrylistController.fetchCountryData();
  }

  @override
  Widget build(BuildContext context) {
    // Observing this Rx ensures cards and system bars also switch immediately.
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
                _buildIntroduction(),
                const SizedBox(height: 15),
                Expanded(child: _buildCountryList()),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _headerIcon({
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 15),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            _headerIcon(
              tooltip: 'Back',
              icon: Icons.arrow_back_rounded,
              onTap: mypagecontroller.goBack,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                languagesController.tr('COUNTRY_SELECTION'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.35,
                  color: _text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Match the working theme button on Network and Orders.
            Obx(
              () => _headerIcon(
                tooltip: themeController.isDarkMode.value
                    ? 'Light mode'
                    : 'Dark mode',
                onTap: themeController.toggleTheme,
                icon: themeController.isDarkMode.value
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
            ),
            const SizedBox(width: 9),
            _headerIcon(
              tooltip: 'Menu',
              icon: Icons.menu_rounded,
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF16A34A), Color(0xFF0B7836)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.public_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                languagesController.tr('BOOKING_FOR'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryList() {
    return Obx(() {
      if (countrylistController.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: _accent));
      }

      final List<Country> countries = countrylistController.finalCountryList;

      if (countries.isEmpty) {
        return RefreshIndicator(
          color: _accent,
          onRefresh: _refreshCountries,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 25, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 46),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _softGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.public_off_rounded,
                        color: _accent,
                        size: 29,
                      ),
                    ),
                    const SizedBox(height: 13),
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
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: _accent,
        onRefresh: _refreshCountries,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 340;
            return GridView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 26),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: twoColumns ? 2 : 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: twoColumns ? 163 : 91,
              ),
              itemCount: countries.length,
              itemBuilder: (context, index) =>
                  _buildCountryCard(countries[index], compact: !twoColumns),
            );
          },
        ),
      );
    });
  }

  Widget _flag(String url, {required double size}) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: _softGreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withOpacity(.13)),
      ),
      child: url.isEmpty || url == 'null'
          ? Icon(Icons.flag_outlined, size: size * .45, color: _accent)
          : Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.flag_outlined, size: size * .45, color: _accent),
            ),
    );
  }

  Widget _buildCountryCard(Country data, {required bool compact}) {
    final flagUrl = data.countryFlagImageUrl?.toString() ?? '';
    final countryName = data.countryName ?? '';

    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: () => _selectCountry(data),
        borderRadius: BorderRadius.circular(17),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_dark ? .065 : .018),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 9,
            vertical: compact ? 10 : 13,
          ),
          child: compact
              ? Row(
                  children: [
                    _flag(flagUrl, size: 55),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        countryName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _text,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _accent,
                      size: 15,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _flag(flagUrl, size: 58),
                    const SizedBox(height: 9),
                    Expanded(
                      child: Center(
                        child: Text(
                          countryName,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _text,
                            fontSize: 12.8,
                            height: 1.18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Icon(Icons.arrow_forward_rounded, size: 17, color: _accent),
                  ],
                ),
        ),
      ),
    );
  }

  void _selectCountry(Country selectedCountry) {
    final enableOperatorLookup = selectedCountry.enableOperatorLookup;

    box.write('country_id', selectedCountry.id);
    box.write('countryName', selectedCountry.countryName ?? '');
    box.write('maxlength', selectedCountry.phoneNumberLength ?? '');
    box.write('enable_operator_lookup', enableOperatorLookup);
    box.write('validity_type', '');
    box.write('company_id', '');
    box.write('search_tag', '');

    serviceController.reserveDigit.clear();
    bundleController.resetBundles();

    mypagecontroller.changePage(
      RechargeScreen(enableOperatorLookup: enableOperatorLookup),
      isMainPage: false,
    );
  }
}
