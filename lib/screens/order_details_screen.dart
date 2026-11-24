import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/helpers/capture_image_helper.dart';
import 'package:onlinetelecom/helpers/localtime_helper.dart';
import 'package:onlinetelecom/helpers/share_image_helper.dart';
import 'package:onlinetelecom/utils/colors.dart';

/// Online Telecom: a clean, ticket-style, shareable order receipt.
/// No forced reading direction or intro banner; page title uses 16px.
/// The original constructor parameters, visibility toggle, save and share APIs
/// are preserved. Receipt actions scroll above BaseScreen's bottom navigation.
class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({
    super.key,
    this.createDate,
    this.status,
    this.rejectReason,
    this.companyName,
    this.bundleTitle,
    this.rechargebleAccount,
    this.validityType,
    this.sellingPrice,
    this.buyingPrice,
    this.orderID,
    this.resellerName,
    this.resellerPhone,
    this.companyLogo,
    this.amount,
  });

  final String? createDate;
  final String? status;
  final String? rejectReason;
  final String? companyName;
  final String? bundleTitle;
  final String? rechargebleAccount;
  final String? validityType;
  final String? sellingPrice;
  final String? buyingPrice;
  final String? orderID;
  final String? resellerName;
  final String? resellerPhone;
  final String? companyLogo;
  final String? amount;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final ThemeController themeController = Get.find<ThemeController>();
  final GetStorage box = GetStorage();

  final GlobalKey _captureKey = GlobalKey();
  final GlobalKey shareKey = GlobalKey();

  bool showPrice = false;

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
  Color get _accent => AppColors.primaryColor;
  Color get _softGreen =>
      _dark ? const Color(0xFF1E3829) : const Color(0xFFEAF8EF);

  String _value(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.toLowerCase() == 'null' ? '' : trimmed;
  }

  String get currencyCode => _value(box.read('currency_code')?.toString());
  bool get isPending => widget.status == '0';
  bool get isConfirmed => widget.status == '1';

  Color get statusColor => isPending
      ? const Color(0xFFE3A136)
      : isConfirmed
      ? const Color(0xFF159B65)
      : const Color(0xFFE15E68);

  Color get statusSoftColor => isPending
      ? (_dark ? const Color(0xFF42351C) : const Color(0xFFFFF5E4))
      : isConfirmed
      ? (_dark ? const Color(0xFF193D31) : const Color(0xFFEAF8F1))
      : (_dark ? const Color(0xFF47272E) : const Color(0xFFFFEFF1));

  String get statusText => isPending
      ? languagesController.tr('PENDING')
      : isConfirmed
      ? languagesController.tr('CONFIRMED')
      : languagesController.tr('REJECTED');

  IconData get _statusIcon => isPending
      ? Icons.schedule_rounded
      : isConfirmed
      ? Icons.verified_rounded
      : Icons.error_outline_rounded;

  String get validityText {
    switch (widget.validityType?.toLowerCase()) {
      case 'yearly':
        return languagesController.tr('YEARLY');
      case 'unlimited':
        return languagesController.tr('UNLIMITED');
      case 'monthly':
        return languagesController.tr('MONTHLY');
      case 'weekly':
        return languagesController.tr('WEEKLY');
      case 'daily':
        return languagesController.tr('DAILY');
      case 'hourly':
        return languagesController.tr('HOURLY');
      case 'nightly':
        return languagesController.tr('NIGHTLY');
      default:
        return '';
    }
  }

  String get formattedSellingPrice {
    final amount =
        double.tryParse(_value(widget.sellingPrice).replaceAll(',', '')) ?? 0;
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: 2,
    ).format(amount);
  }

  String get _displayOrderId {
    final id = _value(widget.orderID);
    return id.isEmpty ? '—' : 'OT#- $id';
  }

  String get _date {
    if (_value(widget.createDate).isEmpty) return '—';
    try {
      return convertToDate(widget.createDate!);
    } catch (_) {
      return _value(widget.createDate);
    }
  }

  String get _time {
    if (_value(widget.createDate).isEmpty) return '—';
    try {
      return convertToLocalTime(widget.createDate!);
    } catch (_) {
      return '—';
    }
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

      final media = MediaQuery.of(context);
      final clearance = media.viewInsets.bottom > 0
          ? 24.0
          : 76.0 + 38.0 + media.viewPadding.bottom;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: bars,
        child: Scaffold(
          backgroundColor: _background,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16, 4, 16, clearance),
                    child: Column(
                      children: [
                        // Only the ticket itself is saved or shared.
                        RepaintBoundary(
                          key: _captureKey,
                          child: RepaintBoundary(
                            key: shareKey,
                            child: _buildTicket(),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildActions(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool active = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? _softGreen : _surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: active ? _accent.withOpacity(.2) : _border,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: active ? _accent : _text, size: 20),
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
          _iconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
            tooltip: 'Back',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              languagesController.tr('ORDER_DETAILS'),
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
          _iconButton(
            icon: showPrice
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            onTap: () => setState(() => showPrice = !showPrice),
            tooltip: showPrice ? 'Hide price' : 'Show price',
            active: showPrice,
          ),
          const SizedBox(width: 9),
          _iconButton(
            icon: _dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            onTap: themeController.toggleTheme,
            tooltip: _dark ? 'Light mode' : 'Dark mode',
          ),
        ],
      ),
    );
  }

  // A compact ticket with a real perforated divider rather than stacked boxes.
  Widget _buildTicket() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .14 : .045),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF13663B), Color(0xFF22B66C)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 19, 19, 12),
            child: _ticketTop(),
          ),
          _ticketDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(19, 10, 19, 16),
            child: _productAndOrderDetails(),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(19, 16, 19, 18),
            color: _input,
            child: _customerAndPrice(),
          ),
          Container(
            height: 5,
            decoration: BoxDecoration(color: statusColor.withOpacity(.80)),
          ),
        ],
      ),
    );
  }

  Widget _ticketTop() {
    final reason = _value(widget.rejectReason);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _softGreen,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(Icons.receipt_long_rounded, color: _accent, size: 23),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languagesController.tr('ORDER_DETAILS'),
                    style: TextStyle(
                      color: _text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _displayOrderId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/icons/logo.png',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.check_circle_outline, color: _accent, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: statusSoftColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: statusColor.withOpacity(.18)),
          ),
          child: Row(
            children: [
              Icon(_statusIcon, color: statusColor, size: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.check_circle_outline_rounded,
                color: statusColor.withOpacity(.5),
                size: 17,
              ),
            ],
          ),
        ),
        if (!isPending && !isConfirmed && reason.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            reason,
            style: TextStyle(color: statusColor, fontSize: 12, height: 1.4),
          ),
        ],
      ],
    );
  }

  Widget _ticketDivider() {
    return SizedBox(
      height: 24,
      width: double.infinity,
      child: CustomPaint(
        painter: _TicketDividerPainter(
          lineColor: _border,
          cutoutColor: _background,
        ),
      ),
    );
  }

  Widget _productAndOrderDetails() {
    final name = _value(widget.bundleTitle);
    final company = _value(widget.companyName);
    final logoUrl = _value(widget.companyLogo);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 53,
              height: 53,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _input,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _border),
              ),
              child: logoUrl.isEmpty
                  ? Icon(Icons.sim_card_outlined, size: 25, color: _accent)
                  : Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.sim_card_outlined,
                        size: 25,
                        color: _accent,
                      ),
                    ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? company : name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  if (company.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            if (validityText.isNotEmpty) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _softGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    validityText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (_value(widget.amount).isNotEmpty) ...[
          const SizedBox(height: 13),
          _dataRow(languagesController.tr('AMOUNT'), _value(widget.amount)),
        ],
        const SizedBox(height: 17),
        Container(height: 1, color: _border),
        const SizedBox(height: 15),
        _dataRow(
          languagesController.tr('ORDER_ID'),
          _displayOrderId,
          emphasize: true,
        ),
        const SizedBox(height: 12),
        _dataRow(languagesController.tr('DATE'), _date),
        const SizedBox(height: 12),
        _dataRow(languagesController.tr('TIME'), _time),
      ],
    );
  }

  Widget _customerAndPrice() {
    final recipient = _value(widget.rechargebleAccount);
    final senderName = _value(widget.resellerName);
    final senderPhone = _value(widget.resellerPhone);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recipient.isNotEmpty) ...[
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _softGreen,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.phone_iphone_rounded,
                  size: 19,
                  color: _accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languagesController.tr('PHONE_NUMBER'),
                      style: TextStyle(color: _muted, fontSize: 10),
                    ),
                    const SizedBox(height: 3),
                    SelectableText(
                      recipient,
                      style: TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
        ],
        if (senderName.isNotEmpty) ...[
          _dataRow(languagesController.tr('SENDER'), senderName),
          const SizedBox(height: 12),
        ],
        if (senderPhone.isNotEmpty) ...[
          _dataRow(languagesController.tr('PHONE_NUMBER'), senderPhone),
          const SizedBox(height: 12),
        ],
        if (showPrice) ...[
          Container(height: 1, color: _border),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.payments_outlined, color: _accent, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  languagesController.tr('PRICE'),
                  style: TextStyle(
                    color: _text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  '$formattedSellingPrice $currencyCode'.trim(),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _accent,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _dataRow(String label, String value, {bool emphasize = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _muted,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          flex: 5,
          child: Text(
            value.isEmpty ? '—' : value,
            textAlign: TextAlign.end,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: emphasize ? _accent : _text,
              fontSize: 11.8,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool filled = false,
  }) {
    return SizedBox(
      height: 49,
      child: Material(
        color: filled ? _accent : _surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: filled ? _accent : _border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: filled ? Colors.white : _text, size: 18),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: filled ? Colors.white : _text,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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

  Widget _buildActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionButton(
                icon: Icons.download_rounded,
                label: languagesController.tr('SAVE_TO_GALLERY'),
                onPressed: () => capturePng(_captureKey),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _actionButton(
                icon: Icons.ios_share_rounded,
                label: languagesController.tr('SHARE'),
                filled: true,
                onPressed: () => captureImageFromWidgetAsFile(shareKey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: _actionButton(
            icon: Icons.close_rounded,
            label: languagesController.tr('CLOSE'),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}

/// Paints dotted receipt perforations and semicircular paper cutouts.
class _TicketDividerPainter extends CustomPainter {
  const _TicketDividerPainter({
    required this.lineColor,
    required this.cutoutColor,
  });

  final Color lineColor;
  final Color cutoutColor;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final dashPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    var x = 16.0;
    while (x < size.width - 16) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x + 5 < size.width - 16 ? x + 5 : size.width - 16, y),
        dashPaint,
      );
      x += 10;
    }

    final cutoutPaint = Paint()
      ..color = cutoutColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, y), 10, cutoutPaint);
    canvas.drawCircle(Offset(size.width, y), 10, cutoutPaint);
  }

  @override
  bool shouldRepaint(covariant _TicketDividerPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      oldDelegate.cutoutColor != cutoutColor;
}
