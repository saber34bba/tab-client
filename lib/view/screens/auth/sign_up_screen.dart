import 'dart:convert';
//import 'package:country_code_picker/country_code.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/data/model/body/signup_body.dart';
import 'package:efood_multivendor/data/model/body/social_log_in_body.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/format_phone.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/base/web_menu_bar.dart';
import 'package:efood_multivendor/view/screens/auth/widget/code_picker_widget.dart';
import 'package:efood_multivendor/view/screens/auth/widget/condition_check_box.dart';
import 'package:efood_multivendor/view/screens/auth/widget/guest_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/platform/platform_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as Http;
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _referCodeController = TextEditingController();
  String _countryDialCode;

  @override
  void initState() {
    super.initState();

    _countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel.country).dialCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? WebMenuBar() : null,
      body: SafeArea(child: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          physics: BouncingScrollPhysics(),
          child: Center(
            child: Container(
              width: context.width > 700 ? 700 : context.width,
              padding: context.width > 700 ? EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT) : null,
              decoration: context.width > 700 ? BoxDecoration(
                color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300], blurRadius: 5, spreadRadius: 1)],
              ) : null,
              child: GetBuilder<AuthController>(builder: (authController) {

                return Column(children: [

                  Image.asset(Images.logo, width: 100),
                  if(Images.logo_name.isNotEmpty)
                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  if(Images.logo_name.isNotEmpty)
                    Image.asset(Images.logo_name, width: 100),
                  SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),

                  Text('sign_up'.tr.toUpperCase(), style: robotoBlack.copyWith(fontSize: 30)),
                  SizedBox(height: 50),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 1, blurRadius: 5)],
                    ),
                    child: Column(children: [

                      CustomTextField(
                        hintText: 'first_name'.tr,
                        controller: _firstNameController,
                        focusNode: _firstNameFocus,
                        nextFocus: _lastNameFocus,
                        inputType: TextInputType.name,
                        capitalization: TextCapitalization.words,
                        prefixIcon: Images.user,
                        divider: true,
                      ),

                      CustomTextField(
                        hintText: 'last_name'.tr,
                        controller: _lastNameController,
                        focusNode: _lastNameFocus,
                        nextFocus: _emailFocus,
                        inputType: TextInputType.name,
                        capitalization: TextCapitalization.words,
                        prefixIcon: Images.user,
                        divider: true,
                      ),

                      CustomTextField(
                        hintText: 'email'.tr,
                        controller: _emailController,
                        focusNode: _emailFocus,
                        nextFocus: _phoneFocus,
                        inputType: TextInputType.emailAddress,
                        prefixIcon: Images.mail,
                        divider: true,
                      ),

                      Row(children: [
                        CodePickerWidget(
                          onChanged: (CountryCode countryCode) {
                            _countryDialCode = countryCode.dialCode;
                          },
                          initialSelection: CountryCode.fromCountryCode(Get.find<SplashController>().configModel.country).code,
                          favorite: [CountryCode.fromCountryCode(Get.find<SplashController>().configModel.country).code],
                          showDropDownButton: true,
                          padding: EdgeInsets.zero,
                          showFlagMain: true,
                          dialogBackgroundColor: Theme.of(context).cardColor,
                          textStyle: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyText1.color,
                          ),
                        ),
                        Expanded(child: CustomTextField(
                          hintText: 'phoneHint'.tr,
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          nextFocus: _passwordFocus,
                          inputType: TextInputType.phone,
                          divider: false,
                        )),
                      ]),
                      Padding(padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE), child: Divider(height: 1)),

                      CustomTextField(
                        hintText: 'password'.tr,
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        nextFocus: _confirmPasswordFocus,
                        inputType: TextInputType.visiblePassword,
                        prefixIcon: Images.lock,
                        isPassword: true,
                        divider: true,
                      ),

                      CustomTextField(
                        hintText: 'confirm_password'.tr,
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        nextFocus: Get.find<SplashController>().configModel.refEarningStatus == 1 ? _referCodeFocus : null,
                        inputAction: Get.find<SplashController>().configModel.refEarningStatus == 1 ? TextInputAction.next : TextInputAction.done,
                        inputType: TextInputType.visiblePassword,
                        prefixIcon: Images.lock,
                        isPassword: true,
                        divider: Get.find<SplashController>().configModel.refEarningStatus == 1 ? true : false,
                        onSubmit: (text) => (GetPlatform.isWeb && authController.acceptTerms) ? _register(authController, _countryDialCode) : null,
                      ),

                      (Get.find<SplashController>().configModel.refEarningStatus == 1 ) ? CustomTextField(
                        hintText: 'refer_code'.tr,
                        controller: _referCodeController,
                        focusNode: _referCodeFocus,
                        inputAction: TextInputAction.done,
                        inputType: TextInputType.text,
                        capitalization: TextCapitalization.words,
                        prefixIcon: Images.refer_code,
                        divider: false,
                        prefixSize: 14,
                      ) : SizedBox(),

                    ]),
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                  ConditionCheckBox(authController: authController),
                     SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  Padding(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.grey,
              ),
            ),
            SizedBox(width: 10,),
         Text('or_signup_with'.tr, style: robotoRegular),
             SizedBox(width: 10,),
              Expanded(
              child: Container(
                height: 1,
                color: Colors.grey,
              ),
            ),
          ]),
          
        
        ),
             SizedBox(height: Dimensions.PADDING_SIZE_SMALL), 
                  socialWidget(authController,_phoneController),
                     SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
     SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  !authController.isLoading ? Row(children: [
                    Expanded(child: CustomButton(
                      buttonText: 'sign_in'.tr,
                      transparent: true,
                      onPressed: () =>Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.signUp)),
                    )),
                    Expanded(child: CustomButton(
                      buttonText: 'sign_up'.tr,
                      onPressed: authController.acceptTerms ? () => _register(authController, _countryDialCode) : null,
                    )),
                  ]) : Center(child: CircularProgressIndicator()),
                  SizedBox(height: 30),

                  // SocialLoginWidget(),

                  GuestButton(),

                ]);
              }),
            ),
          ),
        ),
      )),
    );
  }

  void _register(AuthController authController, String countryCode) async {
    String _firstName = _firstNameController.text.trim();
    String _lastName = _lastNameController.text.trim();
    String _email = _emailController.text.trim();
    String _number = _phoneController.text.trim();
    String _password = _passwordController.text.trim();
    String _confirmPassword = _confirmPasswordController.text.trim();
    String _referCode = _referCodeController.text.trim();

    

    String _numberWithCountryCode = countryCode+_number;
    bool _isValid = false;
    _numberWithCountryCode = await getInternationalPhoneNumber(countryCode,_number);
    if(_numberWithCountryCode.isNotEmpty) {
        _isValid = true;
    }
    if(!_isValid || _number.isEmpty){
      _isValid = false;
    }

    if (_firstName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    }else if (_lastName.isEmpty) {
      showCustomSnackBar('enter_your_last_name'.tr);
    }else if (_email.isEmpty) {
      showCustomSnackBar('enter_email_address'.tr);
    }else if (!GetUtils.isEmail(_email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    }else if (_number.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (!_isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    }else if (_password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    }else if (_password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    }else if (_password != _confirmPassword) {
      showCustomSnackBar('confirm_password_does_not_matched'.tr);
    }else if (_referCode.isNotEmpty && _referCode.length != 10) {
      showCustomSnackBar('invalid_refer_code'.tr);
    }else {
      SignUpBody signUpBody = SignUpBody(
        fName: _firstName, lName: _lastName, email: _email, phone: _numberWithCountryCode, password: _password,
        refCode: _referCode,
      );
      authController.registration(signUpBody).then((status) async {
        if (status.isSuccess) {
          if(Get.find<SplashController>().configModel.customerVerification) {
            List<int> _encoded = utf8.encode(_password);
            String _data = base64Encode(_encoded);
            Get.toNamed(RouteHelper.getVerificationRoute(_numberWithCountryCode, status.message, RouteHelper.signUp, _data,_email));
          }else {
            Get.toNamed(RouteHelper.getAccessLocationRoute(RouteHelper.signUp));
          }
        }else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }

  Widget socialWidget(AuthController authController,TextEditingController controller ){
    return Row(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
GestureDetector(
    onTap:() async{
    if(authController.acceptTerms){
    
  
      if(controller.text.isEmpty || controller.text.length<5){
   
          showCustomSnackBar("enter_your_phone_number".tr);
        return;
      }
      if(controller.text.isNotEmpty){
       
       
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();



    if (googleSignInAccount != null) {
      
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
          
    
             SocialLogInBody socialLogInBody=SocialLogInBody(
          email:googleSignInAccount.email ,
          medium: "google" ,
          phone:_countryDialCode+controller.text,
          token: googleSignInAuthentication.accessToken,
          uniqueId: googleSignInAccount.id,

        );
    socialLogin(authController,socialLogInBody,false,true,false);
      
    }

      }

         /*GoogleSignInAccount _googleSignInAccount = await GoogleSignIn().signIn();
   GoogleSignInAuthentication googleSignInAuthentication =
   await _googleSignInAccount.authentication;
print("----${googleSignInAuthentication.accessToken}");*/

    }
  },
  child: Container(
    padding: EdgeInsets.all(10),
    child: Image.asset("assets/image/google.png",width: 30))),
SizedBox(width:50),
GestureDetector(
  onTap: () async {
 if(authController.acceptTerms ){
  if(GeneralPlatform.isIOS || GeneralPlatform.isMacOS){
      logInApple(authController);
  }else{
    showCustomSnackBar("this feature available for ios".tr);
    return;
  }
  if(kIsWeb){

  }else{

  }
    }  
    },
  child: Ink(
    padding: EdgeInsets.all(10),
    decoration:BoxDecoration(color:Colors.black,borderRadius:BorderRadius.circular(16)),
    child: Image.asset("assets/image/apple.png",width: 30,color:Colors.white)),
    ),
/*SizedBox(width:50),
GestureDetector(
  onTap: () async {
 if(authController.acceptTerms ){
    


  if(kIsWeb){

  }else{
   
    //connect using fb


var facebookLogin = FacebookLogin();
facebookLogin.isLoggedIn.then((value) => print("ww $value"));
    var facebookLoginResult = await facebookLogin.logIn(customPermissions:["email"]);
        print("$facebookLoginResult");
         print("Error ${facebookLoginResult}");
     switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error ${FacebookLoginStatus.error}");
        break;
      case FacebookLoginStatus.cancel:
        print("CancelledByUser");
    
        break;
      case FacebookLoginStatus.success:
       final FacebookAccessToken accessToken = facebookLoginResult.accessToken;

        var urldata = Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${accessToken.token}');

        final graphResponse = await Http.get(urldata);

        final profile = json.decode(graphResponse.body);
        var encoded = utf8.encode(profile["name"]);
        var decoded = utf8.decode(encoded);
        Map<String, dynamic> map = {
          "facebook": profile["email"],
          "full_name": decoded.toString()
        };
        SocialLogInBody socialLogInBody=SocialLogInBody(
          email:profile["email"] ,
        );
      socialLogin(authController,socialLogInBody,true,false,false);
        
        break;
    }
  }
    }  
    },
  child: Image.asset("assets/image/facebook.png",width: 30)),*/
],);
  }

  
socialLogin(AuthController authController,SocialLogInBody  data,bool fb,bool gm,bool apple){

    authController.registerWithSocialMedia(data,fb,gm,apple).then((status) async {
     
        if (status.isSuccess) {
          if (authController.isActiveRememberMe) {
           // authController.saveUserNumberAndPassword(_phone, _password, countryDialCode);
          } else {
            authController.clearUserNumberAndPassword();
          }
          String _token = status.message.substring(1, status.message.length);
          if(Get.find<SplashController>().configModel.customerVerification && int.parse(status.message[0]) == 0) {
            //List<int> _encoded = utf8.encode(_password);
           // String _data = base64Encode(_encoded);
         
            /*Get.toNamed(RouteHelper.getVerificationRoute(
              _numberWithCountryCode, 
              _token, 
              RouteHelper.signUp, 
              _data,
              status["email"]
            ));*/
          }else {
            Get.toNamed(RouteHelper.getAccessLocationRoute('sign-in'));
          }
        }else {
          showCustomSnackBar(status.message);
        }
      });
}

 void logInApple(AuthController authController) async {
    final AuthorizationResult result = await TheAppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    switch (result.status) {
      case AuthorizationStatus.authorized:    
   Map<String, dynamic> map = {
          "apple": result.credential.email,
          "full_name": result.credential.fullName.toString()
        };
        SocialLogInBody socialLogInBody=SocialLogInBody(
          email:result.credential.email ,
        );
      socialLogin(authController,socialLogInBody,false,false,true);
        // Navigate to secret page (shhh!)
        
        break;

      case AuthorizationStatus.error:
        setState(() {
          showCustomSnackBar("verify_information".tr);
        });
        break;

      case AuthorizationStatus.cancelled:
        break;
    }
  }
}
