import 'dart:async';
import 'package:onlinetelecom/controllers/bundle_controller.dart';
import 'package:onlinetelecom/controllers/confirm_pin_controller.dart';
import 'package:onlinetelecom/controllers/service_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/helpers/price.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/widgets/drawer.dart';
import 'package:onlinetelecom/widgets/number_textfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key, required this.enableOperatorLookup});
  final bool enableOperatorLookup;

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final ConfirmPinController confirmPinController =
      Get.find<ConfirmPinController>();
  final ServiceController serviceController = Get.find<ServiceController>();
  final BundleController bundleController = Get.find<BundleController>();
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final GetStorage box = GetStorage();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController scrollController = ScrollController();
  int selectedIndex = -1;
  int durationSelectedIndex = 0;
  List<Map<String, String>> duration = [];
  String inputNumber = "";
  String _lastProcessedNumber = "";
  bool isOperatorLookupConfirmed = false;
  Timer? _lookupDebounce;
  String? originalCompanyId;
  String? detectedCompanyId;

  // Keep the current rows visible while another page is loading.
  bool _isLoadingMore = false;
  bool _hasMoreLookupBundles = true;
  List<dynamic> _loadingMoreSnapshot = [];
  int _listGeneration = 0;

  // Only display inquiry messages returned for the current phone number.
  // Store the response so loading later pages does not hide the notice.
  String? _noticeNumber;
  Object? _noticeResponse;
  int _noticeRequest = 0;

  void _resetPaginationView() {
    _listGeneration++;
    _isLoadingMore = false;
    _hasMoreLookupBundles = true;
    _loadingMoreSnapshot = [];
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  bool get isOperatorLookupEnabled {
    final dynamic storedValue = box.read("enable_operator_lookup");
    if (storedValue is bool) {
      return storedValue;
    }
    if (storedValue is int) {
      return storedValue == 1;
    }
    final normalizedValue = storedValue?.toString().trim().toLowerCase() ?? "";
    if (normalizedValue == "true" ||
        normalizedValue == "1" ||
        normalizedValue == "yes") {
      return true;
    }
    if (normalizedValue == "false" ||
        normalizedValue == "0" ||
        normalizedValue == "no") {
      return false;
    }
    return widget.enableOperatorLookup;
  }

  int get _maximumPhoneLength {
    final storedLength = box.read("maxlength");
    return int.tryParse(storedLength?.toString() ?? "") ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _initializeDuration();
    bundleController.resetBundles();
    confirmPinController.pinController.clear();
    confirmPinController.numberController.clear();
    box.write("company_id", "");
    serviceController.fetchservices();
    bundleController.fetchallbundles();
    confirmPinController.numberController.addListener(_onTextChanged);
    scrollController.addListener(_loadMoreBundles);
  }

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    confirmPinController.numberController.removeListener(_onTextChanged);
    scrollController.removeListener(_loadMoreBundles);
    scrollController.dispose();
    super.dispose();
  }

  void _initializeDuration() {
    duration = [
      {"Name": languagesController.tr("All"), "Value": ""},
      {"Name": languagesController.tr("UNLIMITED"), "Value": "unlimited"},
      {"Name": languagesController.tr("MONTHLY"), "Value": "monthly"},
      {"Name": languagesController.tr("WEEKLY"), "Value": "weekly"},
      {"Name": languagesController.tr("DAILY"), "Value": "daily"},
      {"Name": languagesController.tr("HOURLY"), "Value": "hourly"},
      {"Name": languagesController.tr("NIGHTLY"), "Value": "nightly"},
    ];
  }

  Future<void> _loadMoreBundles() async {
    if (_isLoadingMore ||
        bundleController.isLoading.value ||
        bundleController.isLookupLoading.value ||
        !scrollController.hasClients ||
        bundleController.finalList.isEmpty) {
      return;
    }

    final position = scrollController.position;
    if (position.maxScrollExtent <= 0 ||
        position.pixels <= 0 ||
        position.pixels < position.maxScrollExtent - 80) {
      return;
    }

    final phoneNumber = confirmPinController.numberController.text.trim();
    final requiredLength = _maximumPhoneLength;
    final isLookupModeActive =
        isOperatorLookupEnabled &&
        requiredLength > 0 &&
        phoneNumber.length == requiredLength;

    if (isLookupModeActive && !_hasMoreLookupBundles) return;

    final totalPages =
        bundleController.allbundleslist.value.payload?.pagination.totalPages ??
        0;
    if (totalPages > 0 && bundleController.initialpage >= totalPages) return;

    final previousBundles = bundleController.finalList.toList();
    final previousPage = bundleController.initialpage;
    final generation = _listGeneration;

    setState(() {
      _isLoadingMore = true;
      _loadingMoreSnapshot = previousBundles;
    });

    try {
      bundleController.initialpage = previousPage + 1;
      if (isLookupModeActive) {
        await bundleController.fetchlookupbundles(phoneNumber);
      } else {
        await bundleController.fetchallbundles();
      }

      if (!mounted || generation != _listGeneration) return;

      final fetchedBundles = bundleController.finalList.toList();
      final previousIds = previousBundles
          .map((bundle) => bundle.id?.toString())
          .whereType<String>()
          .toSet();
      final fetchedIds = fetchedBundles
          .map((bundle) => bundle.id?.toString())
          .whereType<String>()
          .toSet();

      final newBundles = fetchedBundles.where((bundle) {
        final id = bundle.id?.toString();
        return id == null || !previousIds.contains(id);
      }).toList();

      // Some lookup implementations replace finalList with only the new page.
      // Restore the earlier rows before showing the next page.
      if (previousIds.any((id) => !fetchedIds.contains(id))) {
        bundleController.finalList.assignAll([
          ...previousBundles,
          ...newBundles,
        ]);
      }

      if (isLookupModeActive && newBundles.isEmpty) {
        _hasMoreLookupBundles = false;
      }
    } catch (_) {
      if (mounted && generation == _listGeneration) {
        bundleController.initialpage = previousPage;
      }
    } finally {
      if (mounted && generation == _listGeneration) {
        setState(() {
          _isLoadingMore = false;
          _loadingMoreSnapshot = [];
        });
      }
    }
  }

  Future<void> _pullRefresh() async {
    _resetPaginationView();
    _clearInquiryNotice();
    final phoneNumber = confirmPinController.numberController.text.trim();
    final requiredLength = _maximumPhoneLength;
    bundleController.initialpage = 1;
    bundleController.finalList.clear();
    if (isOperatorLookupEnabled &&
        requiredLength > 0 &&
        phoneNumber.length == requiredLength) {
      await _fetchLookupWithNotice(phoneNumber);
      return;
    }
    await bundleController.fetchallbundles();
  }

  void _onTextChanged() {
    if (!mounted) {
      return;
    }
    final number = confirmPinController.numberController.text.trim();
    if (number == _lastProcessedNumber) {
      return;
    }
    _lastProcessedNumber = number;
    _resetPaginationView();
    _clearInquiryNotice();
    final requiredLength = _maximumPhoneLength;
    final services =
        serviceController.allserviceslist.value.data?.services ?? [];
    String? matchedOriginalCompanyId;
    for (final service in services) {
      final companyCodes = service.company?.companycodes ?? [];
      for (final code in companyCodes) {
        final reservedDigit = code.reservedDigit?.toString().trim() ?? "";
        if (reservedDigit.isEmpty) {
          continue;
        }
        final normalizedNumber = number.startsWith("0")
            ? number.substring(1)
            : number;
        final normalizedReservedDigit = reservedDigit.startsWith("0")
            ? reservedDigit.substring(1)
            : reservedDigit;
        final prefixMatched =
            number.startsWith(reservedDigit) ||
            normalizedNumber.startsWith(normalizedReservedDigit);
        if (prefixMatched) {
          matchedOriginalCompanyId = service.companyId?.toString();
          break;
        }
      }
      if (matchedOriginalCompanyId != null) {
        break;
      }
    }
    _lookupDebounce?.cancel();
    setState(() {
      inputNumber = number;
      originalCompanyId = matchedOriginalCompanyId;
      detectedCompanyId = null;
      isOperatorLookupConfirmed = false;
    });
    if (!isOperatorLookupEnabled) {
      _handleNormalNumber(number);
      return;
    }
    if (number.isEmpty) {
      setState(() {
        originalCompanyId = null;
        detectedCompanyId = null;
        isOperatorLookupConfirmed = false;
        selectedIndex = -1;
      });
      bundleController.initialpage = 1;
      bundleController.finalList.clear();
      bundleController.fetchallbundles();
      return;
    }
    if (requiredLength <= 0 || number.length != requiredLength) {
      return;
    }
    _lookupDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) {
        return;
      }
      final requestedNumber = confirmPinController.numberController.text.trim();
      if (requestedNumber != number) {
        return;
      }
      if (requestedNumber.length != requiredLength) {
        return;
      }
      bundleController.initialpage = 1;
      bundleController.finalList.clear();
      try {
        await _fetchLookupWithNotice(requestedNumber);
        if (!mounted) {
          return;
        }
        final latestNumber = confirmPinController.numberController.text.trim();
        if (latestNumber != requestedNumber) {
          return;
        }
        String? lookupCompanyId;
        if (bundleController.finalList.isNotEmpty) {
          final firstBundle = bundleController.finalList.first;
          lookupCompanyId = firstBundle.service?.company?.id?.toString();
        }
        setState(() {
          detectedCompanyId = lookupCompanyId;
          isOperatorLookupConfirmed = lookupCompanyId != null;
        });
      } catch (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          detectedCompanyId = null;
          isOperatorLookupConfirmed = false;
        });
      }
    });
  }

  Future<void> _handleNormalNumber(String number) async {
    _lookupDebounce?.cancel();
    final cleanNumber = number.trim();
    if (cleanNumber.isEmpty) {
      box.write("company_id", "");
      setState(() {
        selectedIndex = -1;
      });
      bundleController.initialpage = 1;
      bundleController.finalList.clear();
      await bundleController.fetchallbundles();
      return;
    }
    final services =
        serviceController.allserviceslist.value.data?.services ?? [];
    String? matchedCompanyId;
    for (final service in services) {
      final companyCodes = service.company?.companycodes ?? [];
      for (final code in companyCodes) {
        final reservedDigit = code.reservedDigit?.toString().trim() ?? "";
        if (reservedDigit.isEmpty) {
          continue;
        }
        final normalizedNumber = cleanNumber.startsWith("0")
            ? cleanNumber.substring(1)
            : cleanNumber;
        final normalizedReservedDigit = reservedDigit.startsWith("0")
            ? reservedDigit.substring(1)
            : reservedDigit;
        final matched =
            cleanNumber.startsWith(reservedDigit) ||
            normalizedNumber.startsWith(normalizedReservedDigit);
        if (matched) {
          matchedCompanyId = service.companyId?.toString();
          break;
        }
      }
      if (matchedCompanyId != null) {
        break;
      }
    }
    if (matchedCompanyId == null) {
      return;
    }
    final currentCompanyId = box.read("company_id")?.toString() ?? "";
    if (currentCompanyId == matchedCompanyId) {
      return;
    }
    await box.write("company_id", matchedCompanyId);
    bundleController.initialpage = 1;
    bundleController.finalList.clear();
    await bundleController.fetchallbundles();
  }

  // Existing recharge, lookup, pagination and PIN submission logic above
  // is intentionally kept unchanged. This section only redesigns the UI.
  final ThemeController themeController = Get.find<ThemeController>();

  bool get _dark => themeController.isDarkMode.value;
  Color get _background =>
      _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _inputSurface =>
      _dark ? AppColors.darkInputBackground : const Color(0xFFF3F9F5);
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _accent => AppColors.primaryColor;
  Color get _softGreen =>
      _dark ? const Color(0xFF193B2B) : const Color(0xFFE9F8EE);
  static const Color _mint = Color(0xFF18A65C);
  static const Color _orange = Color(0xFFD78E37);
  static const Color _red = Color(0xFFE07873);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = themeController.isDarkMode.value;
      final bars = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: _background,
        systemNavigationBarIconBrightness: dark
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
                _buildControlPanel(),
                const SizedBox(height: 11),
                Expanded(child: _buildBundleList()),
              ],
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
    final country = box.read('countryName')?.toString() ?? '';
    final title = '$country ${box.read("catName")}'.trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          _headerButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onTap: () {
              confirmPinController.numberController.clear();
              mypagecontroller.goBack();
            },
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 16,
                letterSpacing: -0.3,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _headerButton(
            icon: themeController.isDarkMode.value
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            tooltip: themeController.isDarkMode.value
                ? 'Light mode'
                : 'Dark mode',
            onTap: themeController.toggleTheme,
          ),
          const SizedBox(width: 8),
          _headerButton(
            icon: Icons.menu_rounded,
            tooltip: 'Menu',
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(11, 11, 11, 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
          // Keep the control panel flat: no second shadow around the phone input.
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preserve CustomTextField's phone formatter, length and permission
            // handling, but clip away its extra painted outer shadow/glow.
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.hardEdge,
              child: CustomTextField(
                confirmPinController: confirmPinController.numberController,
                languageData: languagesController.tr('ENTER_PHONE_NUMBER'),
              ),
            ),
            const SizedBox(height: 11),
            _buildOperators(),
            const SizedBox(height: 11),
            Container(height: 1, color: _border.withOpacity(0.7)),
            const SizedBox(height: 10),
            _buildDurationFilters(),
          ],
        ),
      ),
    );
  }

  Widget _buildOperators() {
    return SizedBox(
      height: 61,
      child: Obx(() {
        final services =
            serviceController.allserviceslist.value.data?.services ?? [];
        final isFullNumber =
            _maximumPhoneLength > 0 &&
            inputNumber.length == _maximumPhoneLength;
        final filteredServices = inputNumber.isEmpty
            ? services
            : isOperatorLookupEnabled
            ? services.where((service) {
                final id = service.companyId?.toString() ?? '';
                final original =
                    originalCompanyId != null && id == originalCompanyId;
                final detected =
                    isFullNumber &&
                    isOperatorLookupConfirmed &&
                    detectedCompanyId != null &&
                    id == detectedCompanyId;
                return original || detected;
              }).toList()
            : services.where((service) {
                return service.company?.companycodes?.any((code) {
                      final digit = code.reservedDigit?.toString() ?? '';
                      return digit.isNotEmpty && inputNumber.startsWith(digit);
                    }) ??
                    false;
              }).toList();

        if (serviceController.isLoading.value) {
          return Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: _mint),
            ),
          );
        }
        if (filteredServices.isEmpty) {
          return Center(
            child: Text(
              languagesController.tr('NO_DATA_FOUND'),
              style: TextStyle(color: _muted, fontSize: 12),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(filteredServices.length, (index) {
                  final service = filteredServices[index];
                  final companyId = service.companyId?.toString() ?? '';
                  final detected =
                      isOperatorLookupEnabled &&
                      isOperatorLookupConfirmed &&
                      inputNumber.length == _maximumPhoneLength &&
                      detectedCompanyId != null &&
                      companyId == detectedCompanyId;
                  final ported =
                      isOperatorLookupConfirmed &&
                      inputNumber.length == _maximumPhoneLength &&
                      originalCompanyId != null &&
                      detectedCompanyId != null &&
                      originalCompanyId != detectedCompanyId;
                  final selected =
                      isOperatorLookupEnabled &&
                          isOperatorLookupConfirmed &&
                          inputNumber.length == _maximumPhoneLength
                      ? detected
                      : selectedIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == filteredServices.length - 1 ? 0 : 9,
                    ),
                    child: _operatorCard(
                      data: service,
                      index: index,
                      isSelected: selected,
                      showPortedBadge: detected && ported,
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _operatorCard({
    required dynamic data,
    required int index,
    required bool isSelected,
    required bool showPortedBadge,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final isFullNumber =
              _maximumPhoneLength > 0 &&
              inputNumber.length == _maximumPhoneLength;
          if (isOperatorLookupEnabled &&
              isFullNumber &&
              isOperatorLookupConfirmed)
            return;
          _resetPaginationView();
          _clearInquiryNotice();
          setState(() {
            bundleController.initialpage = 1;
            bundleController.finalList.clear();
            selectedIndex = index;
            box.write('company_id', data.companyId);
          });
          await bundleController.fetchallbundles();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: showPortedBadge ? 75 : 62,
          height: 60,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? [_softGreen, _surface]
                  : [_surface, _inputSurface],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: showPortedBadge
                  ? _orange
                  : isSelected
                  ? _mint
                  : _border,
              width: isSelected ? 1.6 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _mint.withOpacity(_dark ? 0.13 : 0.13),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: data.company?.companyLogo ?? '',
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Center(
                    child: SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        color: _mint,
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) =>
                      Icon(Icons.sim_card_outlined, color: _muted, size: 21),
                ),
              ),
              if (isSelected)
                Positioned(
                  bottom: -3,
                  right: -3,
                  child: Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _mint,
                      border: Border.all(color: _surface, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 9,
                    ),
                  ),
                ),
              if (showPortedBadge)
                Positioned(
                  right: -7,
                  top: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _orange,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      languagesController.tr('PORTED'),
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationFilters() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: duration.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final selected = durationSelectedIndex == index;
          return InkWell(
            onTap: () async {
              _resetPaginationView();
              _clearInquiryNotice();
              setState(() => durationSelectedIndex = index);
              box.write('validity_type', duration[index]['Value']);
              bundleController.initialpage = 1;
              bundleController.finalList.clear();
              if (isOperatorLookupEnabled) {
                final number = confirmPinController.numberController.text
                    .trim();
                if (_maximumPhoneLength > 0 &&
                    number.length == _maximumPhoneLength) {
                  await _fetchLookupWithNotice(number);
                } else {
                  await bundleController.fetchallbundles();
                }
                return;
              }
              await bundleController.fetchallbundles();
            },
            borderRadius: BorderRadius.circular(11),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 190),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: selected ? _accent : _inputSurface,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: selected ? _accent : _border),
              ),
              child: Text(
                duration[index]['Name'] ?? '',
                style: TextStyle(
                  color: selected ? Colors.white : _muted,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Discard notices from older numbers, operator choices, and filters.
  void _clearInquiryNotice() {
    _noticeRequest++;
    _noticeNumber = null;
    _noticeResponse = null;
  }

  Future<void> _fetchLookupWithNotice(String number) async {
    final previousResponse = bundleController.allbundleslist.value;
    final request = ++_noticeRequest;
    _noticeNumber = null;
    _noticeResponse = null;

    await bundleController.fetchlookupbundles(number);

    if (!mounted ||
        request != _noticeRequest ||
        confirmPinController.numberController.text.trim() != number) {
      return;
    }

    final response = bundleController.allbundleslist.value;
    // Avoid displaying an old response if the API did not return a new one.
    if (identical(previousResponse, response)) return;

    setState(() {
      _noticeNumber = number;
      _noticeResponse = response;
    });
  }

  // The API puts these messages under payload.package_inquiry.
  // BundleModel / Payload must preserve this field when parsing JSON.
  dynamic _getPackageInquiry(dynamic response) {
    if (response == null) return null;

    dynamic payload;
    try {
      payload = response is Map ? response['payload'] : response.payload;
    } catch (_) {
      return null;
    }

    if (payload == null) return null;
    if (payload is Map) {
      return payload['packageInquiry'] ?? payload['package_inquiry'];
    }

    try {
      final dynamic inquiry = payload.packageInquiry;
      if (inquiry != null) return inquiry;
    } catch (_) {
      // Some models expose only toJson().
    }

    try {
      final dynamic serialized = payload.toJson();
      if (serialized is Map) {
        return serialized['packageInquiry'] ?? serialized['package_inquiry'];
      }
    } catch (_) {
      // A payload without package inquiry has no notice to show.
    }
    return null;
  }

  String? _inquiryMessage(dynamic inquiry, String name) {
    if (inquiry == null) return null;

    try {
      dynamic value;
      if (inquiry is Map) {
        String snakeKey = name;
        if (name == 'messageEn') {
          snakeKey = 'message_en';
        } else if (name == 'messageFa') {
          snakeKey = 'message_fa';
        } else if (name == 'messageTr') {
          snakeKey = 'message_tr';
        }
        value = inquiry[name] ?? inquiry[snakeKey];
      } else {
        switch (name) {
          case 'messageEn':
            value = inquiry.messageEn;
            break;
          case 'messageFa':
            value = inquiry.messageFa;
            break;
          case 'messageTr':
            value = inquiry.messageTr;
            break;
          case 'message':
            value = inquiry.message;
            break;
        }
      }
      final text = value?.toString().trim();
      return text == null || text.isEmpty ? null : text;
    } catch (_) {
      return null;
    }
  }

  String? _topLevelMessage(dynamic response) {
    try {
      final dynamic value = response is Map
          ? response['message']
          : response.message;
      final text = value?.toString().trim();
      return text == null || text.isEmpty ? null : text;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> _currentPackageInquiryMessages({
    bool includeResponseFallback = false,
  }) {
    final currentNumber = confirmPinController.numberController.text.trim();
    if (_noticeResponse == null ||
        _noticeNumber == null ||
        _noticeNumber != currentNumber) {
      return {};
    }

    // Using the initial lookup response prevents a later pagination response
    // from replacing the package inquiry notice with an unrelated message.
    final response = _noticeResponse;
    final inquiry = _getPackageInquiry(response);
    if (inquiry == null && !includeResponseFallback) return {};

    final english =
        _inquiryMessage(inquiry, 'messageEn') ??
        _inquiryMessage(inquiry, 'message') ??
        _topLevelMessage(response);

    final rawMessages = <String, String?>{
      'EN': english,
      'FA': _inquiryMessage(inquiry, 'messageFa'),
      'TR': _inquiryMessage(inquiry, 'messageTr'),
    };

    final messages = <String, String>{};
    for (final entry in rawMessages.entries) {
      final value = entry.value;
      if (value != null && value.isNotEmpty) {
        messages[entry.key] = value;
      }
    }
    return messages;
  }

  Widget _buildInquiryLanguageRow(String code, String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _inputSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 35,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: _softGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              code,
              style: TextStyle(
                color: _accent,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 24, color: _border),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              textDirection: code == 'FA'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              textAlign: code == 'FA' ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                color: _text,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageInquiryNoticeCard(Map<String, String> messages) {
    return Container(
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: _accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Package inquiry notice',
                  style: TextStyle(
                    color: _text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          for (final entry in messages.entries)
            _buildInquiryLanguageRow(entry.key, entry.value),
        ],
      ),
    );
  }

  Widget _buildBundleList() {
    final media = MediaQuery.of(context);
    final bottomSpace = media.viewInsets.bottom > 0
        ? 24.0
        : 76.0 + 38.0 + media.viewPadding.bottom;
    return Obx(() {
      final bundles = _isLoadingMore
          ? _loadingMoreSnapshot
          : bundleController.finalList;
      final loading =
          _isLoadingMore ||
          bundleController.isLoading.value ||
          bundleController.isLookupLoading.value;
      final inquiryMessages = _currentPackageInquiryMessages();
      final showInquiryNotice = inquiryMessages.isNotEmpty;
      if (loading && bundles.isEmpty) {
        return Center(child: CircularProgressIndicator(color: _mint));
      }
      if (bundles.isEmpty) {
        final emptyMessages = _currentPackageInquiryMessages(
          includeResponseFallback: true,
        );
        return RefreshIndicator(
          color: _mint,
          onRefresh: _pullRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 54, 16, bottomSpace),
            children: [
              Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: _softGreen,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(Icons.layers_outlined, color: _mint, size: 30),
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
              if (emptyMessages.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final entry in emptyMessages.entries)
                        _buildInquiryLanguageRow(entry.key, entry.value),
                      const SizedBox(height: 12),
                      Text(
                        'Please try another number or check again later.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }
      return RefreshIndicator(
        color: _mint,
        onRefresh: _pullRefresh,
        child: ListView.separated(
          controller: scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16, 2, 16, bottomSpace),
          itemCount:
              bundles.length + (showInquiryNotice ? 1 : 0) + (loading ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            if (index < bundles.length) {
              return _buildBundleCard(bundles[index]);
            }
            if (showInquiryNotice && index == bundles.length) {
              return _buildPackageInquiryNoticeCard(inquiryMessages);
            }
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: CircularProgressIndicator(color: _mint, strokeWidth: 2),
              ),
            );
          },
        ),
      );
    });
  }

  /// Original compact bundle-row layout, with a clean card border and shadow.
  /// No glossy overlay, 3D layers, or unnecessary minimum height.
  Widget _buildBundleCard(dynamic data) {
    final logo = data.service?.company?.companyLogo?.toString() ?? '';
    final currency = box.read('currency_code')?.toString() ?? '';
    final validity = _validityText(data.validityType?.toString());

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _validateAndOpenBundle(data),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _dark ? _border : const Color(0xFFE1EAE5),
            ),
            boxShadow: [
              BoxShadow(
                color: _dark
                    ? Colors.black.withOpacity(0.22)
                    : const Color(0xFF163B2A).withOpacity(0.09),
                blurRadius: 9,
                spreadRadius: -2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _inputSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border.withOpacity(0.65)),
                ),
                child: CachedNetworkImage(
                  imageUrl: logo,
                  fit: BoxFit.contain,
                  errorWidget: (_, __, ___) =>
                      Icon(Icons.business_outlined, color: _accent, size: 20),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.bundleTitle?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          languagesController.tr('BUY'),
                          style: const TextStyle(
                            color: _red,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: PriceTextView(
                            price: data.buyingPrice.toString(),
                            textStyle: const TextStyle(
                              color: _red,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            currency,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _red,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              // Give the right-side values a stable width and keep the
              // complete sale amount/currency on one horizontal line.
              SizedBox(
                width: 110,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (validity.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _softGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          validity,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _mint,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (validity.isNotEmpty) const SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      height: 18,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                languagesController.tr('SALE'),
                                maxLines: 1,
                                softWrap: false,
                                style: const TextStyle(
                                  color: _mint,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              PriceTextView(
                                price: data.sellingPrice.toString(),
                                textStyle: const TextStyle(
                                  color: _mint,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (currency.isNotEmpty) ...[
                                const SizedBox(width: 3),
                                Text(
                                  currency,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: const TextStyle(
                                    color: _mint,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }

  void _validateAndOpenBundle(dynamic data) {
    final number = confirmPinController.numberController.text.trim();
    if (number.isEmpty) {
      _toast(languagesController.tr('ENTER_PHONE_NUMBER'));
      return;
    }
    if (box.read('permission') == 'no' ||
        number.length.toString() != box.read('maxlength').toString()) {
      _toast(languagesController.tr('ENTER_CORRECT_NUMBER'));
      return;
    }
    box.write('bundleID', data.id.toString());
    _showBundleConfirmationDialog(data);
  }

  void _toast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color(0xFF23382C),
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  void _showBundleConfirmationDialog(dynamic data) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 17),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _border),
          ),
          child: Obx(
            () => confirmPinController.isLoading.value
                ? SizedBox(
                    height: 225,
                    child: Center(
                      child: Lottie.asset(
                        'assets/loties/recharge.json',
                        height: 170,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDialogHeader(data, dialogContext),
                        const SizedBox(height: 15),
                        _buildPriceBlock(data),
                        const SizedBox(height: 11),
                        _buildPhoneBlock(),
                        const SizedBox(height: 11),
                        _buildPinField(),
                        const SizedBox(height: 17),
                        _buildDialogActions(dialogContext),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogHeader(dynamic data, BuildContext dialogContext) {
    final logo = data.service?.company?.companyLogo?.toString() ?? '';
    final validity = _validityText(data.validityType?.toString());
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          width: 48,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _inputSurface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _border),
          ),
          child: CachedNetworkImage(
            imageUrl: logo,
            fit: BoxFit.contain,
            errorWidget: (_, __, ___) =>
                Icon(Icons.sim_card_rounded, color: _accent, size: 24),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.bundleTitle?.toString() ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
              if (validity.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  validity,
                  style: const TextStyle(
                    color: _mint,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => Navigator.pop(dialogContext),
          icon: Icon(Icons.close_rounded, color: _muted, size: 22),
        ),
      ],
    );
  }

  Widget _buildPriceBlock(dynamic data) {
    final currency = box.read('currency_code')?.toString() ?? '';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _inputSurface,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _dialogPriceRow(
            icon: Icons.shopping_bag_outlined,
            label: languagesController.tr('BUY'),
            price: data.buyingPrice.toString(),
            currency: currency,
            accent: _red,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(height: 1, color: _border),
          ),
          _dialogPriceRow(
            icon: Icons.sell_outlined,
            label: languagesController.tr('SELL'),
            price: data.sellingPrice.toString(),
            currency: currency,
            accent: _mint,
          ),
        ],
      ),
    );
  }

  Widget _dialogPriceRow({
    required IconData icon,
    required String label,
    required String price,
    required String currency,
    required Color accent,
  }) {
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withOpacity(_dark ? .15 : .09),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accent, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        PriceTextView(
          price: price,
          textStyle: TextStyle(
            color: accent,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          currency,
          style: TextStyle(
            color: accent,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneBlock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: _inputSurface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_iphone_rounded, color: _mint, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              languagesController.tr('PHONENUMBER'),
              style: TextStyle(color: _muted, fontSize: 11),
            ),
          ),
          Flexible(
            child: Text(
              confirmPinController.numberController.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinField() {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _mint.withOpacity(.30)),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline_rounded, color: _mint, size: 19),
          const SizedBox(height: 4),
          TextField(
            controller: confirmPinController.pinController,
            maxLength: 4,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            obscureText: true,
            cursorColor: _mint,
            style: TextStyle(
              color: _text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: languagesController.tr('PIN'),
              hintStyle: TextStyle(
                color: _muted,
                fontSize: 12,
                letterSpacing: 0,
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogActions(BuildContext dialogContext) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            onPressed: () async {
              if (confirmPinController.isLoading.value) return;
              if (confirmPinController.pinController.text.length != 4) {
                _toast(languagesController.tr('ENTER_YOUR_PIN'));
                return;
              }
              await confirmPinController.placeOrder(dialogContext);
            },
            icon: const Icon(Icons.verified_outlined, size: 19),
            label: Text(
              languagesController.tr('CONFIRMATION'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          flex: 2,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: _text,
              side: BorderSide(color: _border),
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              languagesController.tr('CANCEL'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  String _validityText(String? value) {
    switch (value?.toLowerCase()) {
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
}
