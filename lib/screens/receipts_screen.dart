import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:onlinetelecom/controllers/payments_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/screens/create_payments_screen.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/drawer.dart';

/// Payment receipt list — minimal payment ledger with attachment previews.
/// Uses the app's existing theme, translation, controllers and navigation.
class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  final PaymentsController paymentsController = Get.put(PaymentsController());
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
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _softGreen =>
      _dark ? const Color(0xFF1D3A2B) : const Color(0xFFEAF7EF);
  Color get _primary => AppColors.primaryColor;

  @override
  void initState() {
    super.initState();
    paymentsController.fetchpayments();
  }

  Future<void> _refreshPayments() async {
    paymentsController.fetchpayments();
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }

  String _clean(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.toLowerCase() == 'null' ? '' : text;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = themeController.isDarkMode.value;
      final systemBars = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
      );

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemBars,
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
                _buildCreateButton(),
                const SizedBox(height: 15),
                Expanded(child: _buildReceiptList()),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _headerAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
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
          _headerAction(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onTap: mypagecontroller.goBack,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              languagesController.tr('PAYMENT_RECEIPT_REQUEST'),
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
          _headerAction(
            icon: _dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tooltip: _dark ? 'Light mode' : 'Dark mode',
            onTap: themeController.toggleTheme,
          ),
          const SizedBox(width: 9),
          _headerAction(
            icon: Icons.menu_rounded,
            tooltip: 'Menu',
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: _primary,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => mypagecontroller.changePage(
            CreatePaymentsScreen(),
            isMainPage: false,
          ),
          child: Container(
            height: 49,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  height: 29,
                  width: 29,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    languagesController.tr('ADD_NEW_RECEIPT'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptList() {
    return Obx(() {
      final payments =
          paymentsController.allpaymentslist.value.data?.payments ?? [];
      final loading = paymentsController.isLoading.value;
      final media = MediaQuery.of(context);
      final bottomClearance = media.viewInsets.bottom > 0
          ? 24.0
          : 76.0 + 38.0 + media.viewPadding.bottom;

      if (loading && payments.isEmpty) {
        return Center(child: CircularProgressIndicator(color: _primary));
      }

      if (payments.isEmpty) {
        return RefreshIndicator(
          color: _primary,
          onRefresh: _refreshPayments,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 55, 16, bottomClearance),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _softGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 32,
                        color: _primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      languagesController.tr('NO_DATA_FOUND'),
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

      return RefreshIndicator(
        color: _primary,
        onRefresh: _refreshPayments,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16, 1, 16, bottomClearance),
          itemCount: payments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 11),
          itemBuilder: (context, index) => _buildReceiptItem(payments[index]),
        ),
      );
    });
  }

  Widget _buildReceiptItem(dynamic data) {
    final status = _clean(data.status).toLowerCase();
    final accent = _paymentStatusColor(status);
    final amount = _clean(data.amount);
    final currency = _clean(data.currency?.symbol);
    final method = _clean(data.paymentMethod?.methodName);
    final performer = _clean(data.performedByName);
    final date = _paymentDate(_clean(data.paymentDate));
    final notes = _clean(data.notes);
    final images = [
      _clean(data.paymentImageUrl),
      _clean(data.extraImage1Url),
      _clean(data.extraImage2Url),
    ].where((url) => url.isNotEmpty).toList();

    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showPaymentDialog(data),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // A slim status stripe replaces the old heavy status cards.
                Container(width: 4, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(13, 13, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method.isEmpty
                                        ? languagesController.tr(
                                            'PAYMENT_METHOD',
                                          )
                                        : method,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '$amount $currency'.trim(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: _text,
                                      fontSize: 20,
                                      letterSpacing: -.35,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _statusPill(status),
                          ],
                        ),
                        const SizedBox(height: 11),
                        Container(height: 1, color: _border),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              color: _muted,
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                performer,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: _muted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              date,
                              style: TextStyle(
                                color: _muted,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (notes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            notes,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: _muted, fontSize: 10.5),
                          ),
                        ],
                        if (images.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ...images
                                  .take(3)
                                  .map(
                                    (url) => Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: _smallImage(url),
                                    ),
                                  ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: _muted,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ],
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

  Widget _smallImage(String url) {
    return Container(
      width: 39,
      height: 35,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _border),
      ),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.image_not_supported_outlined, color: _muted, size: 17),
      ),
    );
  }

  Widget _statusPill(String status) {
    final color = _paymentStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(_dark ? .19 : .10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            _paymentStatusLabel(status, languagesController),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(dynamic data) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: PaymentDialog(
          status: data.status,
          paymentMethod: data.paymentMethod?.methodName,
          amount: data.amount,
          performedByName: data.performedByName,
          currency: data.currency?.code,
          notes: data.notes,
          date: data.paymentDate,
          image1: data.paymentImageUrl,
          image2: data.extraImage1Url,
          image3: data.extraImage2Url,
        ),
      ),
    );
  }
}

