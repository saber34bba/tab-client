//import 'package:country_code_picker/country_code.dart';

import 'package:efood_multivendor/controller/traiteur_controller.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/screens/auth/widget/code_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/custom_snackbar.dart';

class TraiteurForm extends StatefulWidget {
  const TraiteurForm({Key key}) : super(key: key);

  @override
  State<TraiteurForm> createState() => _TraiteurFormState();
}

class _TraiteurFormState extends State<TraiteurForm> {
  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _evenementController = TextEditingController();
  final TextEditingController _personneNumberController =
      TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _fNameNode = FocusNode();
  final FocusNode _lNameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _phoneNode = FocusNode();
  final FocusNode _evenementNode = FocusNode();
  final FocusNode _evenementNumberNode = FocusNode();
  final FocusNode _personneNumberNode = FocusNode();
  final FocusNode _budgetNode = FocusNode();
  final FocusNode _descriptionNode = FocusNode();
  String _countryDialCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: GetBuilder<TraiteurController>(builder: (traiteur) {
        return Column(children: [
          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
          Align(
              alignment: Alignment.center,
              child: Text(
                'service_traiteur'.tr,
                style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeOverLarge),
              )),
          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
          Expanded(
              child: SingleChildScrollView(
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            physics: BouncingScrollPhysics(),
            child: Center(
                child: SizedBox(
                    width: Dimensions.WEB_MAX_WIDTH,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                          Row(children: [
                            Expanded(
                                child: CustomTextField(
                              hintText: 'first_name'.tr,
                              controller: _fNameController,
                              capitalization: TextCapitalization.words,
                              inputType: TextInputType.name,
                              focusNode: _fNameNode,
                              nextFocus: _lNameNode,
                              showTitle: true,
                            )),
                            SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                            Expanded(
                                child: CustomTextField(
                              hintText: 'last_name'.tr,
                              controller: _lNameController,
                              capitalization: TextCapitalization.words,
                              inputType: TextInputType.name,
                              focusNode: _lNameNode,
                              nextFocus: _emailNode,
                              showTitle: true,
                            )),
                          ]),
                          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                          CustomTextField(
                            hintText: 'email'.tr,
                            controller: _emailController,
                            focusNode: _emailNode,
                            nextFocus: _phoneNode,
                            inputType: TextInputType.emailAddress,
                            showTitle: true,
                          ),
                          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                            Text('phone'.tr,
                                style:
                                    robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        SizedBox(
                            height:Dimensions.PADDING_SIZE_EXTRA_SMALL ),
                          Row(children: [
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.RADIUS_SMALL),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors
                                          .grey[Get.isDarkMode ? 800 : 200],
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 5))
                                ],
                              ),
                              child: CodePickerWidget(
                                onChanged: (/*CountryCode*/ countryCode) {
                                  _countryDialCode = countryCode.dialCode;
                                },
                                initialSelection: _countryDialCode ?? null,
                                favorite: [_countryDialCode]
                                    .whereType<String>()
                                    .toList(),
                                showDropDownButton: true,
                                padding: EdgeInsets.zero,
                                showFlagMain: true,
                                flagWidth: 30,
                                dialogBackgroundColor: Theme.of(context).cardColor,
                                textStyle: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color,
                                ),
                              ),
                            ),
                            SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                            Expanded(
                                flex: 1,
                                child: CustomTextField(
                                  hintText: 'phoneHint'.tr,
                                  controller: _phoneController,
                                  focusNode: _phoneNode,
                                  nextFocus: _evenementNode,
                                  inputType: TextInputType.phone,
                                )),
                          ]),
                          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                          CustomTextField(
                            hintText: 'evenement'.tr,
                            controller: _evenementController,
                            focusNode: _evenementNode,
                            nextFocus: _personneNumberNode,
                            inputType: TextInputType.name,
                            showTitle: true,
                          ),
                          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                          CustomTextField(
                            hintText: 'nb_personnes'.tr,
                            controller: _personneNumberController,
                            focusNode: _personneNumberNode,
                            nextFocus: _budgetNode,
                            inputType: TextInputType.number,
                            isNumber: true,
                            showTitle: true,
                          ),
                          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                          CustomTextField(
                            hintText: 'budget'.tr,
                            controller: _budgetController,
                            focusNode: _budgetNode,
                            nextFocus: _descriptionNode,
                            inputType: TextInputType.number,
                            isAmount: true,
                            showTitle: true,
                          ),
                          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                          CustomTextField(
                            hintText: 'description'.tr,
                            controller: _descriptionController,
                            focusNode: _descriptionNode,
                            nextFocus: _descriptionNode,
                            inputType: TextInputType.multiline,
                            showTitle: true,
                            maxLines: 6,
                          ),
                          SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                        ]))),
          )),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              !traiteur.isSubmitting
                  ? CustomButton(
                width: MediaQuery.of(context).size.width / 2 -
                    (Dimensions.PADDING_SIZE_SMALL * 2),
                buttonText: 'close'.tr,
                margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                height: 50,
                onPressed: () => Get.back(),
                color: Colors.grey,
              ) : SizedBox.shrink(),
              CustomButton(
                      width: MediaQuery.of(context).size.width / 2 -
                          (Dimensions.PADDING_SIZE_SMALL * 2),
                      buttonText: !traiteur.isSubmitting ?  'submit'.tr : null,
                      child: !traiteur.isSubmitting ?  null: Center(child: CircularProgressIndicator(color: Colors.white,)),
                      margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      height: 50,
                      onPressed: traiteur.isSubmitting ?  null: () => _submit(traiteur),
                    ),
            ],
          )
        ]);
      }),
    );
  }

  _submit(TraiteurController user) async {
    String _fName = _fNameController.text.trim();
    String _lName = _lNameController.text.trim();
    String _email = _emailController.text.trim();
    String _phone = _phoneController.text.trim();
    String _evenement = _evenementController.text.trim();
    String _personneNumber = _personneNumberController.text.trim();
    String _budget = _budgetController.text.trim();
    String _description = _descriptionController.text.trim();


  
    if (_fName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    } else if (_lName.isEmpty) {
      showCustomSnackBar('enter_your_name'.tr);
    } else if (_email.isEmpty) {
      showCustomSnackBar('enter_email_address'.tr);
    } else if (!GetUtils.isEmail(_email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    } else if (_phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else {
      Map<String, String> data = {
        "prenom": _fName,
        "nom": _lName,
        "email": _email,
        "phone": _phone,
        "event": _evenement,
        "personnes": _personneNumber,
        "budget": _budget,
        "description": _description,
      };
      print(data);
      bool ret = await user.askTraiteur(data);
      if(ret){
        Get.back();
        showCustomSnackBar('send'.tr);
      } else {
        showCustomSnackBar('retry'.tr);
      }
    }
  }
}
