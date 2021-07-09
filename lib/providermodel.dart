import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ProviderModel with ChangeNotifier {
  final _iap = InAppPurchase.instance;
  bool available = true;
  StreamSubscription? subscription;
  String myProductID = 'subcription_test';
  String myProductID2 = 'monthly_sub30';

  bool _isPurchased = false;
  bool get isPurchasedd => _isPurchased;
  set isPurchased(bool value) {
    _isPurchased = value;
    notifyListeners();
  }

  List _purchases = [];
  List get purchases => _purchases;
  set purchases(List value) {
    _purchases = value;
    notifyListeners();
  }

  List _products = [];
  List get products => _products;
  set products(List value) {
    _products = value;
    notifyListeners();
    // purchases = [];
  }

  void initialize() async {
    available = await _iap.isAvailable();
    if (available) {
      await _getProducts();
      await _getPastPurchases();
      verifyPurchase();
      subscription = _iap.purchaseStream.listen((data) {
        print('😓 PURCHASE STREAM: ${data.first.status} ----${data.first.purchaseID} ---- ${data.first.verificationData}');
        purchases.addAll(data);
        verifyPurchase();
      });
    }
  }

  void verifyPurchase() {
    PurchaseDetails? purchase = hasPurchased(myProductID);
    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
        isPurchased = true;
      }
    }
  }

  PurchaseDetails? hasPurchased(String productID) {
    final smt = purchases.firstWhere(
      (purchase) => purchase.productID == productID,
      orElse: () => null,
    );
    return smt;
  }

  Future<void> _getProducts() async {
    Set<String> ids = Set.from([myProductID]);
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    products = response.productDetails;
    print('😓 PRODUCT: ${products.length}');

    notifyListeners();
    // print('😩:${products.first.price}');
  }

  Future<void> _getPastPurchases() async {
    // Set<String> ids = Set.from([myProductID]);
    // ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    // response.productDetails.forEach((element) {
    //   element.pas
    // });
    print('😓 GET PAST PURCHASE');
    _iap.restorePurchases();
  }
}
