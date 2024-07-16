import 'package:get/get.dart';
import 'package:sample/src/domain/service/service_marketingexpense.dart';
import 'package:sample/src/domain/service/service_posmaterial.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyController extends GetxController {
  ServicePosMaterial servicePos = ServicePosMaterial();
  ServiceMarketingExpense serviceMe = ServiceMarketingExpense();

  var isCekIn = false.obs();
  var sessionId = "0".obs();
  var sessionRole = "".obs();
  var sessionUsername = "".obs();
  var sessionName = "".obs();
  var sessionDivisi = "".obs();

  var idSm = "".obs();
  var nameSm = "".obs();
  var tokenSm = "".obs();

  var idSales = "".obs();
  var nameSales = "".obs();
  var tokenSales = "".obs();

  getRole() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    sessionId = preferences.getString("id") ?? '0';
    sessionRole = preferences.getString("role") ?? '';
    sessionUsername = preferences.getString("username") ?? '';
    sessionName = preferences.getString("name") ?? '';
    sessionDivisi = preferences.getString("divisi") ?? '';

    getManagerToken(int.parse(sessionId));
  }

  getManagerToken(int idSales) {
    servicePos
        .generateTokenSm(context: Get.context!, idSales: idSales)
        .then((value) {
      idSm = value.id ?? "";
      nameSm = value.name ?? "";
      tokenSm = value.token ?? "";
    });
  }

  getSalesToken(String idMe) {
    serviceMe
        .generateTokenSales(context: Get.context!, idMe : idMe)
        .then((value) {
      idSales = value.id ?? "";
      nameSales = value.name ?? "";
      tokenSales = value.token ?? "";
    });
  }
}
