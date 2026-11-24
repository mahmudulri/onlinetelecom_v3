import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onlinetelecom/controllers/add_sub_reseller_controller.dart';
import 'package:onlinetelecom/controllers/commission_group_controller.dart';
import 'package:onlinetelecom/controllers/country_list_controller.dart';
import 'package:onlinetelecom/controllers/district_controller.dart';
import 'package:onlinetelecom/controllers/province_controller.dart';
import 'package:onlinetelecom/global_controller/languages_controller.dart';
import 'package:onlinetelecom/global_controller/page_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/bottomsheet.dart';

class AddNewUser extends StatefulWidget {
  const AddNewUser({super.key});
  @override
  State<AddNewUser> createState() => _AddNewUserState();
}

class _AddNewUserState extends State<AddNewUser> {
  final GetStorage box = GetStorage();
  final Mypagecontroller mypagecontroller = Get.find<Mypagecontroller>();
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  // EXACTLY the shared controller / reactive toggle pattern from Network.
  final ThemeController themeController = Get.find<ThemeController>();
  final AddSubResellerController addSubResellerController = Get.put(
    AddSubResellerController(),
  );
  final CountryListController countryListController = Get.put(
    CountryListController(),
  );
  final ProvinceController provinceController = Get.put(ProvinceController());
  final DistrictController districtController = Get.put(DistrictController());
  final CommissionGroupController commissionlistController = Get.put(
    CommissionGroupController(),
  );
  String selectedCommissionGroup = '';
  String selectedCountry = '';
  String selectedProvince = '';
  String selectedDistrict = '';
  bool get _dark => themeController.isDarkMode.value;
  Color get _bg => _dark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get _surface => _dark ? AppColors.darkCard : AppColors.lightSurface;
  Color get _field =>
      _dark ? AppColors.darkInputBackground : const Color(0xFFF6FAF7);
  Color get _text =>
      _dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get _muted =>
      _dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get _border => _dark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get _accent => AppColors.primaryColor;
  Color get _accentSoft =>
      _dark ? const Color(0xFF1D3829) : const Color(0xFFE9F7ED);
  @override
  void initState() {
    super.initState();
    _resetDataFields();
    commissionlistController.fetchGrouplist();
  }

  // Preserve existing controller values and create-user request behavior.
  void _resetDataFields() {
    addSubResellerController.groupId.value = '';
    selectedCommissionGroup = '';
    addSubResellerController.countryId.value = '';
    selectedCountry = '';
    addSubResellerController.provinceId.value = '';
    selectedProvince = '';
    addSubResellerController.districtID.value = '';
    selectedDistrict = '';
  }

