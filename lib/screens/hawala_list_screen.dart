import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:onlinetelecom/controllers/branch_controller.dart';
import 'package:onlinetelecom/controllers/hawala_cancel_controller.dart';
import 'package:onlinetelecom/controllers/hawala_list_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/helpers/capture_image_helper.dart';
import 'package:onlinetelecom/helpers/share_image_helper.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

import 'create_hawala_screen.dart';

class HawalaListScreen extends StatefulWidget {
  const HawalaListScreen({super.key});

  @override
  State<HawalaListScreen> createState() => _HawalaListScreenState();
}

class _HawalaListScreenState extends State<HawalaListScreen> {
  final HawalaListController hawalalistController =
      Get.find<HawalaListController>();
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final BranchController branchController = Get.put(BranchController());
  final ThemeController themeController = Get.find<ThemeController>();
  final ScrollController scrollController = ScrollController();
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
  Color get _softGreen =>
      _dark ? const Color(0xFF1E3829) : const Color(0xFFEAF8EF);
  Color get _accent => AppColors.primaryColor;

  @override
  void initState() {
    super.initState();
    hawalalistController.finalList.clear();
    hawalalistController.initialpage = 1;
    hawalalistController.fetchhawala();
    branchController.fetchallbranch();
    scrollController.addListener(_loadMoreHawala);
  }

  @override
  void dispose() {
    scrollController.removeListener(_loadMoreHawala);
    scrollController.dispose();
    super.dispose();
  }

