import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:onlinetelecom/controllers/add_commsion_group_controller.dart';
import 'package:onlinetelecom/controllers/commission_group_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Online Telecom — redesigned commission-group management screen.
/// Uses the same global ThemeController as the Network/Orders screens.
class CommissionGroupScreen extends StatefulWidget {
  const CommissionGroupScreen({super.key});

  @override
  State<CommissionGroupScreen> createState() => _CommissionGroupScreenState();
}

class _CommissionGroupScreenState extends State<CommissionGroupScreen> {
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final CommissionGroupController commissionlistController =
      Get.find<CommissionGroupController>();
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final ThemeController themeController = Get.find<ThemeController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  bool get _dark => themeController.isDarkMode.value;
  Color get _bg => _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _input =>
      _dark ? AppColors.darkInputBackground : const Color(0xFFF5F9F6);
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _primary => AppColors.primaryColor;
  Color get _accentSoft =>
      _dark ? const Color(0xFF20392A) : const Color(0xFFEAF8EF);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
    commissionlistController.fetchGrouplist();
  }

  void _onSearch() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshGroups() async {
    commissionlistController.fetchGrouplist();
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = themeController.isDarkMode.value;
      final overlay = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _bg,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay,
        child: Scaffold(
          key: _scaffoldKey,
          drawer: const DrawerWidget(),
          resizeToAvoidBottomInset: true,
          backgroundColor: _bg,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                _buildToolbar(),
                const SizedBox(height: 15),
                Expanded(child: _buildGroupList()),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            _headerIcon(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onTap: mypagecontroller.goBack,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                languagesController.tr('COMMISSION_GROUP'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: 19,
                  letterSpacing: -.35,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 7),
            // Exact shared theme behavior used in the Network header.
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
              icon: Icons.menu_rounded,
              tooltip: 'Menu',
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // New, minimal dashboard strip displaying real fetched group count.
          Obx(() {
            final groups =
                commissionlistController.allgrouplist.value.data?.groups ?? [];
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: _accentSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.hub_outlined, color: _primary, size: 20),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      languagesController.tr('COMMISSION_GROUP'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _accentSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${groups.length}',
                      style: TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 11),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 49,
                    decoration: BoxDecoration(
                      color: _input,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      cursorColor: _primary,
                      style: TextStyle(
                        color: _text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: languagesController.tr('SEARCH'),
                        hintStyle: TextStyle(color: _muted, fontSize: 12.5),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: _primary,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                tooltip: 'Clear',
                                onPressed: _searchController.clear,
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: _muted,
                                  size: 17,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showCreateGroupDialog,
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      height: 49,
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF16A34A), Color(0xFF0D7C3B)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                          const SizedBox(width: 5),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 100),
                            child: Text(
                              languagesController.tr('CREATE_NEW'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
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
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList() {
    return Obx(() {
      final isLoading = commissionlistController.isLoading.value;
      final groups =
          commissionlistController.allgrouplist.value.data?.groups ?? [];
      final query = _searchController.text.trim().toLowerCase();
      final filtered = groups.where((group) {
        if (query.isEmpty) return true;
        final name = group.groupName?.toString().toLowerCase() ?? '';
        final type = group.commissionType?.toString().toLowerCase() ?? '';
        final amount = group.amount?.toString().toLowerCase() ?? '';
        return name.contains(query) ||
            type.contains(query) ||
            amount.contains(query);
      }).toList();

      if (isLoading && groups.isEmpty) {
        return Center(child: CircularProgressIndicator(color: _primary));
      }

      if (filtered.isEmpty) {
        return RefreshIndicator(
          onRefresh: _refreshGroups,
          color: _primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 40),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 58,
                      width: 58,
                      decoration: BoxDecoration(
                        color: _accentSoft,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Icon(
                        query.isNotEmpty
                            ? Icons.search_off_rounded
                            : Icons.groups_2_outlined,
                        color: _primary,
                        size: 27,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      languagesController.tr('NO_DATA_FOUND'),
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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
        onRefresh: _refreshGroups,
        color: _primary,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 9),
          itemBuilder: (_, index) => _buildGroupCard(filtered[index]),
        ),
      );
    });
  }

  Widget _buildGroupCard(dynamic group) {
    final name = group.groupName?.toString() ?? '';
    final commissionType = group.commissionType?.toString() ?? '';
    final percentage = commissionType.toLowerCase() == 'percentage';
    final typeLabel = percentage
        ? languagesController.tr('PERCENTAGE')
        : commissionType;
    final amount = group.amount?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .075 : .025),
            blurRadius: 11,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: _accentSoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                percentage ? Icons.percent_rounded : Icons.wallet_outlined,
                color: _primary,
                size: 23,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _text,
                      fontSize: 13.7,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          typeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _muted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 9),
            Container(
              constraints: const BoxConstraints(minWidth: 67, maxWidth: 110),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: _input,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    languagesController.tr('AMOUNT'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    percentage ? '$amount%' : amount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        elevation: 0,
        child: CreateGroupBox(),
      ),
    );
  }
}

/// Create-group modal — existing controller field names and API are preserved.
class CreateGroupBox extends StatefulWidget {
  const CreateGroupBox({super.key});

  @override
  State<CreateGroupBox> createState() => _CreateGroupBoxState();
}

class _CreateGroupBoxState extends State<CreateGroupBox> {
  final AddCommsionGroupController addCommsionGroupController = Get.put(
    AddCommsionGroupController(),
  );
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final ThemeController themeController = Get.find<ThemeController>();

  late final List<Map<String, String>> commissionType;

  bool get _dark => themeController.isDarkMode.value;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _input =>
      _dark ? AppColors.darkInputBackground : const Color(0xFFF5F9F6);
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _primary => AppColors.primaryColor;
  Color get _softGreen =>
      _dark ? const Color(0xFF20392A) : const Color(0xFFEAF8EF);

  @override
  void initState() {
    super.initState();
    commissionType = [
      {'name': languagesController.tr('PERCENTAGE'), 'value': 'percentage'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Observing the global flag makes the dialog theme reactive too.
      final dark = themeController.isDarkMode.value;
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .82,
        ),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkCard : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _border),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeading(),
              const SizedBox(height: 20),
              _fieldLabel(languagesController.tr('GROUP_NAME')),
              const SizedBox(height: 7),
              _buildInput(
                controller: addCommsionGroupController.nameController,
                hint: languagesController.tr('ENTER_GROUP_NAME'),
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 15),
              _fieldLabel(languagesController.tr('COMMISSION_TYPE')),
              const SizedBox(height: 7),
              _commissionSelector(),
              const SizedBox(height: 15),
              _fieldLabel(languagesController.tr('AMOUNT')),
              const SizedBox(height: 7),
              _buildInput(
                controller: addCommsionGroupController.amountController,
                hint: languagesController.tr('ENTER_AMOUNT_OR_VALUE'),
                icon: Icons.percent_rounded,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 21),
              _buildDialogActions(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDialogHeading() {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: _softGreen,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(Icons.add_card_rounded, color: _primary, size: 22),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                languagesController.tr('CREATE_NEW'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                languagesController.tr('COMMISSION_GROUP'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
        Material(
          color: _input,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: _closeDialog,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 34,
              width: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.close_rounded, size: 19, color: _muted),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) => Text(
    label,
    style: TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w700),
  );

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 51,
      decoration: BoxDecoration(
        color: _input,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        cursorColor: _primary,
        style: TextStyle(
          color: _text,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _muted, fontSize: 12.5),
          prefixIcon: Icon(icon, color: _primary, size: 19),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _commissionSelector() {
    return Material(
      color: _input,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: _showCommissionTypeDialog,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 51,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Icon(Icons.percent_rounded, color: _primary, size: 21),
              const SizedBox(width: 11),
              Expanded(
                child: Obx(() {
                  final value = addCommsionGroupController.commitype.value;
                  return Text(
                    value.isEmpty
                        ? languagesController.tr('COMMISSION_TYPE')
                        : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: value.isEmpty ? _muted : _text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: _muted, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommissionTypeDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: _surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: commissionType.map((item) {
              return Material(
                color: _input,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    addCommsionGroupController.commitype.value =
                        item['name'] ?? '';
                    addCommsionGroupController.commissiontype.value =
                        item['value'] ?? '';
                    Navigator.pop(dialogContext);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 51,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    child: Row(
                      children: [
                        Icon(Icons.percent_rounded, color: _primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item['name'] ?? '',
                            style: TextStyle(
                              color: _text,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (addCommsionGroupController.commissiontype.value ==
                            item['value'])
                          Icon(
                            Icons.check_circle_rounded,
                            color: _primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogActions() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: _closeDialog,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(
                languagesController.tr('CANCEL'),
                style: TextStyle(
                  color: _text,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 48,
            child: Obx(() {
              final loading = addCommsionGroupController.isLoading.value;
              return ElevatedButton(
                onPressed: loading ? null : _createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  disabledBackgroundColor: _primary.withOpacity(.45),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  elevation: 0,
                ),
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        languagesController.tr('CREATE_NOW'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
              );
            }),
          ),
        ),
      ],
    );
  }

  void _createGroup() {
    final hasName = addCommsionGroupController.nameController.text
        .trim()
        .isNotEmpty;
    final hasAmount = addCommsionGroupController.amountController.text
        .trim()
        .isNotEmpty;
    final hasCommissionType =
        addCommsionGroupController.commissiontype.value.isNotEmpty;
    if (hasName && hasAmount && hasCommissionType) {
      // Preserve the project's existing API request and post-submit behavior.
      addCommsionGroupController.createnow();
    }
  }

  void _closeDialog() {
    addCommsionGroupController.nameController.clear();
    addCommsionGroupController.amountController.clear();
    addCommsionGroupController.commissiontype.value = '';
    addCommsionGroupController.commitype.value = '';
    Navigator.pop(context);
  }
}
