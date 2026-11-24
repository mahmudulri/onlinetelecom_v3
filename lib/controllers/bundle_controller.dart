import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/bundle_model.dart';
import '../services/bundle_service.dart';

class BundleController extends GetxController {
  int initialpage = 0; // Last successfully loaded page

  final RxList<Bundle> finalList = <Bundle>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLookupLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxBool hasError = false.obs;
  final Rx<BundleModel> allbundleslist = BundleModel().obs;

  int _requestId = 0;
  String? _phone;

  bool get isLookupMode => _phone != null;
  String? get activeLookupNumber => _phone;
  bool get isFetching => isLoading.value || isLookupLoading.value;

  void _reset({String? phone}) {
    _requestId++; // Ignore pending responses from the previous query
    _phone = phone;
    initialpage = 0;
    finalList.clear();
    allbundleslist.value = BundleModel();
    hasMore.value = true;
    hasError.value = false;
    isLoading.value = false;
    isLookupLoading.value = false;
  }

  Future<void> fetchallbundles({bool reset = false}) async {
    if (reset || isLookupMode) _reset();
    await _fetchPage(initialpage == 0 ? 1 : initialpage);
  }

  Future<void> fetchlookupbundles(
    String phoneNumber, {
    bool reset = true,
  }) async {
    final number = phoneNumber.trim();
    if (number.isEmpty) return;
    if (reset || _phone != number) _reset(phone: number);
    await _fetchPage(initialpage == 0 ? 1 : initialpage);
  }

  Future<void> loadMoreBundles() async {
    if (isFetching || !hasMore.value || initialpage == 0) return;
    await _fetchPage(initialpage + 1);
  }

  Future<void> _fetchPage(int page) async {
    if (isFetching || (page > 1 && !hasMore.value)) return;

    final request = _requestId;
    final number = _phone;
    final lookup = number != null;
    if (lookup) {
      isLookupLoading.value = true;
    } else {
      isLoading.value = true;
    }
    hasError.value = false;

    try {
      final api = BundlesApi();
      final response = lookup
          ? await api.fetchlookupBundles(number!, pageNo: page)
          : await api.fetchBundles(page);
      if (request != _requestId) return;

      final bundles = response.data?.bundles ?? <Bundle>[];
      final totalPages = response.payload?.pagination.totalPages ?? 0;
      allbundleslist.value = response;

      int added = 0;
      if (page == 1) {
        finalList.assignAll(bundles);
        added = bundles.length;
      } else {
        final ids = finalList
            .where((bundle) => bundle.id != null)
            .map((bundle) => bundle.id.toString())
            .toSet();
        for (final bundle in bundles) {
          if (bundle.id == null || ids.add(bundle.id.toString())) {
            finalList.add(bundle);
            added++;
          }
        }
      }

      initialpage = page;
      hasMore.value =
          added > 0 &&
          (totalPages > 0
              ? page < totalPages
              : bundles.length >= BundlesApi.perPage);

      debugPrint(
        'Bundles page=$page, lookup=$lookup, total=${finalList.length}',
      );
    } catch (e) {
      if (request != _requestId) return;
      hasError.value = true;
      debugPrint('Bundles error (page $page): $e');
    } finally {
      if (request == _requestId) {
        isLoading.value = false;
        isLookupLoading.value = false;
      }
    }
  }

  void resetBundles() => _reset();
}
