import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/screens/traiteur/form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TraiteurButtonView extends StatelessWidget {
  final bool web;
  const TraiteurButtonView({this.web = false,Key key}) : super(key: key);
  dialog(BuildContext context){
    showDialog(
      context: context, 
      builder:(context) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFFF1F1F1),

        ),
        child: TraiteurForm(),
      ),
      );
    },);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: web ? 250 : Dimensions.WEB_MAX_WIDTH,
      height: 90,
      margin: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL, right: Dimensions.PADDING_SIZE_SMALL, top: Dimensions.PADDING_SIZE_DEFAULT, bottom: web ?  Dimensions.PADDING_SIZE_DEFAULT : 0),
      padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
        boxShadow: [
          BoxShadow(
          color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
          blurRadius: 5, spreadRadius: 1,
        )],
      ),
      child: InkWell(
        onTap: web ? ()=> dialog(context) : null,
        child:  Row(children: [

     Expanded(child: CustomButton(buttonText: 'service_traiteur'.tr, height: 50, onPressed: ()=>dialog(context)))
           //       Expanded(child: CustomButton(buttonText: 'service_traiteur'.tr, width: 150, height: 50, onPressed: ()=>dialog(context))),

     // Image.asset(Images.ic_launcher, height: 64, width: 64, fit: BoxFit.cover),
        //SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
      /*web? Expanded(
          child: !web ? SizedBox.shrink() : Text(
            'service_traiteur'.tr, textAlign: TextAlign.start,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
        ):Container(),
        if(!web)*/
    //    Expanded(child: CustomButton(buttonText: 'service_traiteur'.tr, width: 150, height: 50, onPressed: ()=>dialog(context))),

      ]),),
    );
  }
}
