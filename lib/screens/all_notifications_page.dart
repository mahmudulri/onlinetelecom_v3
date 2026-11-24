import 'package:flutter/material.dart' hide Notification;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:onlinetelecom/pages/notification_details_page.dart';

import '../controllers/notifications_controller.dart';
import '../global_controller/languages_controller.dart';
import '../global_controller/theme_controller.dart';
import '../models/notifications_model.dart';
import '../utils/colors.dart';

/// Redesigned notification inbox.
/// Uses the same ThemeController and header buttons as the Network screen.
class AllNotificationsPage extends StatefulWidget {
  const AllNotificationsPage({super.key});

  @override
  State<AllNotificationsPage> createState() => _AllNotificationsPageState();
}

class _AllNotificationsPageState extends State<AllNotificationsPage> {
  final NotificationController notificationController =
      Get.find<NotificationController>();
  final LanguagesController languagesController =
      Get.find<LanguagesController>();
  final ThemeController themeController = Get.find<ThemeController>();

  bool get _dark => themeController.isDarkMode.value;
  Color get _background =>
      _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _accent => AppColors.primaryColor;
  Color get _paleGreen =>
      _dark ? const Color(0xFF203C2A) : const Color(0xFFECF9F0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) notificationController.fetchData();
    });
  }

  Future<void> _openNotificationDetails(Notification notification) async {
    await Get.to(() => NotificationDetailsPage(notification: notification));
    if (mounted) await notificationController.fetchData();
  }

  Future<void> _refreshNotifications() async {
    await notificationController.fetchData();
  }

  String _formatNotificationDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    // Observe the shared flag directly so colors change immediately even if
    // the surrounding route does not rebuild its inherited ThemeData.
    return Obx(() {
      final isDarkMode = themeController.isDarkMode.value;
      final overlay = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay,
        child: Scaffold(
          backgroundColor: _background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildNotificationsBody()),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Identical 42x42 / radius 14 header-control style to the Network page.
  Widget _headerIcon({
    required Widget icon,
    required VoidCallback? onTap,
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
              border: Border.all(color: _border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: icon,
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
          _headerIcon(
            tooltip: 'Back',
            onTap: () => Get.back(),
            icon: Icon(Icons.arrow_back_rounded, size: 22, color: _text),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    languagesController.tr('NOTIFICATIONS'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _text,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.35,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Obx(() {
                  final items =
                      notificationController
                          .allnotificationlist
                          .value
                          .data
                          ?.notifications ??
                      [];
                  final unread = items.where((n) => n.isRead == false).length;
                  if (unread == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _paleGreen,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      '$unread',
                      style: TextStyle(
                        color: _accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => _headerIcon(
              tooltip: themeController.isDarkMode.value
                  ? 'Light mode'
                  : 'Dark mode',
              onTap: themeController.toggleTheme,
              icon: Icon(
                themeController.isDarkMode.value
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                size: 21,
                color: _text,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Obx(() {
            final loading = notificationController.isLoading.value;
            return _headerIcon(
              tooltip: 'Refresh',
              onTap: loading ? null : () => notificationController.fetchData(),
              icon: loading
                  ? SizedBox(
                      height: 17,
                      width: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(_accent),
                      ),
                    )
                  : Icon(Icons.refresh_rounded, size: 22, color: _text),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotificationsBody() {
    return Obx(() {
      final isLoading = notificationController.isLoading.value;
      final notifications =
          notificationController
              .allnotificationlist
              .value
              .data
              ?.notifications ??
          [];

      if (isLoading && notifications.isEmpty) {
        return Center(child: CircularProgressIndicator(color: _accent));
      }

      if (notifications.isEmpty) {
        return RefreshIndicator(
          color: _accent,
          onRefresh: _refreshNotifications,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.63,
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 35, 20, 35),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: _border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: _paleGreen,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            size: 32,
                            color: _accent,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          languagesController.tr('NO_NOTIFICATIONS'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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

      return RefreshIndicator(
        color: _accent,
        onRefresh: _refreshNotifications,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 1, 16, 26),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, index) =>
              _buildNotificationCard(notifications[index]),
        ),
      );
    });
  }

  Widget _buildNotificationCard(Notification notification) {
    final unread = notification.isRead == false;
    final title = notification.title ?? '';
    final message = notification.message ?? '';
    final date = _formatNotificationDate(notification.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () => _openNotificationDetails(notification),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: unread
                  ? [
                      _dark ? const Color(0xFF20392A) : const Color(0xFFF5FCF7),
                      _surface,
                    ]
                  : [_surface, _surface],
            ),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: unread
                  ? _accent.withOpacity(_dark ? 0.30 : 0.20)
                  : _border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_dark ? 0.09 : 0.025),
                blurRadius: 11,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Stack(
              children: [
                if (unread)
                  Positioned(
                    left: 0,
                    top: 12,
                    bottom: 12,
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(3),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: unread
                                  ? _paleGreen
                                  : (_dark
                                        ? AppColors.darkInputBackground
                                        : const Color(0xFFF3F6F4)),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              unread
                                  ? Icons.notifications_active_outlined
                                  : Icons.notifications_none_rounded,
                              color: unread ? _accent : _muted,
                              size: 20,
                            ),
                          ),
                          if (unread)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: _accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _surface,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Directionality(
                          textDirection: Directionality.of(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: _text,
                                        fontSize: 13.2,
                                        height: 1.22,
                                        fontWeight: unread
                                            ? FontWeight.w800
                                            : FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  if (unread)
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              if (message.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _muted,
                                    fontSize: 11.5,
                                    height: 1.28,
                                  ),
                                ),
                              ],
                              if (date.isNotEmpty) ...[
                                const SizedBox(height: 7),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 12,
                                      color: _muted,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        date,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: _muted,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(top: 11),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 19,
                          color: _muted.withOpacity(0.65),
                        ),
                      ),
                    ],
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