  void _loadMoreHawala() {
    if (!scrollController.hasClients || hawalalistController.isLoading.value) {
      return;
    }
    final pagination =
        hawalalistController.allhawalalist.value.data?.pagination;
    final totalPages = pagination?.totalPages ?? 0;
    if (totalPages <= 0 || hawalalistController.initialpage >= totalPages) {
      return;
    }
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 80) {
      hawalalistController.initialpage++;
      hawalalistController.fetchhawala();
    }
  }

  Future<void> _refreshHawala() async {
    hawalalistController.finalList.clear();
    hawalalistController.initialpage = 1;
    hawalalistController.fetchhawala();
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
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                _buildNewOrderButton(),
                const SizedBox(height: 10),
                Expanded(child: _buildHawalaList()),
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
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
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
            onTap: mypagecontroller.goBack,
            tooltip: 'Back',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              languagesController.tr('HAWALA_ORDER_LIST'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _headerButton(
            icon: isDarkIcon(),
            onTap: themeController.toggleTheme,
            tooltip: _dark ? 'Light mode' : 'Dark mode',
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

  IconData isDarkIcon() =>
      _dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded;

  Widget _buildNewOrderButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => mypagecontroller.changePage(
            const HawalaScreen(),
            isMainPage: false,
          ),
          icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
          label: Text(
            languagesController.tr('NEW_ORDER'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHawalaList() {
    return Obx(() {
      final list = hawalalistController.finalList;
      if (hawalalistController.isLoading.value && list.isEmpty) {
        return Center(child: CircularProgressIndicator(color: _accent));
      }
      final media = MediaQuery.of(context);
      final bottomClearance = media.viewInsets.bottom > 0
          ? 24.0
          : 76.0 + 38.0 + media.viewPadding.bottom;
      if (list.isEmpty) {
        return RefreshIndicator(
          color: _accent,
          onRefresh: _refreshHawala,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 55, 16, bottomClearance),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        color: _softGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 29,
                        color: _accent,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      languagesController.tr('NO_DATA_FOUND'),
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
        onRefresh: _refreshHawala,
        child: ListView.separated(
          controller: scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16, 4, 16, bottomClearance),
          itemCount:
              list.length + (hawalalistController.isLoading.value ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index >= list.length) {
              return Padding(
                padding: const EdgeInsets.all(14),
                child: Center(child: CircularProgressIndicator(color: _accent)),
              );
            }
            return _buildHawalaCard(list[index]);
          },
        ),
      );
    });
  }

  Widget _buildHawalaCard(dynamic data) {
    final status = data.status?.toString() ?? '';
    final statusColor = _statusColor(status);
    final hawalaNumber =
        data.hawalaCustomNumber?.toString().trim().isNotEmpty == true
        ? data.hawalaCustomNumber.toString()
        : data.hawalaNumber?.toString() ?? '';

    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: () => _showDetailsDialog(data),
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: _softGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      color: _accent,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languagesController.tr('HAWALA_NUMBER'),
                          style: TextStyle(color: _muted, fontSize: 10.5),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hawalaNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _text,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusPill(status),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: _border),
              const SizedBox(height: 11),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _compactInfo(
                      languagesController.tr('SENDER_NAME'),
                      data.senderName?.toString() ?? '',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _compactInfo(
                      languagesController.tr('RECEIVER_NAME'),
                      data.receiverName?.toString() ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _dark
                      ? const Color(0xFF1B2C23)
                      : const Color(0xFFF3F9F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _compactInfo(
                        languagesController.tr('HAWALA_AMOUNT'),
                        data.hawalaAmount?.toString() ?? '',
                        amount: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _compactInfo(
                        languagesController.tr('PAYABLE_AMOUNT'),
                        data.hawalaAmountCurrencyRate?.toString() ?? '',
                        amount: true,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: statusColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactInfo(String label, String value, {bool amount = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: amount ? _accent : _text,
            fontSize: amount ? 13 : 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _statusPill(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(_dark ? .16 : .09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            _statusText(status),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(dynamic data) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        backgroundColor: Colors.transparent,
        child: HawalaDetailsDialog(
          id: data.id?.toString(),
          hawalaNumber: data.hawalaNumber?.toString(),
          hawalaCustomNumber: data.hawalaCustomNumber?.toString(),
          status: data.status?.toString(),
          branchID: data.hawalaBranchId?.toString(),
          senderName: data.senderName?.toString(),
          receiverName: data.receiverName?.toString(),
          fatherName: data.receiverFatherName?.toString(),
          idcardnumber: data.receiverIdCardNumber?.toString(),
          amount: data.hawalaAmount?.toString(),
          hawalacurrencyRate: data.hawalaAmountCurrencyRate?.toString(),
          hawalacurrencyCode: data.hawalaAmountCurrencyCode?.toString(),
          resellercurrencyCode: data.resellerPreferedCurrencyCode?.toString(),
          resellCurrencyRate: data.resellerPreferedCurrencyRate?.toString(),
          paidbysender: data.commissionPaidBySender?.toString(),
          paidbyreceiver: data.commissionPaidByReceiver?.toString(),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFD29A24);
      case 'confirmed':
        return const Color(0xFF20AD6A);
      default:
        return const Color(0xFFE25263);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'confirmed':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.cancel_outlined;
    }
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return languagesController.tr('PENDING');
      case 'confirmed':
        return languagesController.tr('CONFIRMED');
      default:
        return languagesController.tr('REJECTED');
    }
  }
}

class HawalaDetailsDialog extends StatelessWidget {
  HawalaDetailsDialog({
    super.key,
    this.id,
    this.hawalaNumber,
    this.hawalaCustomNumber,
    this.status,
    this.branchID,
    this.senderName,
    this.receiverName,
    this.fatherName,
    this.idcardnumber,
    this.amount,
    this.hawalacurrencyRate,
    this.hawalacurrencyCode,
    this.resellercurrencyCode,
    this.resellCurrencyRate,
    this.paidbysender,
    this.paidbyreceiver,
  });

  final String? id;
  final String? hawalaNumber;
  final String? hawalaCustomNumber;
  final String? status;
  final String? branchID;
  final String? senderName;
  final String? receiverName;
  final String? fatherName;
  final String? idcardnumber;
  final String? amount;
  final String? hawalacurrencyRate;
  final String? hawalacurrencyCode;
  final String? resellercurrencyCode;
  final String? resellCurrencyRate;
  final String? paidbysender;
  final String? paidbyreceiver;

  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final BranchController branchController = Get.put(BranchController());
  final CancelHawalaController cancelHawalaController = Get.put(
    CancelHawalaController(),
  );
  final ThemeController themeController = Get.find<ThemeController>();
  final RxBool isOpen = true.obs;
  final GlobalKey captureKey = GlobalKey();
  final GlobalKey shareKey = GlobalKey();

  bool get _dark => themeController.isDarkMode.value;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _accent => AppColors.primaryColor;

  dynamic _findBranch() {
    try {
      final branches =
          branchController.allbranch.value.data?.hawalabranches ?? [];
      for (final item in branches) {
        if (item.id.toString() == branchID.toString()) return item;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Color _statusColor(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        return const Color(0xFFD29A24);
      case 'confirmed':
        return const Color(0xFF20AD6A);
      default:
        return const Color(0xFFE25263);
    }
  }

  IconData _statusIcon(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'confirmed':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.cancel_outlined;
    }
  }

  String _statusText(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        return languagesController.tr('PENDING');
      case 'confirmed':
        return languagesController.tr('CONFIRMED');
      default:
        return languagesController.tr('REJECTED');
    }
  }

  Widget _actionButton({
    required VoidCallback onTap,
    required String label,
    required IconData icon,
    bool filled = false,
  }) {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? _accent : _surface,
          foregroundColor: filled ? Colors.white : _text,
          side: BorderSide(color: filled ? _accent : _border),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool emphasized = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF738079), fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: emphasized ? _accent : const Color(0xFF24342C),
                fontSize: emphasized ? 13 : 11.5,
                fontWeight: emphasized ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final currentStatus = status ?? '';
      final statusColor = _statusColor(currentStatus);
      final branch = _findBranch();
      final displayNumber =
          hawalaCustomNumber != null &&
              hawalaCustomNumber != 'null' &&
              hawalaCustomNumber!.trim().isNotEmpty
          ? hawalaCustomNumber!
          : hawalaNumber ?? '';

      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .84,
          maxWidth: 460,
        ),
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _border),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      _statusIcon(currentStatus),
                      color: statusColor,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _statusText(currentStatus),
                      style: TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: _muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RepaintBoundary(
                key: captureKey,
                child: RepaintBoundary(
                  key: shareKey,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(15, 18, 15, 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE1EAE5)),
                    ),
                    child: Column(
                      children: [
                        Image.asset('assets/icons/logo.png', height: 44),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(.11),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Text(
                            _statusText(currentStatus),
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _receiptRow(
                          languagesController.tr('HAWALA_NUMBER'),
                          displayNumber,
                          emphasized: true,
                        ),
                        _receiptRow(
                          languagesController.tr('HAWALA_AMOUNT'),
                          amount ?? '',
                          emphasized: true,
                        ),
                        _receiptRow(
                          languagesController.tr('SENDER_NAME'),
                          senderName ?? '',
                        ),
                        _receiptRow(
                          languagesController.tr('RECEIVER_NAME'),
                          receiverName ?? '',
                        ),
                        const SizedBox(height: 9),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F8F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _receiptRow(
                                languagesController.tr('BRANCH'),
                                branch?.name?.toString() ?? '',
                              ),
                              _receiptRow(
                                languagesController.tr('ADDRESS'),
                                branch?.address?.toString() ?? '',
                              ),
                              _receiptRow(
                                languagesController.tr('PHONE_NUMBER'),
                                branch?.phoneNumber?.toString() ?? '',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      onTap: () => capturePng(captureKey),
                      label: languagesController.tr('SAVE_TO_GALLERY'),
                      icon: Icons.download_rounded,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _actionButton(
                      onTap: () => captureImageFromWidgetAsFile(shareKey),
                      label: languagesController.tr('SHARE'),
                      icon: Icons.share_rounded,
                      filled: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Obx(() {
                if (currentStatus.toLowerCase() != 'pending') {
                  return const SizedBox.shrink();
                }
                if (isOpen.value) {
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => isOpen.value = false,
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: Text(languagesController.tr('CANCEL_ORDER')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE25263),
                        side: const BorderSide(color: Color(0xFFF1C5CB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        onTap: () => isOpen.value = true,
                        label: languagesController.tr('NO'),
                        icon: Icons.close_rounded,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            cancelHawalaController.cancelnow(id);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE25263),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(languagesController.tr('YES')),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 9),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: _muted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    languagesController.tr('CLOSE'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
