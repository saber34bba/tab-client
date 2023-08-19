import 'package:efood_multivendor/data/repository/traiteur_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class TraiteurController extends GetxController implements GetxService {
  final TraiteurRepo traiteurRepo;
  TraiteurController({@required this.traiteurRepo});
  bool _submitting = false;

  bool get isSubmitting => _submitting;


  Future<bool> askTraiteur(Map<String, String> data) async {
    _submitting = true;
    update();
    try {
      Response response = await traiteurRepo.askTraiteur(data);
      return response.body["success"] ?? false;
    } finally {
      _submitting = false;
      update();
    }
    return false;
  }
}