  @override
  Widget build(BuildContext context) {
    // Observing the theme on the ENTIRE page is important: header, controls,
    // dropdowns, submit button and system bars all change together.
    return Obx(() {
      final isDarkMode = themeController.isDarkMode.value;
      final media = MediaQuery.of(context);
      final bottomSpace = media.viewInsets.bottom > 0
          ? 24.0
          : 76.0 + 38.0 + media.viewPadding.bottom;
      final overlay = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDarkMode
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        systemNavigationBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
      );
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay,
        child: Scaffold(
          backgroundColor: _bg,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(16, 0, 16, bottomSpace),
                    children: [
                      _buildPhotoFeature(),
                      const SizedBox(height: 19),
                      _buildPersonalSection(),
                      const SizedBox(height: 18),
                      _buildLocationSection(),
                      const SizedBox(height: 18),
                      _buildDocumentsSection(),
                      const SizedBox(height: 16),
                      _buildSubmitButton(),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // -------------------------------------------------------------------------
  // HEADER: same 42x42 Material + InkWell + border as Network's _headerIcon,
  // including the same toggleTheme behavior.
  // -------------------------------------------------------------------------
  Widget _headerIcon({
    required Widget icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: _dark ? AppColors.darkCard : AppColors.lightSurface,
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
            onTap: mypagecontroller.goBack,
            icon: Icon(Icons.arrow_back_rounded, size: 22, color: _text),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              languagesController.tr('ADD_USER'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _headerIcon(
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
          const SizedBox(width: 9),
          _headerIcon(
            tooltip: 'Menu',
            onTap: () => CustomFullScreenSheet.show(context),
            icon: Icon(Icons.menu_rounded, size: 22, color: _text),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // PROFILE: a small horizontal identity strip, not the previous large form
  // hero card. Tapping the photo still invokes uploadImage().
  // -------------------------------------------------------------------------
  Widget _buildPhotoFeature() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Obx(() {
            final path = addSubResellerController.selectedImagePath.value;
            final photo = addSubResellerController.imageFile;
            return GestureDetector(
              onTap: () async {
                await addSubResellerController.uploadImage();
                if (mounted) setState(() {});
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _accentSoft,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _accent.withOpacity(.20)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: path.isNotEmpty && photo != null
                          ? Image.file(
                              photo,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _photoPlaceholder(),
                            )
                          : _photoPlaceholder(),
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      width: 23,
                      height: 23,
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _surface, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languagesController.tr('UPLOAD_PHOTO'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  languagesController.tr('ADD_USER'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _muted, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.add_a_photo_outlined, color: _accent, size: 17),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() => Container(
    color: _accentSoft,
    alignment: Alignment.center,
    child: Icon(Icons.person_outline_rounded, size: 29, color: _accent),
  );
  // -------------------------------------------------------------------------
  // SECTION STYLE: floating label and left-hand numbered marker, not the old
  // cards with oversized numbered headings and horizontal dividers.
  // -------------------------------------------------------------------------
  Widget _sectionHeader(String index, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10),
      child: Row(
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: _accentSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: _accent, size: 16),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _text,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            index,
            style: TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _formSurface(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_dark ? .075 : .018),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _label(String key, {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Flexible(
            child: Text(
              languagesController.tr(key),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.6,
                fontWeight: FontWeight.w700,
                color: _text,
              ),
            ),
          ),
          if (optional) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '(${languagesController.tr('OPTIONAL')})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _muted, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  BoxDecoration _inputBoxDecoration() {
    return BoxDecoration(
      color: _field,
      borderRadius: BorderRadius.circular(11),
      border: Border.all(color: _border),
    );
  }

  Widget _fieldInput({
    required String labelKey,
    required String hintKey,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool optional = false,
  }) {
    final radius = BorderRadius.circular(11);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(labelKey, optional: optional),
        SizedBox(
          height: 45,
          child: TextField(
            controller: controller,
            cursorColor: _accent,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              color: _text,
              fontSize: 12.8,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              // The input itself owns its ONLY background and border.
              // Explicit options override global InputDecorationTheme defaults.
              filled: true,
              fillColor: _field,
              prefixIcon: Icon(icon, color: _accent, size: 18),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 41,
                minHeight: 41,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              hintText: languagesController.tr(hintKey),
              hintMaxLines: 1,
              hintStyle: TextStyle(color: _muted, fontSize: 11.5),
              border: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: _accent, width: 1.25),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: _border),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalSection() {
    return Column(
      children: [
        _sectionHeader(
          '01',
          Icons.badge_outlined,
          languagesController.tr('FULL_NAME'),
        ),
        _formSurface([
          _fieldInput(
            labelKey: 'FULL_NAME',
            hintKey: 'ADD_FIRST_AND_LAST_NAME',
            icon: Icons.storefront_outlined,
            controller: addSubResellerController.resellerNameController,
          ),
          const SizedBox(height: 12),
          _fieldInput(
            labelKey: 'CONTACT_NAME',
            hintKey: 'CONTACT_NAME',
            icon: Icons.person_outline_rounded,
            controller: addSubResellerController.contactNameController,
          ),
          const SizedBox(height: 12),
          _fieldInput(
            labelKey: 'PHONENUMBER',
            hintKey: 'ENTER_PHONE_NUMBER',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            controller: addSubResellerController.phoneController,
          ),
          const SizedBox(height: 12),
          _fieldInput(
            labelKey: 'EMAIL',
            hintKey: 'ENTER_EMAIL_ADDRESS',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            controller: addSubResellerController.emailController,
            optional: true,
          ),
          const SizedBox(height: 12),
          _label('COMMISSION_GROUP'),
          _buildCommissionDropdown(),
        ]),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      children: [
        _sectionHeader(
          '02',
          Icons.travel_explore_outlined,
          languagesController.tr('COUNTRY_OF_RESIDENCE'),
        ),
        _formSurface([
          _label('COUNTRY_OF_RESIDENCE'),
          _buildCountryDropdown(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_label('PROVINCE'), _buildProvinceDropdown()],
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_label('DISTRICT'), _buildDistrictDropdown()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _label('DESIRED_CURRENCY'),
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 13),
            decoration: _inputBoxDecoration(),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 17,
                  color: _accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    box.read('currency_code')?.toString() ?? '',
                    style: TextStyle(
                      color: _text,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(Icons.lock_outline_rounded, size: 15, color: _muted),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // DATA: unchanged GetX sources and reactive controller field assignments.
  // -------------------------------------------------------------------------
  Widget _buildCommissionDropdown() {
    return Obx(() {
      final groups =
          commissionlistController.allgrouplist.value.data?.groups ?? [];
      final options = <MapEntry<String, String>>[
        for (final group in groups)
          MapEntry(group.id.toString(), group.groupName?.toString() ?? ''),
      ];
      return _buildPicker(
        options: options,
        currentValue: addSubResellerController.groupId.value,
        fallback: selectedCommissionGroup,
        icon: Icons.percent_rounded,
        onChanged: (value) {
          addSubResellerController.groupId.value = value;
          selectedCommissionGroup = _nameOf(options, value);
          setState(() {});
        },
      );
    });
  }

  Widget _buildCountryDropdown() {
    return Obx(() {
      final countries =
          countryListController.allcountryListData.value.data?.countries ?? [];
      final options = <MapEntry<String, String>>[
        for (final country in countries)
          MapEntry(
            country.id.toString(),
            country.countryName?.toString() ?? '',
          ),
      ];
      return _buildPicker(
        options: options,
        currentValue: addSubResellerController.countryId.value,
        fallback: selectedCountry,
        icon: Icons.public_rounded,
        onChanged: (value) {
          addSubResellerController.countryId.value = value;
          selectedCountry = _nameOf(options, value);
          setState(() {});
        },
      );
    });
  }

  Widget _buildProvinceDropdown() {
    return Obx(() {
      final provinces =
          provinceController.allprovincelist.value.data?.provinces ?? [];
      final options = <MapEntry<String, String>>[
        for (final province in provinces)
          MapEntry(
            province.id.toString(),
            province.provinceName?.toString() ?? '',
          ),
      ];
      return _buildPicker(
        options: options,
        currentValue: addSubResellerController.provinceId.value,
        fallback: selectedProvince,
        icon: Icons.map_outlined,
        onChanged: (value) {
          addSubResellerController.provinceId.value = value;
          selectedProvince = _nameOf(options, value);
          setState(() {});
        },
      );
    });
  }

  Widget _buildDistrictDropdown() {
    return Obx(() {
      final districts =
          districtController.alldistrictList.value.data?.districts ?? [];
      final options = <MapEntry<String, String>>[
        for (final district in districts)
          MapEntry(
            district.id.toString(),
            district.districtName?.toString() ?? '',
          ),
      ];
      return _buildPicker(
        options: options,
        currentValue: addSubResellerController.districtID.value,
        fallback: selectedDistrict,
        icon: Icons.location_city_outlined,
        onChanged: (value) {
          addSubResellerController.districtID.value = value;
          selectedDistrict = _nameOf(options, value);
          setState(() {});
        },
      );
    });
  }

  String _nameOf(List<MapEntry<String, String>> options, String value) {
    for (final entry in options) {
      if (entry.key == value) return entry.value;
    }
    return '';
  }

  Widget _buildPicker({
    required List<MapEntry<String, String>> options,
    required String currentValue,
    required String fallback,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    final pickedValue = options.any((entry) => entry.key == currentValue)
        ? currentValue
        : null;
    return Container(
      height: 45,
      padding: const EdgeInsets.only(left: 10, right: 6),
      decoration: _inputBoxDecoration(),
      child: Row(
        children: [
          Icon(icon, color: _accent, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: pickedValue,
                dropdownColor: _surface,
                borderRadius: BorderRadius.circular(12),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _accent,
                  size: 19,
                ),
                hint: Text(
                  fallback.isEmpty ? '—' : fallback,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: _muted),
                ),
                selectedItemBuilder: (context) => [
                  for (final item in options)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _text,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
                items: [
                  for (final item in options)
                    DropdownMenuItem<String>(
                      value: item.key,
                      child: Text(
                        item.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _text, fontSize: 12),
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) onChanged(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // DOCUMENTS: compact paired upload tiles. Both upload/remove operations
  // invoke the same controller methods as the original page.
  // -------------------------------------------------------------------------
  Widget _buildDocumentsSection() {
    return Column(
      children: [
        _sectionHeader(
          '03',
          Icons.folder_open_outlined,
          languagesController.tr('IDENTITY_ATTACHMENT'),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(
                () => _documentTile(
                  title: languagesController.tr('IDENTITY_ATTACHMENT'),
                  placeholder: languagesController.tr(
                    'TAP_TO_UPLOAD_IDENTITY_IMAGE',
                  ),
                  path: addSubResellerController.selectedIdentityPath.value,
                  onUpload: () async {
                    await addSubResellerController.uploadIdentityAttachment();
                    if (mounted) setState(() {});
                  },
                  onRemove: () {
                    addSubResellerController.selectedIdentityPath.value = '';
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(
                () => _documentTile(
                  title: languagesController.tr('EXTRA_PROOF'),
                  placeholder: languagesController.tr(
                    'TAP_TO_UPLOAD_EXTRA_PROOF',
                  ),
                  path: addSubResellerController.selectedExtraProofPath.value,
                  onUpload: () async {
                    await addSubResellerController.uploadExtraOptionalProof();
                    if (mounted) setState(() {});
                  },
                  onRemove: () {
                    addSubResellerController.selectedExtraProofPath.value = '';
                    setState(() {});
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _documentTile({
    required String title,
    required String placeholder,
    required String path,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    final hasImage = path.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 10, 9, 9),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontSize: 11.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            languagesController.tr('OPTIONAL'),
            style: TextStyle(color: _muted, fontSize: 9.5),
          ),
          const SizedBox(height: 8),
          DottedBorder(
            color: _accent.withOpacity(_dark ? .38 : .28),
            dashPattern: const [5, 4],
            strokeWidth: 1.2,
            borderType: BorderType.RRect,
            radius: const Radius.circular(11),
            child: Material(
              color: _field,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: onUpload,
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 101,
                  width: double.infinity,
                  child: hasImage
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(path),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _emptyDocument(placeholder),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: onRemove,
                                child: Container(
                                  height: 26,
                                  width: 26,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(.67),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _emptyDocument(placeholder),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyDocument(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined, size: 23, color: _accent),
          const SizedBox(height: 5),
          Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 9.5, height: 1.2),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Submit follows the identity attachment inside the scrollable form.
  // -------------------------------------------------------------------------
  // Submit sits immediately after Identity Attachment and Extra Proof.
  // Keeping it inside the ListView prevents overlap with the bottom navigation.
  Widget _buildSubmitButton() {
    return Obx(() {
      final loading = addSubResellerController.isLoading.value;
      return SizedBox(
        height: 48,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: loading ? null : _submitUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            disabledBackgroundColor: _muted.withOpacity(.33),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.person_add_alt_1_rounded, size: 19),
              const SizedBox(width: 9),
              Text(
                loading
                    ? languagesController.tr('PLEASE_WAIT')
                    : languagesController.tr('ADD_NOW'),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _submitUser() {
    if (addSubResellerController.resellerNameController.text.isEmpty ||
        addSubResellerController.contactNameController.text.isEmpty ||
        addSubResellerController.phoneController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: languagesController.tr('FILL_DATA_CORRECTLY'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    addSubResellerController.addNow();
  }
}
