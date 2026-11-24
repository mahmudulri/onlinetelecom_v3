import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:onlinetelecom/controllers/transferlist_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

import 'create_transfer_screen.dart';

/// Commission transfers — Online Telecom shared green / light-dark design.
/// The existing TransferlistController and CreateTransferScreen are unchanged.
class CommissionTransferScreen extends StatefulWidget {
  const CommissionTransferScreen({super.key});

  @override
  State<CommissionTransferScreen> createState() =>
      _CommissionTransferScreenState();
}

class _CommissionTransferScreenState extends State<CommissionTransferScreen> {
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final TransferlistController transferlistController = Get.put(
    TransferlistController(),
  );
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final ThemeController themeController = Get.find<ThemeController>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  bool get _dark => themeController.isDarkMode.value;
  Color get _background =>
      _dark ? AppColors.darkBackground : AppColors.lightBackground;
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
      _dark ? const Color(0xFF1E3829) : const Color(0xFFEAF8EF);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    transferlistController.fetchdata();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshTransfers() async {
    transferlistController.fetchdata();
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  void _createTransfer() {
    mypagecontroller.changePage(CreateTransferScreen(), isMainPage: false);
  }

  @override
  Widget build(BuildContext context) {
    // Observe the same GetX theme state as the Network and Orders pages.
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final systemOverlay = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemOverlay,
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
                _buildToolbar(),
                const SizedBox(height: 14),
                Expanded(child: _buildTransferList()),
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
                languagesController.tr('TRANSFER_COMISSION'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.35,
                ),
              ),
            ),
            const SizedBox(width: 7),
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
          Obx(() {
            final requests =
                transferlistController.alltransferlist.value.data?.requests ??
                [];
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
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
                      color: _softGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      size: 21,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      languagesController.tr('TRANSFER_COMISSION'),
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
                      color: _softGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${requests.length}',
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
                    onTap: _createTransfer,
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      height: 49,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 96),
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

  Widget _buildTransferList() {
    return Obx(() {
      final isLoading = transferlistController.isLoading.value;
      final requests =
          transferlistController.alltransferlist.value.data?.requests ?? [];
      final query = _searchController.text.trim().toLowerCase();
      final filtered = requests.where((request) {
        if (query.isEmpty) return true;
        final amount = request.amount?.toString().toLowerCase() ?? '';
        final status = request.status?.toString().toLowerCase() ?? '';
        final notes = request.adminNotes?.toString().toLowerCase() ?? '';
        return amount.contains(query) ||
            status.contains(query) ||
            notes.contains(query) ||
            _statusText(status).toLowerCase().contains(query);
      }).toList();

      if (isLoading && requests.isEmpty) {
        return Center(child: CircularProgressIndicator(color: _primary));
      }

      if (filtered.isEmpty) {
        return RefreshIndicator(
          onRefresh: _refreshTransfers,
          color: _primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
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
                        color: _softGreen,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Icon(
                        query.isNotEmpty
                            ? Icons.search_off_rounded
                            : Icons.swap_horiz_rounded,
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
        onRefresh: _refreshTransfers,
        color: _primary,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 9),
          itemBuilder: (_, index) => _buildTransferCard(filtered[index]),
        ),
      );
    });
  }

  Widget _buildTransferCard(dynamic data) {
    final status = data.status?.toString() ?? '';
    final notes = data.adminNotes?.toString() ?? '';
    final amount = data.amount?.toString() ?? '';
    final hasNotes = notes.trim().isNotEmpty && notes.toLowerCase() != 'null';
    final statusColor = _statusColor(status);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .10 : .025),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Column(
          children: [
            Row(
              children: [
                Container(width: 4, height: 74, color: statusColor),
                const SizedBox(width: 12),
                Container(
                  height: 43,
                  width: 43,
                  decoration: BoxDecoration(
                    color: _statusBackground(status),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    _statusIcon(status),
                    size: 22,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        languagesController.tr('AMOUNT'),
                        style: TextStyle(
                          color: _muted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        amount,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBackground(status),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _statusText(status),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
              ],
            ),
            if (hasNotes) ...[
              Divider(height: 1, thickness: 1, color: _border),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 27,
                      width: 27,
                      decoration: BoxDecoration(
                        color: _softGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.notes_rounded,
                        size: 15,
                        color: _primary,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            languagesController.tr('NOTES'),
                            style: TextStyle(
                              color: _muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notes,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _text,
                              fontSize: 12,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFE0A51B);
      case 'completed':
      case 'approved':
      case 'confirmed':
      case 'success':
      case 'successful':
        return const Color(0xFF23B26D);
      case 'rejected':
      case 'cancelled':
      case 'canceled':
      case 'failed':
        return const Color(0xFFE05263);
      default:
        return _primary;
    }
  }

  Color _statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _dark ? const Color(0xFF3D331A) : const Color(0xFFFFF6DA);
      case 'completed':
      case 'approved':
      case 'confirmed':
      case 'success':
      case 'successful':
        return _dark ? const Color(0xFF1B3929) : const Color(0xFFECF9F2);
      case 'rejected':
      case 'cancelled':
      case 'canceled':
      case 'failed':
        return _dark ? const Color(0xFF3A2027) : const Color(0xFFFFF0F2);
      default:
        return _softGreen;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'completed':
      case 'approved':
      case 'confirmed':
      case 'success':
      case 'successful':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
      case 'cancelled':
      case 'canceled':
      case 'failed':
        return Icons.cancel_outlined;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  String _statusText(String status) {
    if (status.isEmpty) return '';
    switch (status.toLowerCase()) {
      case 'pending':
        return languagesController.tr('PENDING');
      case 'completed':
        return languagesController.tr('COMPLETED');
      case 'confirmed':
        return languagesController.tr('CONFIRMED');
      case 'rejected':
        return languagesController.tr('REJECTED');
      default:
        return status;
    }
  }
}
