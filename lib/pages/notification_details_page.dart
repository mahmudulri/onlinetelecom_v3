import 'package:flutter/material.dart' hide Notification;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

import '../controllers/notifications_controller.dart';
import '../models/notifications_model.dart';

class NotificationDetailsPage extends StatefulWidget {
  final Notification notification;

  const NotificationDetailsPage({super.key, required this.notification});

  @override
  State<NotificationDetailsPage> createState() =>
      _NotificationDetailsPageState();
}

class _NotificationDetailsPageState extends State<NotificationDetailsPage> {
  final NotificationController notificationController =
      Get.find<NotificationController>();
  final ThemeController themeController = Get.find<ThemeController>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isClosing = false;

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
  Color get _softAccent =>
      _dark ? const Color(0xFF193B2B) : const Color(0xFFEAF7EE);

  // Keep the original mark-as-read-on-exit behavior, including system Back.
  Future<bool> _handleBack() async {
    if (_isClosing) return false;
    _isClosing = true;

    final notificationId = widget.notification.id;
    final wasUnread = widget.notification.isRead == false;

    if (wasUnread && notificationId != null) {
      try {
        await notificationController.markAsRead(notificationId);
      } catch (error) {
        // A transient API error must not trap the user on the details screen.
        debugPrint('Failed to mark notification as read: $error');
      }
    }

    return true;
  }

  Future<void> _onBackPressed() async {
    final canPop = await _handleBack();
    if (canPop && mounted) {
      Get.back(result: true);
    }
  }

  String _formattedDate() {
    final date = widget.notification.createdAt;
    if (date == null) return '';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = themeController.isDarkMode.value;
      final overlay = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay,
        child: WillPopScope(
          onWillPop: _handleBack,
          child: Scaffold(
            key: _scaffoldKey,
            drawer: const DrawerWidget(),
            backgroundColor: _background,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Obx(() {
                      final isMarkingAsRead =
                          notificationController.isMarkingAsRead.value;

                      return Stack(
                        children: [
                          SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              16,
                              5,
                              16,
                              25 + MediaQuery.of(context).viewPadding.bottom,
                            ),
                            child: _buildNotificationCard(),
                          ),
                          if (isMarkingAsRead)
                            Positioned.fill(
                              child: AbsorbPointer(
                                child: ColoredBox(
                                  color: Colors.black.withOpacity(
                                    dark ? 0.28 : 0.08,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _surface,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: _border),
                                      ),
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: _accent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _headerButton({
    required VoidCallback onTap,
    required IconData icon,
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
            child: Icon(icon, color: _text, size: 21),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          _headerButton(
            onTap: _onBackPressed,
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'Notification Details',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _headerButton(
            onTap: themeController.toggleTheme,
            icon: _dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tooltip: _dark ? 'Light mode' : 'Dark mode',
          ),
          const SizedBox(width: 8),
          _headerButton(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            icon: Icons.menu_rounded,
            tooltip: 'Menu',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard() {
    final notification = widget.notification;
    final title = notification.title?.trim() ?? '';
    final message = notification.message?.trim() ?? '';
    final createdAt = _formattedDate();
    final mediaUrl = notification.media?.toString().trim() ?? '';
    final hasMedia = mediaUrl.isNotEmpty && mediaUrl.toLowerCase() != 'null';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 17),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? 0.12 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 43,
                width: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _softAccent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.notifications_active_outlined,
                  color: _accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    if (createdAt.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 13,
                            color: _muted,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              createdAt,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _muted,
                                fontSize: 11,
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
            ],
          ),
          const SizedBox(height: 15),
          Divider(height: 1, thickness: 1, color: _border),
          const SizedBox(height: 15),
          SelectableText(
            message,
            style: TextStyle(
              color: _text,
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              height: 1.65,
            ),
          ),
          if (hasMedia) ...[
            const SizedBox(height: 17),
            _buildMediaPreview(mediaUrl),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaPreview(String mediaUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _border),
        ),
        child: Image.network(
          mediaUrl,
          width: double.infinity,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              height: 170,
              child: Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes == null
                      ? null
                      : progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!,
                  strokeWidth: 2.2,
                  color: _accent,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => SizedBox(
            height: 116,
            child: Center(
              child: Icon(Icons.broken_image_outlined, color: _muted, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}
