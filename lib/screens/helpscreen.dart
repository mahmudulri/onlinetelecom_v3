import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:onlinetelecom/controllers/help_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Help / Guide — compact FAQ accordion with Online Telecom Light/Dark theme.
/// Uses the existing HelpController and translation keys.
class Helpscreen extends StatefulWidget {
  const Helpscreen({super.key});

  @override
  State<Helpscreen> createState() => _HelpscreenState();
}

class _HelpscreenState extends State<Helpscreen> {
  final HelpController helpController = Get.find<HelpController>();
  final LanguagesController languagesController =
      Get.find<LanguagesController>();
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final ThemeController themeController = Get.find<ThemeController>();
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
  Color get _primary => AppColors.primaryColor;
  Color get _softGreen =>
      _dark ? const Color(0xFF1D3829) : const Color(0xFFEAF8EF);

  @override
  void initState() {
    super.initState();
    helpController.helpService();
  }

  Future<void> _refreshHelp() async {
    helpController.helpService();
    // helpService() is initiated by the existing controller.
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final bars = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: bars,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: const DrawerWidget(),
          backgroundColor: _background,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildHelpContent()),
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
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
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
      child: Row(
        children: [
          _headerButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onTap: mypagecontroller.goBack,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              languagesController.tr('GUIDE'),
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
            icon: _dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tooltip: _dark ? 'Light mode' : 'Dark mode',
            onTap: themeController.toggleTheme,
          ),
          const SizedBox(width: 9),
          _headerButton(
            icon: Icons.menu_rounded,
            tooltip: 'Menu',
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpContent() {
    return Obx(() {
      final articles = helpController.helpdata.value.data?.articles ?? [];
      final isLoading = helpController.isLoading.value;
      final media = MediaQuery.of(context);
      // Keep items clear of BaseScreen's raised bottom navigation button.
      final bottomClearance = media.viewInsets.bottom > 0
          ? 24.0
          : 76.0 + 38.0 + media.viewPadding.bottom;

      if (isLoading && articles.isEmpty) {
        return Center(
          child: CircularProgressIndicator(color: _primary, strokeWidth: 2.5),
        );
      }

      if (articles.isEmpty) {
        return RefreshIndicator(
          color: _primary,
          onRefresh: _refreshHelp,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 70, 16, bottomClearance),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _softGreen,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        Icons.menu_book_outlined,
                        color: _primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
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
        color: _primary,
        onRefresh: _refreshHelp,
        child: ListView.separated(
          key: const PageStorageKey<String>('help_faq_list'),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16, 5, 16, bottomClearance),
          itemCount: articles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 11),
          itemBuilder: (context, index) {
            final article = articles[index];
            return _HelpAccordionCard(
              key: ValueKey('help_article_$index'),
              number: index + 1,
              title: article.title?.toString() ?? '',
              description: article.description?.toString() ?? '',
              surface: _surface,
              background: _background,
              border: _border,
              textColor: _text,
              mutedColor: _muted,
              accentColor: _primary,
              accentSoftColor: _softGreen,
              dark: _dark,
            );
          },
        ),
      );
    });
  }
}

/// A compact Q/A item with its own animated expansion state.
class _HelpAccordionCard extends StatefulWidget {
  const _HelpAccordionCard({
    super.key,
    required this.number,
    required this.title,
    required this.description,
    required this.surface,
    required this.background,
    required this.border,
    required this.textColor,
    required this.mutedColor,
    required this.accentColor,
    required this.accentSoftColor,
    required this.dark,
  });

  final int number;
  final String title;
  final String description;
  final Color surface;
  final Color background;
  final Color border;
  final Color textColor;
  final Color mutedColor;
  final Color accentColor;
  final Color accentSoftColor;
  final bool dark;

  @override
  State<_HelpAccordionCard> createState() => _HelpAccordionCardState();
}

class _HelpAccordionCardState extends State<_HelpAccordionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasAnswer = widget.description.trim().isNotEmpty;
    return Material(
      color: widget.surface,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _expanded
                ? widget.accentColor.withOpacity(.34)
                : widget.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(widget.dark ? .08 : .025),
              blurRadius: _expanded ? 17 : 9,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: hasAnswer
                    ? () => setState(() => _expanded = !_expanded)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 13, 12, 13),
                  child: Row(
                    children: [
                      Container(
                        height: 43,
                        width: 43,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: widget.accentSoftColor,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(
                          widget.number.toString().padLeft(2, '0'),
                          style: TextStyle(
                            color: widget.accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: _expanded ? 5 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.textColor,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            height: 1.38,
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 31,
                        width: 31,
                        decoration: BoxDecoration(
                          color: _expanded
                              ? widget.accentColor
                              : widget.accentSoftColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: AnimatedRotation(
                          turns: _expanded ? .5 : 0,
                          duration: const Duration(milliseconds: 230),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 21,
                            color: _expanded
                                ? Colors.white
                                : widget.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                child: _expanded && hasAnswer
                    ? Column(
                        children: [
                          Divider(
                            color: widget.border,
                            height: 1,
                            thickness: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: widget.accentSoftColor,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    color: widget.accentColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Text(
                                    widget.description,
                                    style: TextStyle(
                                      color: widget.mutedColor,
                                      height: 1.65,
                                      fontSize: 12.7,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
