import 'dart:io';

import 'package:onlinetelecom/controllers/currency_controller.dart';

import 'package:onlinetelecom/global_controller/languages_controller.dart';

import 'package:onlinetelecom/utils/colors.dart';

import 'package:onlinetelecom/widgets/custom_text.dart';

import 'package:onlinetelecom/widgets/socialbuttonbox.dart';

import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:onlinetelecom/global_controller/theme_controller.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get/get.dart';

import 'package:get_storage/get_storage.dart';

import 'package:url_launcher/url_launcher.dart';

import '../controllers/country_list_controller.dart';

import '../controllers/district_controller.dart';

import '../controllers/province_controller.dart';

import '../controllers/sign_up_controller.dart';

import '../models/currency_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final LanguagesController languagesController =
      Get.find<LanguagesController>();

  final CountryListController countryListController = Get.put(
    CountryListController(),
  );

  final ProvinceController provinceController = Get.put(ProvinceController());

  final DistrictController districtController = Get.put(DistrictController());

  final CurrencyController currencyController = Get.put(CurrencyController());

  final SignUpController signUpController = Get.put(SignUpController());

  final box = GetStorage();

  final ThemeController themeController = Get.find<ThemeController>();

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _primary => Theme.of(context).colorScheme.primary;

  Color get _textColor => Theme.of(context).colorScheme.onSurface;

  Color get _mutedColor =>
      _isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  Color get _surfaceColor =>
      _isDark ? AppColors.darkCard : AppColors.lightSurface;

  Color get _inputColor =>
      _isDark ? AppColors.darkInputBackground : AppColors.lightBackground;

  Color get _borderColor =>
      _isDark ? AppColors.darkBorder : AppColors.lightBorder;

  final String phoneNumber = "+989386344752";

  String selectedCountry = "";

  String selectedProvince = "";

  String selectedDistrict = "";

  bool isPasswordVisible = false;

  bool isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    countryListController.fetchCountryData();

    districtController.fetchDistrict();

    provinceController.fetchProvince();

    currencyController.fetchCurrencyList();
  }

  bool get isRtl {
    final direction = box.read("direction")?.toString().toLowerCase();

    return direction == "rtl";
  }

  Alignment get fieldAlignment =>
      isRtl ? Alignment.centerRight : Alignment.centerLeft;

  TextAlign get fieldTextAlign => isRtl ? TextAlign.right : TextAlign.left;

  Widget _labelledField(String label, Widget child, {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [
          _fieldLabel(label, optional: optional),

          const SizedBox(height: 7),

          child,
        ],
      ),
    );
  }

  Widget _formPanel({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: _surfaceColor,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: _borderColor),

        boxShadow: _isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(.055),

                  blurRadius: 28,

                  offset: const Offset(0, 10),
                ),
              ],
      ),

      child: child,
    );
  }

  Widget _photoPicker() => Obx(
    () => GestureDetector(
      onTap: () async {
        await signUpController.uploadImage();

        if (mounted) setState(() {});
      },

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),

        decoration: BoxDecoration(
          color: _inputColor,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: _borderColor),
        ),

        child: Column(
          children: [
            Container(
              width: 86,

              height: 86,

              padding: const EdgeInsets.all(4),

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                border: Border.all(color: _primary.withOpacity(.5), width: 1.5),
              ),

              child: ClipOval(
                child:
                    signUpController.selectedImagePath.value.isNotEmpty &&
                        signUpController.imageFile != null
                    ? Image.file(signUpController.imageFile!, fit: BoxFit.cover)
                    : Icon(
                        Icons.add_a_photo_outlined,

                        color: _primary,

                        size: 32,
                      ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              languagesController.tr('UPLOAD_PHOTO'),

              style: TextStyle(
                color: _mutedColor,

                fontSize: 12,

                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _passwordField({
    required TextEditingController controller,

    required String hint,

    required bool visible,

    required VoidCallback onToggle,

    required IconData icon,
  }) {
    return _authField(
      controller: controller,

      hintText: hint,

      icon: icon,

      obscureText: !visible,

      suffixIcon: IconButton(
        onPressed: onToggle,

        icon: Icon(
          visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,

          size: 20,

          color: _mutedColor,
        ),
      ),
    );
  }

  Widget _registerButton() => Obx(() {
    final loading = signUpController.isLoading.value;

    return SizedBox(
      height: 54,

      width: double.infinity,

      child: ElevatedButton(
        onPressed: loading
            ? null
            : () async {
                final error = signUpController.validateInputs();

                if (error != null) {
                  Get.snackbar(
                    languagesController.tr('INVALID_INPUT'),

                    error,

                    backgroundColor: _surfaceColor,

                    colorText: _textColor,

                    snackPosition: SnackPosition.BOTTOM,
                  );

                  return;
                }

                await signUpController.registernow();
              },

        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,

          foregroundColor: Theme.of(context).colorScheme.onPrimary,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        child: loading
            ? SizedBox(
                height: 20,

                width: 20,

                child: CircularProgressIndicator(
                  strokeWidth: 2,

                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : Text(
                languagesController.tr('REGISTER'),

                style: const TextStyle(
                  fontWeight: FontWeight.w800,

                  fontSize: 15,
                ),
              ),
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    final width = MediaQuery.sizeOf(context).width;

    final background = _isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,

              systemNavigationBarColor: background,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,

              systemNavigationBarColor: background,
            ),

      child: Scaffold(
        backgroundColor: background,

        resizeToAvoidBottomInset: true,

        body: SafeArea(
          child: Column(
            children: [
              // Header is OUTSIDE the scrolling form and always stays at the top.
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 3, 12, 5),

                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',

                      onPressed: () => Get.back(),

                      icon: Icon(Icons.arrow_back_rounded, color: _textColor),
                    ),

                    const Spacer(),

                    Obx(
                      () => IconButton(
                        tooltip: themeController.isDarkMode.value
                            ? 'Light mode'
                            : 'Dark mode',

                        onPressed: themeController.toggleTheme,

                        icon: Icon(
                          themeController.isDarkMode.value
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,

                          color: _textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),

                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,

                  padding: EdgeInsets.fromLTRB(
                    width < 360 ? 14 : 20,

                    8,

                    width < 360 ? 14 : 20,

                    28,
                  ),

                  children: [
                    Center(
                      child: Container(
                        width: 104,

                        height: 104,

                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: _surfaceColor,

                          borderRadius: BorderRadius.circular(28),

                          border: Border.all(color: _borderColor),

                          boxShadow: _isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withOpacity(
                                      .10,
                                    ),

                                    blurRadius: 26,

                                    offset: const Offset(0, 10),
                                  ),
                                ],
                        ),

                        child: Image.asset(
                          'assets/icons/logo.png',

                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      languagesController.tr('REGISTER'),

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: _textColor,

                        fontSize: 27,

                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 22),

                    _formPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          _labelledField(
                            languagesController.tr('FULL_NAME'),

                            _authField(
                              controller:
                                  signUpController.resellerNameController,

                              hintText: languagesController.tr(
                                'ENTER_YOUR_FULL_NAME',
                              ),

                              icon: Icons.person_outline_rounded,
                            ),
                          ),

                          _labelledField(
                            languagesController.tr('CONTACT_NAME'),

                            _authField(
                              controller:
                                  signUpController.contactNameController,

                              hintText: languagesController.tr(
                                'ENTER_CONTACT_NAME',
                              ),

                              icon: Icons.badge_outlined,
                            ),
                          ),

                          _labelledField(
                            languagesController.tr('PHONE_NUMBER'),

                            _authField(
                              controller: signUpController.phoneController,

                              hintText: languagesController.tr(
                                'ENTER_PHONE_NUMBER',
                              ),

                              keyboardType: TextInputType.phone,

                              icon: Icons.phone_outlined,
                            ),
                          ),

                          _labelledField(
                            languagesController.tr('EMAIL'),

                            _authField(
                              controller: signUpController.emailController,

                              hintText: languagesController.tr('EMAIL_ADDRESS'),

                              keyboardType: TextInputType.emailAddress,

                              icon: Icons.email_outlined,
                            ),

                            optional: true,
                          ),

                          _labelledField(
                            languagesController.tr('CURRENCY'),

                            _currencyDropdown(screenHeight),
                          ),

                          _labelledField(
                            languagesController.tr('COUNTRY_OF_RESIDENCE'),

                            _countryDropdown(screenHeight),
                          ),

                          _labelledField(
                            languagesController.tr('PROVINCE'),

                            _provinceDropdown(screenHeight),

                            optional: true,
                          ),

                          _labelledField(
                            languagesController.tr('DISTRICT'),

                            _districtDropdown(screenHeight),

                            optional: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    _formPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          _photoPicker(),

                          const SizedBox(height: 18),

                          _fieldLabel(
                            languagesController.tr('IDENTITY_ATTACHMENT'),

                            optional: true,
                          ),

                          const SizedBox(height: 8),

                          Obx(
                            () => _uploadBox(
                              hasImage: signUpController
                                  .selectedIdentityPath
                                  .value
                                  .isNotEmpty,

                              imagePath:
                                  signUpController.selectedIdentityPath.value,

                              emptyText: languagesController.tr(
                                'TAP_TO_UPLOAD_IDENTITY_IMAGE',
                              ),

                              onTap: () async {
                                await signUpController
                                    .uploadIdentityAttachment();

                                if (mounted) setState(() {});
                              },

                              onRemove: () =>
                                  signUpController.selectedIdentityPath.value =
                                      '',
                            ),
                          ),

                          const SizedBox(height: 16),

                          _fieldLabel(
                            languagesController.tr('EXTRA_PROOF'),

                            optional: true,
                          ),

                          const SizedBox(height: 8),

                          Obx(
                            () => _uploadBox(
                              hasImage: signUpController
                                  .selectedExtraProofPath
                                  .value
                                  .isNotEmpty,

                              imagePath:
                                  signUpController.selectedExtraProofPath.value,

                              emptyText: languagesController.tr(
                                'TAP_TO_UPLOAD_EXTRA_PROOF',
                              ),

                              onTap: () async {
                                await signUpController
                                    .uploadExtraOptionalProof();

                                if (mounted) setState(() {});
                              },

                              onRemove: () =>
                                  signUpController
                                          .selectedExtraProofPath
                                          .value =
                                      '',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    _formPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          _labelledField(
                            languagesController.tr('ENTER_YOUR_PIN'),

                            _authField(
                              controller: signUpController.pinController,

                              hintText: languagesController.tr('NEW_PIN'),

                              icon: Icons.pin_outlined,

                              keyboardType: TextInputType.number,
                            ),

                            optional: true,
                          ),

                          _labelledField(
                            languagesController.tr('CONFIRM_PIN'),

                            _authField(
                              controller: signUpController.confirmPinController,

                              hintText: languagesController.tr('CONFIRM_PIN'),

                              icon: Icons.verified_user_outlined,

                              keyboardType: TextInputType.number,
                            ),

                            optional: true,
                          ),

                          _labelledField(
                            languagesController.tr('PASSWORD'),

                            _passwordField(
                              controller: signUpController.passwordController,

                              hint: languagesController.tr('PASSWORD'),

                              visible: isPasswordVisible,

                              onToggle: () => setState(
                                () => isPasswordVisible = !isPasswordVisible,
                              ),

                              icon: Icons.lock_outline_rounded,
                            ),
                          ),

                          _labelledField(
                            languagesController.tr('CONFIRM_PASSWORD'),

                            _passwordField(
                              controller:
                                  signUpController.confirmPassController,

                              hint: languagesController.tr('CONFIRM_PASSWORD'),

                              visible: isConfirmPasswordVisible,

                              onToggle: () => setState(
                                () => isConfirmPasswordVisible =
                                    !isConfirmPasswordVisible,
                              ),

                              icon: Icons.lock_reset_outlined,
                            ),
                          ),

                          _registerButton(),

                          const SizedBox(height: 18),

                          Wrap(
                            alignment: WrapAlignment.center,

                            crossAxisAlignment: WrapCrossAlignment.center,

                            spacing: 5,

                            runSpacing: 5,

                            children: [
                              Text(
                                languagesController.tr('ALREADY_REGISTERED'),

                                style: TextStyle(
                                  color: _mutedColor,

                                  fontSize: 13,
                                ),
                              ),

                              GestureDetector(
                                onTap: () => Get.back(),

                                child: Text(
                                  languagesController.tr('LOGIN'),

                                  style: TextStyle(
                                    color: _primary,

                                    fontWeight: FontWeight.w800,

                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 23),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text, {bool optional = false}) {
    return Row(
      children: [
        Flexible(
          child: NText(
            text: text,

            color: _textColor.withOpacity(0.88),

            fontWeight: FontWeight.w600,

            fontSize: 13.5,
          ),
        ),

        if (optional) ...[
          const SizedBox(width: 5),

          NText(
            text: "(${languagesController.tr("OPTIONAL")})",

            color: _mutedColor,

            fontSize: 12,
          ),
        ],
      ],
    );
  }

  /// ============================================================

  /// AUTH FIELD

  /// ============================================================

  Widget _authField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    // Match the sign-in field: one border and vertically centered text.
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textAlign: fieldTextAlign,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: _primary,
        style: TextStyle(
          color: _textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: _mutedColor, fontSize: 14),
          prefixIcon: Icon(icon, size: 20, color: _mutedColor),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 46,
            minHeight: 48,
          ),
          suffixIcon: suffixIcon,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 46,
            minHeight: 48,
          ),
          isDense: true,
          filled: true,
          fillColor: _inputColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  /// DROPDOWN WRAPPER

  Widget _dropdownWrapper({required Widget child}) {
    return Container(
      height: 50,

      padding: const EdgeInsets.symmetric(horizontal: 14),

      decoration: BoxDecoration(
        color: _inputColor,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: _primary.withOpacity(0.28)),

        boxShadow: [
          BoxShadow(color: _primary.withOpacity(0.045), blurRadius: 10),
        ],
      ),

      alignment: Alignment.center,

      child: child,
    );
  }

  Widget _dropdownIcon() {
    return FaIcon(FontAwesomeIcons.chevronDown, color: _primary, size: 14);
  }

  /// ============================================================

  /// CURRENCY DROPDOWN

  /// ============================================================

  Widget _currencyDropdown(double screenHeight) {
    return _dropdownWrapper(
      child: Obx(() {
        final List<Currency> currencies =
            currencyController.allcurrencylist.value.data?.currencies ??
            <Currency>[];

        final List<Currency> usable = currencies
            .where((currency) => currency.id != null)
            .toList();

        final String? selectedCurrencyId =
            signUpController.currencyId.value.isEmpty
            ? null
            : signUpController.currencyId.value;

        final bool selectedExists =
            selectedCurrencyId != null &&
            usable.any(
              (currency) => currency.id.toString() == selectedCurrencyId,
            );

        final String? currentValue = selectedExists ? selectedCurrencyId : null;

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,

            value: currentValue,

            dropdownColor: _surfaceColor,

            icon: _dropdownIcon(),

            borderRadius: BorderRadius.circular(12),

            hint: Align(
              alignment: fieldAlignment,

              child: NText(
                text: languagesController.tr("CURRENCY"),

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                color: _mutedColor,

                fontSize: 14,

                textAlign: fieldTextAlign,
              ),
            ),

            selectedItemBuilder: (context) {
              return usable.map<Widget>((currency) {
                return Align(
                  alignment: fieldAlignment,

                  child: NText(
                    text: _currencyName(currency),

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    color: _textColor,

                    fontSize: 14,

                    fontWeight: FontWeight.w500,

                    textAlign: fieldTextAlign,
                  ),
                );
              }).toList();
            },

            items: usable.map<DropdownMenuItem<String>>((currency) {
              return DropdownMenuItem<String>(
                value: currency.id.toString(),

                child: Align(
                  alignment: fieldAlignment,

                  child: NText(
                    text: _currencyName(currency),

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    color: _textColor,

                    fontSize: 14,

                    fontWeight: FontWeight.w500,

                    textAlign: fieldTextAlign,
                  ),
                ),
              );
            }).toList(),

            onChanged: (value) {
              if (value == null) {
                return;
              }

              signUpController.currencyId.value = value;
            },
          ),
        );
      }),
    );
  }

  String _currencyName(Currency currency) {
    final name = (currency.name ?? '').trim();

    final code = (currency.code ?? '').trim();

    final symbol = (currency.symbol ?? '').trim();

    if (name.isNotEmpty && code.isNotEmpty) {
      return "$name ($code)";
    }

    if (code.isNotEmpty && symbol.isNotEmpty) {
      return "$code ($symbol)";
    }

    if (code.isNotEmpty) {
      return code;
    }

    if (symbol.isNotEmpty) {
      return symbol;
    }

    return name;
  }

  /// ============================================================

  /// COUNTRY DROPDOWN

  /// ============================================================

  Widget _countryDropdown(double screenHeight) {
    return _dropdownWrapper(
      child: Obx(() {
        final countries =
            countryListController.allcountryListData.value.data?.countries ??
            <dynamic>[];

        final String? selectedCountryId =
            signUpController.countryId.value.isEmpty
            ? null
            : signUpController.countryId.value;

        final bool selectedExists =
            selectedCountryId != null &&
            countries.any(
              (country) =>
                  ((country?.id) ?? '').toString() == selectedCountryId,
            );

        final String? currentValue = selectedExists ? selectedCountryId : null;

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,

            value: currentValue,

            dropdownColor: _surfaceColor,

            borderRadius: BorderRadius.circular(12),

            icon: _dropdownIcon(),

            hint: Align(
              alignment: fieldAlignment,

              child: NText(
                text: languagesController.tr("COUNTRY_OF_RESIDENCE"),

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                color: _mutedColor,

                fontSize: 14,

                textAlign: fieldTextAlign,
              ),
            ),

            selectedItemBuilder: (context) {
              return countries.map<Widget>((country) {
                final name = ((country?.countryName) ?? '').toString();

                return Align(
                  alignment: fieldAlignment,

                  child: NText(
                    text: name,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    color: _textColor,

                    fontSize: 14,

                    fontWeight: FontWeight.w500,

                    textAlign: fieldTextAlign,
                  ),
                );
              }).toList();
            },

            items: countries.map<DropdownMenuItem<String>>((country) {
              final id = ((country?.id) ?? '').toString();

              final name = ((country?.countryName) ?? '').toString();

              final flagUrl = ((country?.countryFlagImageUrl) ?? '').toString();

              return DropdownMenuItem<String>(
                value: id,

                child: Row(
                  children: [
                    if (flagUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),

                        child: Image.network(
                          flagUrl,

                          height: 24,

                          width: 36,

                          fit: BoxFit.cover,

                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox();
                          },
                        ),
                      ),

                    if (flagUrl.isNotEmpty) const SizedBox(width: 10),

                    Expanded(
                      child: NText(
                        text: name,

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,

                        color: _textColor,

                        fontSize: 14,

                        fontWeight: FontWeight.w500,

                        textAlign: fieldTextAlign,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            onChanged: (value) {
              if (value == null) {
                return;
              }

              dynamic picked;

              for (final country in countries) {
                if (((country?.id) ?? '').toString() == value) {
                  picked = country;

                  break;
                }
              }

              signUpController.countryId.value = value;

              selectedCountry = ((picked?.countryName) ?? '').toString();

              setState(() {});
            },
          ),
        );
      }),
    );
  }

  /// ============================================================

  /// PROVINCE DROPDOWN

  /// ============================================================

  Widget _provinceDropdown(double screenHeight) {
    return _dropdownWrapper(
      child: Obx(() {
        final provinces =
            provinceController.allprovincelist.value.data?.provinces ??
            <dynamic>[];

        final String? selectedProvinceId =
            signUpController.provinceId.value.isEmpty
            ? null
            : signUpController.provinceId.value;

        final bool selectedExists =
            selectedProvinceId != null &&
            provinces.any(
              (province) =>
                  ((province?.id) ?? '').toString() == selectedProvinceId,
            );

        final String? currentValue = selectedExists ? selectedProvinceId : null;

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,

            value: currentValue,

            dropdownColor: _surfaceColor,

            borderRadius: BorderRadius.circular(12),

            icon: _dropdownIcon(),

            hint: Align(
              alignment: fieldAlignment,

              child: NText(
                text: languagesController.tr("PROVINCE"),

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                color: _mutedColor,

                fontSize: 14,

                textAlign: fieldTextAlign,
              ),
            ),

            selectedItemBuilder: (context) {
              return provinces.map<Widget>((province) {
                final name = ((province?.provinceName) ?? '').toString();

                return Align(
                  alignment: fieldAlignment,

                  child: NText(
                    text: name,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    color: _textColor,

                    fontSize: 14,

                    fontWeight: FontWeight.w500,

                    textAlign: fieldTextAlign,
                  ),
                );
              }).toList();
            },

            items: provinces.map<DropdownMenuItem<String>>((province) {
              final id = ((province?.id) ?? '').toString();

              final name = ((province?.provinceName) ?? '').toString();

              return DropdownMenuItem<String>(
                value: id,

                child: Align(
                  alignment: fieldAlignment,

                  child: NText(
                    text: name,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    color: _textColor,

                    fontSize: 14,

                    fontWeight: FontWeight.w500,

                    textAlign: fieldTextAlign,
                  ),
                ),
              );
            }).toList(),

            onChanged: (value) {
              if (value == null) {
                return;
              }

              dynamic picked;

              for (final province in provinces) {
                if (((province?.id) ?? '').toString() == value) {
                  picked = province;

                  break;
                }
              }

              signUpController.provinceId.value = value;

              selectedProvince = ((picked?.provinceName) ?? '').toString();

              setState(() {});
            },
          ),
        );
      }),
    );
  }

  /// ============================================================

  /// DISTRICT DROPDOWN

  /// ============================================================

  Widget _districtDropdown(double screenHeight) {
    return _dropdownWrapper(
      child: Obx(() {
        final districts =
            districtController.alldistrictList.value.data?.districts ??
            <dynamic>[];

        final String? selectedDistrictId =
            signUpController.districtID.value.isEmpty
            ? null
            : signUpController.districtID.value;

        final bool selectedExists =
            selectedDistrictId != null &&
            districts.any(
              (district) =>
                  ((district?.id) ?? '').toString() == selectedDistrictId,
            );

        final String? currentValue = selectedExists ? selectedDistrictId : null;

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,

            value: currentValue,

            dropdownColor: _surfaceColor,

            borderRadius: BorderRadius.circular(12),

            icon: _dropdownIcon(),

            hint: Align(
              alignment: fieldAlignment,

              child: NText(
                text: languagesController.tr("DISTRICT"),

                maxLines: 1,

                overflow: TextOverflow.ellipsis,

                color: _mutedColor,

                fontSize: 14,

                textAlign: fieldTextAlign,
              ),
            ),

            selectedItemBuilder: (context) {
              return districts.map<Widget>((district) {
                final name = ((district?.districtName) ?? '').toString();

                return Align(
                  alignment: fieldAlignment,

                  child: NText(
                    text: name,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    color: _textColor,

                    fontSize: 14,

                    fontWeight: FontWeight.w500,

                    textAlign: fieldTextAlign,
                  ),
                );
              }).toList();
            },

            items: districts.map<DropdownMenuItem<String>>((district) {
              final id = ((district?.id) ?? '').toString();

              final name = ((district?.districtName) ?? '').toString();

              return DropdownMenuItem<String>(
                value: id,

                child: Align(
                  alignment: fieldAlignment,

                  child: NText(
                    text: name,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    color: _textColor,

                    fontSize: 14,

                    fontWeight: FontWeight.w500,

                    textAlign: fieldTextAlign,
                  ),
                ),
              );
            }).toList(),

            onChanged: (value) {
              if (value == null) {
                return;
              }

              dynamic picked;

              for (final district in districts) {
                if (((district?.id) ?? '').toString() == value) {
                  picked = district;

                  break;
                }
              }

              signUpController.districtID.value = value;

              selectedDistrict = ((picked?.districtName) ?? '').toString();

              setState(() {});
            },
          ),
        );
      }),
    );
  }

  /// ============================================================

  /// UPLOAD BOX

  /// ============================================================

  Widget _uploadBox({
    required bool hasImage,

    required String imagePath,

    required String emptyText,

    required VoidCallback onTap,

    required VoidCallback onRemove,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: DottedBorder(
        color: _primary.withOpacity(0.28),

        strokeWidth: 1.4,

        dashPattern: const [6, 4],

        borderType: BorderType.RRect,

        radius: const Radius.circular(14),

        child: Container(
          width: double.infinity,

          height: 115,

          decoration: BoxDecoration(
            color: _inputColor,

            borderRadius: BorderRadius.circular(16),
          ),

          child: hasImage
              ? Stack(
                  fit: StackFit.expand,

                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),

                      child: Image.file(File(imagePath), fit: BoxFit.cover),
                    ),

                    Positioned(
                      top: 7,

                      right: 7,

                      child: GestureDetector(
                        onTap: onRemove,

                        child: Container(
                          height: 30,

                          width: 30,

                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.65),

                            shape: BoxShape.circle,
                          ),

                          child: Icon(Icons.close, color: _textColor, size: 17),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Image.asset("assets/icons/upload_image.png", height: 28),

                    const SizedBox(height: 7),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),

                      child: NText(
                        text: emptyText,

                        textAlign: TextAlign.center,

                        color: _mutedColor,

                        fontSize: 13,

                        height: 1.35,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
