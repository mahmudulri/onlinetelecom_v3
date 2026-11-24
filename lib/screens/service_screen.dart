import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:onlinetelecom/controllers/service_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

import 'social_bundles.dart';

/// Online Telecom — compact, light/dark-aware service selection.
/// The existing fetch, refresh, company selection and SocialBundles flow
/// are deliberately kept unchanged.
class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final ServiceController serviceController = Get.find<ServiceController>();
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

  Color get _softSurface =>
      _dark ? AppColors.darkInputBackground : const Color(0xFFF0F8F2);

  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;

  Color get _accent => AppColors.primaryColor;

  @override
  void initState() {
    super.initState();
    serviceController.fetchservices();
  }

  Future<void> _refreshServices() async {
    serviceController.fetchservices();
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  @override
  Widget build(BuildContext context) {
    // Observing the shared theme here updates the entire screen immediately.
    return Obx(() {
      final isDarkMode = themeController.isDarkMode.value;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: _background,
          systemNavigationBarIconBrightness: isDarkMode
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
                const SizedBox(height: 7),
                Expanded(child: _buildServiceGrid()),
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
          _headerAction(
            tooltip: 'Back',
            icon: Icons.arrow_back_rounded,
            onTap: mypagecontroller.goBack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              languagesController.tr('SERVICES'),
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
          _headerAction(
            tooltip: themeController.isDarkMode.value
                ? 'Light mode'
                : 'Dark mode',
            icon: themeController.isDarkMode.value
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            onTap: themeController.toggleTheme,
          ),
          const SizedBox(width: 8),
          _headerAction(
            tooltip: 'Menu',
            icon: Icons.menu_rounded,
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _headerAction({
    required String tooltip,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _border),
            ),
            child: Icon(icon, color: _text, size: 21),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceGrid() {
    final media = MediaQuery.of(context);
    // Leaves space below the last row for apps with a bottom navigation bar.
    final bottomPadding = media.viewInsets.bottom > 0
        ? 20.0
        : 90.0 + media.viewPadding.bottom;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        if (serviceController.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: _accent));
        }

        // Keep the original data source (allserviceslist, not allservices).
        final services =
            serviceController.allserviceslist.value.data?.services ?? [];

        if (services.isEmpty) {
          return RefreshIndicator(
            color: _accent,
            onRefresh: _refreshServices,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(0, 85, 0, bottomPadding),
              children: [
                Center(
                  child: Container(
                    width: 66,
                    height: 66,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _softSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _border),
                    ),
                    child: Icon(Icons.apps_outlined, color: _accent, size: 29),
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
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 520
                ? 4
                : constraints.maxWidth >= 340
                ? 3
                : 2;

            return RefreshIndicator(
              color: _accent,
              onRefresh: _refreshServices,
              child: GridView.builder(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(1, 2, 1, bottomPadding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  mainAxisExtent: 119,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return _buildServiceCard(services[index]);
                },
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildServiceCard(dynamic data) {
    final companyName = data.company?.companyName?.toString() ?? '';
    final logo = data.company?.companyLogo?.toString() ?? '';
    final hasLogo = logo.trim().isNotEmpty && logo != 'null';

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: _dark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF164B2B).withOpacity(.045),
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // Preserve the exact existing company selection and navigation.
            box.write('company_id', data.companyId);
            mypagecontroller.changePage(
              const SocialBundles(),
              isMainPage: false,
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(7, 9, 7, 8),
            child: Column(
              children: [
                Container(
                  height: 62,
                  width: 62,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _softSurface,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: hasLogo
                      ? CachedNetworkImage(
                          imageUrl: logo,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: _accent,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.sim_card_outlined,
                            color: _accent,
                            size: 27,
                          ),
                        )
                      : Icon(Icons.sim_card_outlined, color: _accent, size: 27),
                ),
                const SizedBox(height: 7),
                Expanded(
                  child: Center(
                    child: Text(
                      companyName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _text,
                        fontSize: 10.5,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                      ),
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
}
