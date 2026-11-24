import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:onlinetelecom/controllers/hawala_currency_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Hawala rates: new ledger-style currency-pair cards.
/// Existing API, controller, translations and pull-to-refresh are preserved.
class HawalaCurrencyScreen extends StatefulWidget {
  const HawalaCurrencyScreen({super.key});

  @override
  State<HawalaCurrencyScreen> createState() => _HawalaCurrencyScreenState();
}

class _HawalaCurrencyScreenState extends State<HawalaCurrencyScreen> {
  final HawalaCurrencyController hawalaCurrencyController = Get.put(
    HawalaCurrencyController(),
  );
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final ThemeController themeController = Get.find<ThemeController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get _dark => themeController.isDarkMode.value;
  Color get _background =>
      _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _secondarySurface =>
      _dark ? AppColors.darkInputBackground : const Color(0xFFF6FAF7);
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _primary => AppColors.primaryColor;
  Color get _softGreen =>
      _dark ? const Color(0xFF1D3929) : const Color(0xFFEAF8EF);

  static const Color _buyGreen = Color(0xFF16965A);
  static const Color _sellAmber = Color(0xFFCF8A20);

  @override
  void initState() {
    super.initState();
    hawalaCurrencyController.fetchcurrency();
  }

  Future<void> _refreshRates() async {
    hawalaCurrencyController.fetchcurrency();
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final systemBars = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemBars,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: const DrawerWidget(),
          backgroundColor: _background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                _buildListToolbar(),
                const SizedBox(height: 4),
                Expanded(child: _buildRatesList()),
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
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _text, size: 21),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
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
              languagesController.tr('HAWALA_RATES'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -.25,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _headerButton(
            icon: themeController.isDarkMode.value
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            onTap: themeController.toggleTheme,
            tooltip: themeController.isDarkMode.value
                ? 'Light mode'
                : 'Dark mode',
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

  /// Compact section heading, not an intro/banner card.
  Widget _buildListToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(17, 5, 17, 12),
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
            child: Icon(
              Icons.currency_exchange_rounded,
              color: _primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              languagesController.tr('EXCHANGE_RATE'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: _text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Material(
            color: _secondarySurface,
            borderRadius: BorderRadius.circular(11),
            child: InkWell(
              onTap: hawalaCurrencyController.fetchcurrency,
              borderRadius: BorderRadius.circular(11),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: _border),
                ),
                child: Icon(Icons.refresh_rounded, color: _primary, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatesList() {
    return Obx(() {
      final rates =
          hawalaCurrencyController.allcurrencylist.value.data?.rates ?? [];

      if (hawalaCurrencyController.isLoading.value && rates.isEmpty) {
        return Center(child: CircularProgressIndicator(color: _primary));
      }

      if (rates.isEmpty) {
        return RefreshIndicator(
          color: _primary,
          onRefresh: _refreshRates,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 65, 18, 130),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: _softGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.currency_exchange_outlined,
                        size: 31,
                        color: _primary,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      languagesController.tr('NO_DATA_FOUND'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      final media = MediaQuery.of(context);
      final bottomClearance = 76.0 + 38.0 + media.viewPadding.bottom;

      return RefreshIndicator(
        color: _primary,
        onRefresh: _refreshRates,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16, 1, 16, bottomClearance + 20),
          itemCount: rates.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildRateCard(rates[index]),
        ),
      );
    });
  }

  Widget _buildRateCard(dynamic data) {
    final fromName = data.fromCurrency?.name?.toString() ?? '';
    final fromSymbol = data.fromCurrency?.symbol?.toString() ?? '';
    final toName = data.toCurrency?.name?.toString() ?? '';
    final toSymbol = data.toCurrency?.symbol?.toString() ?? '';
    final amount = data.amount?.toString() ?? '';
    final buying = data.buyRate?.toString() ?? '';
    final selling = data.sellRate?.toString() ?? '';

    final sourcePrimary = amount.isNotEmpty
        ? [amount, fromSymbol].where((e) => e.isNotEmpty).join(' ')
        : fromSymbol;
    final sourceSecondary = fromName.isNotEmpty ? fromName : fromSymbol;
    final destinationPrimary = toSymbol.isNotEmpty ? toSymbol : toName;
    final destinationSecondary = toName.isNotEmpty ? toName : toSymbol;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .08 : .03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 4,
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: _currencyColumn(
                    main: sourcePrimary,
                    subtitle: sourceSecondary,
                    align: CrossAxisAlignment.start,
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _softGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primary.withOpacity(.12)),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: _primary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: _currencyColumn(
                    main: destinationPrimary,
                    subtitle: destinationSecondary,
                    align: CrossAxisAlignment.end,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: _secondarySurface,
              border: Border(top: BorderSide(color: _border)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Column(
              children: [
                _buildRateRow(
                  icon: Icons.south_west_rounded,
                  label: languagesController.tr('BUYING'),
                  rate: buying,
                  symbol: toSymbol,
                  accent: _buyGreen,
                ),
                Divider(color: _border, height: 1),
                _buildRateRow(
                  icon: Icons.north_east_rounded,
                  label: languagesController.tr('SELLING'),
                  rate: selling,
                  symbol: toSymbol,
                  accent: _sellAmber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _currencyColumn({
    required String main,
    required String subtitle,
    required CrossAxisAlignment align,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          main.isEmpty ? '—' : main,
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _text,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -.35,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: textAlign,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _muted,
            fontSize: 10.5,
            height: 1.25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRateRow({
    required IconData icon,
    required String label,
    required String rate,
    required String symbol,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withOpacity(_dark ? .16 : .09),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              [
                rate.isEmpty ? '—' : rate,
                symbol,
              ].where((part) => part.isNotEmpty).join(' '),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: accent,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
