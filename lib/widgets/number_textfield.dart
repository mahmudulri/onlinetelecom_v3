import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onlinetelecom/global_controller/font_controller.dart';
import 'package:onlinetelecom/global_controller/theme_controller.dart';
import 'package:onlinetelecom/utils/colors.dart';
import 'package:onlinetelecom/widgets/custom_text.dart';

/// Accept only ASCII (English) digits, including when users paste a number.
class PasteRestrictionFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(newValue.text)) {
      Get.snackbar(
        'Error',
        'Only English number format is allowed',
        colorText: Colors.white,
        duration: const Duration(milliseconds: 1000),
        backgroundColor: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      return oldValue;
    }

    return newValue;
  }
}

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.confirmPinController,
    required this.languageData,
  });

  final TextEditingController confirmPinController;
  final String languageData;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final GetStorage box = GetStorage();
  final ThemeController themeController = Get.find<ThemeController>();
  final FocusNode _numberFocusNode = FocusNode();

  String? errorMessage;

  int get maximumLength {
    return int.tryParse(box.read('maxlength')?.toString() ?? '') ?? 20;
  }

  void validateInput(String input) {
    if (!mounted) return;

    final String cleanInput = input.trim();
    final bool valid =
        cleanInput.isNotEmpty && cleanInput.length == maximumLength;

    // Keep the permission values and validation behavior of the old widget.
    box.write('permission', valid ? 'yes' : 'no');

    if (errorMessage != null) {
      setState(() => errorMessage = null);
    }
  }

  @override
  void dispose() {
    _numberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isDark = themeController.isDarkMode.value;
      final Color textColor = isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary;
      final Color hintColor = isDark
          ? AppColors.darkTextSecondary
          : AppColors.lightTextSecondary;
      final Color fieldColor = isDark
          ? AppColors.darkInputBackground
          : const Color(0xFFF3F9F5);
      final Color borderColor = isDark
          ? AppColors.darkBorder
          : const Color(0xFFDCE9E0);
      const Color activeColor = AppColors.primaryColor;

      final String? fontFamily = box.read('language')?.toString() == 'Fa'
          ? Get.find<FontController>().currentFont
          : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // One decorated input only. No nested Container, shadow or overlay.
          SizedBox(
            height: 50,
            width: double.infinity,
            child: TextField(
              controller: widget.confirmPinController,
              focusNode: _numberFocusNode,
              autofocus: false,
              maxLines: 1,
              maxLength: maximumLength,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              cursorColor: activeColor,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: fontFamily,
              ),
              inputFormatters: [
                PasteRestrictionFormatter(),
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(maximumLength),
              ],
              decoration: InputDecoration(
                hintText: widget.languageData,
                hintStyle: TextStyle(
                  color: hintColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: fontFamily,
                ),
                counterText: '',
                filled: true,
                fillColor: fieldColor,
                prefixIcon: Icon(
                  Icons.phone_iphone_rounded,
                  size: 19,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.primaryColor,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 45,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: activeColor, width: 1.4),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE05263),
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFE05263),
                    width: 1.4,
                  ),
                ),
              ),
              onChanged: validateInput,
              onSubmitted: (_) => _numberFocusNode.unfocus(),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 5),
            NText(
              text: errorMessage!,
              color: const Color(0xFFE05263),
              fontSize: 12,
            ),
          ],
        ],
      );
    });
  }
}
