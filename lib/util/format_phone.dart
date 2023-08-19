import 'package:country_code_picker/country_code_picker.dart';
import 'package:libphonenumber_plugin/libphonenumber_plugin.dart';


Future<String> getInternationalPhoneNumber(String region,String number) async {
  Map<String,String> isoCode = codes.firstWhere((code) => code["dial_code"] == region, orElse: ()=>{
    "code": "MA",
    "dial_code": "+212",
  });
  String _number = number.replaceFirst(RegExp("^0"), "").replaceAll(RegExp(r"[^\d\+]"), "");
  String phone = "${isoCode["dial_code"]}${_number}".replaceAll(RegExp(r"[^\d\+]"), "");
  print("0. "+phone);
  try {
    var ok = await PhoneNumberUtil.isValidPhoneNumber(
      _number.replaceAll(RegExp(r"[^\d\+]"), ""),
      isoCode["code"],
    );
    if(!ok){
      phone = "${isoCode["dial_code"]}0${_number}".replaceAll(RegExp(r"[^\d\+]"), "");
      print("1. "+phone);
      ok = await PhoneNumberUtil.isValidPhoneNumber(
        "0"+_number.replaceAll(RegExp(r"[^\d\+]"), ""),
        isoCode["code"],
      );
      if (ok)
        return "$phone";
    }else {
      return "$phone";
    }
  } catch (e) {
  }
  return "";
}