/// Kept as a public widget to preserve existing routes/call sites.
class PaymentDialog extends StatelessWidget {
  const PaymentDialog({
    super.key,
    this.status,
    this.paymentMethod,
    this.amount,
    this.performedByName,
    this.notes,
    this.currency,
    this.date,
    this.image1,
    this.image2,
    this.image3,
  });

  final dynamic status;
  final dynamic paymentMethod;
  final dynamic amount;
  final dynamic performedByName;
  final dynamic notes;
  final dynamic currency;
  final dynamic date;
  final dynamic image1;
  final dynamic image2;
  final dynamic image3;

  static String _clean(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.toLowerCase() == 'null' ? '' : text;
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final languagesController = Get.find<LanguagesController>();

    return Obx(() {
      final dark = themeController.isDarkMode.value;
      final surface = dark ? AppColors.darkCard : AppColors.lightSurface;
      final muted = dark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary;
      final text = dark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary;
      final border = dark ? AppColors.darkBorder : AppColors.lightBorder;
      final input = dark
          ? AppColors.darkInputBackground
          : const Color(0xFFF5F9F6);
      final state = _clean(status).toLowerCase();
      final accent = _paymentStatusColor(state);
      final images = [
        _clean(image1),
        _clean(image2),
        _clean(image3),
      ].where((url) => url.isNotEmpty).toList();
      final formattedDate = _paymentDate(_clean(date));
      final noteText = _clean(notes);

      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .83,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 5, color: accent),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(17, 17, 17, 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 43,
                          width: 43,
                          decoration: BoxDecoration(
                            color: accent.withOpacity(dark ? .20 : .11),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _paymentStatusIcon(state),
                            color: accent,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _paymentStatusLabel(state, languagesController),
                            style: TextStyle(
                              fontSize: 15,
                              color: text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded, color: muted),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      languagesController.tr('AMOUNT'),
                      style: TextStyle(fontSize: 11, color: muted),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_clean(amount)} ${_clean(currency)}'.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: text,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.4,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: input,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _dialogDetail(
                            label: languagesController.tr('PAYMENT_METHOD'),
                            value: _clean(paymentMethod),
                            text: text,
                            muted: muted,
                          ),
                          Divider(height: 1, color: border),
                          _dialogDetail(
                            label: languagesController.tr('PERFORMED_BY'),
                            value: _clean(performedByName),
                            text: text,
                            muted: muted,
                          ),
                          Divider(height: 1, color: border),
                          _dialogDetail(
                            label: languagesController.tr('DATE'),
                            value: formattedDate,
                            text: text,
                            muted: muted,
                          ),
                          if (noteText.isNotEmpty) ...[
                            Divider(height: 1, color: border),
                            _dialogDetail(
                              label: languagesController.tr('NOTES'),
                              value: noteText,
                              text: text,
                              muted: muted,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (images.isNotEmpty) ...[
                      const SizedBox(height: 17),
                      Row(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            color: muted,
                            size: 16,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            '${images.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: muted,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          for (var i = 0; i < images.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () => _previewImage(context, images[i]),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 86,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: input,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: border),
                                  ),
                                  child: Image.network(
                                    images[i],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.broken_image_outlined,
                                      color: muted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: Text(
                          languagesController.tr('CLOSE'),
                          style: TextStyle(
                            color: text,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _dialogDetail({
    required String label,
    required String value,
    required Color text,
    required Color muted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(color: muted, fontSize: 11)),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              value,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: text,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previewImage(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(dialogContext).size.height * .7,
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                onPressed: () => Navigator.pop(dialogContext),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _paymentDate(String raw) {
  if (raw.isEmpty || raw.toLowerCase() == 'null') return '';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  return DateFormat('dd MMM yyyy').format(parsed);
}

Color _paymentStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return const Color(0xFFD99624);
    case 'completed':
      return const Color(0xFF16A36A);
    default:
      return const Color(0xFFDD5A65);
  }
}

IconData _paymentStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Icons.schedule_rounded;
    case 'completed':
      return Icons.check_circle_outline_rounded;
    default:
      return Icons.cancel_outlined;
  }
}

String _paymentStatusLabel(
  String status,
  LanguagesController languagesController,
) {
  switch (status.toLowerCase()) {
    case 'pending':
      return languagesController.tr('PENDING');
    case 'completed':
      return languagesController.tr('COMPLETED');
    default:
      return languagesController.tr('REJECTED');
  }
}
