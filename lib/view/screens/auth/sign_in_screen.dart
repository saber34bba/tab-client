import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:efood_multivendor/data/model/body/social_log_in_body.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get_utils/src/platform/platform_io.dart';
import 'package:http/http.dart' as Http;

//import 'package:country_code_picker/country_code.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/localization_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final bool selectCountry;
  SignInScreen({@required this.exitFromApp, this.selectCountry = true});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _countryDialCode;
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();
WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     
});
    _countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty ? Get.find<AuthController>().getUserCountryCode()
        : CountryCode.fromCountryCode(Get.find<SplashController>().configModel.country).dialCode;
    _phoneController.text =  Get.find<AuthController>().getUserNumber() ?? '';
    _passwordController.text = Get.find<AuthController>().getUserPassword() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            } else {
              Navigator.pushNamed(context, RouteHelper.getInitialRoute());
            }
            return Future.value(false);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr, style: TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            ));
            _canExit = true;
            Timer(Duration(seconds: 2), () {
              _canExit = false;
            });
            return Future.value(false);
          }
        }else {
          return true;
        }
      },
      child: Scaffold(
        appBar: !Get.find<AuthController>().isLoggedIn() ? (ResponsiveHelper.isDesktop(context) ? WebMenuBar() : !widget.exitFromApp ? AppBar(leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).textTheme.bodyText1.color),
        ), elevation: 0, backgroundColor: Colors.transparent) : null) : null,
        body: SafeArea(child: Center(
          child: Scrollbar(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
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

                      Text('sign_in'.tr.toUpperCase(), style: robotoBlack.copyWith(fontSize: 30)),
                      SizedBox(height: 50),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          color: Theme.of(context).cardColor,
                          boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 1, blurRadius: 5)],
                        ),
                        child: Column(children: [

                          Row(children: [
                            CodePickerWidget(
                              onChanged: (CountryCode countryCode) {
                                _countryDialCode = countryCode.dialCode;
                              },
                              initialSelection: _countryDialCode != null ? Get.find<AuthController>().getUserCountryCode().isNotEmpty ? Get.find<AuthController>().getUserCountryCode()
                                  : CountryCode.fromCountryCode(Get.find<SplashController>().configModel.country).code : Get.find<LocalizationController>().locale.countryCode,
                              favorite: [Get.find<AuthController>().getUserCountryCode().isNotEmpty ? Get.find<AuthController>().getUserCountryCode()
                                  : CountryCode.fromCountryCode(Get.find<SplashController>().configModel.country).code],
                              showDropDownButton: widget.selectCountry,
                              padding: EdgeInsets.zero,
                              showFlagMain: true,
                              flagWidth: 30,
                              // countryFilter: [_countryDialCode],
                              dialogBackgroundColor: Theme.of(context).cardColor,
                              textStyle: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyText1.color,
                              ),
                            ),
                            Expanded(flex: 1, child: CustomTextField(
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
                            inputAction: TextInputAction.done,
                            inputType: TextInputType.visiblePassword,
                            prefixIcon: Images.lock,
                            isPassword: true,
                            onSubmit: (text) => (GetPlatform.isWeb && authController.acceptTerms)
                                ? _login(authController, _countryDialCode) : null,
                          ),

                        ]),
                      ),
                      SizedBox(height: 10),

                      Row(children: [
                        Expanded(
                          child: ListTile(
                            onTap: () => authController.toggleRememberMe(),
                            leading: Checkbox(
                              activeColor: Theme.of(context).primaryColor,
                              value: authController.isActiveRememberMe,
                              onChanged: (bool isChecked) => authController.toggleRememberMe(),
                            ),
                            title: Text('remember_me'.tr),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            horizontalTitleGap: 0,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed(RouteHelper.getForgotPassRoute(false, null)),
                          child: Text('${'forgot_password'.tr}?'),
                        ),
                      ]),
                      SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                      ConditionCheckBox(authController: authController),
                      SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
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
            Text('or_connect_with'.tr, style: robotoRegular),
             SizedBox(width: 10,),
              Expanded(
              child: Container(
                height: 1,
                color: Colors.grey,
              ),
            ),
          ]),
        ),
              Padding(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL)),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
GestureDetector(
    onTap:() async{
    if(authController.acceptTerms){
   
      GoogleSignIn().isSignedIn().then((value) {
        if(value){
    
        }
      });
         /*GoogleSignInAccount _googleSignInAccount = await GoogleSignIn().signIn();
   GoogleSignInAuthentication googleSignInAuthentication =
   await _googleSignInAccount.authentication;
print("----${googleSignInAuthentication.accessToken}");*/

    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
 
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
     
     
       SocialLogInBody socialLogInBody=SocialLogInBody(
          email:googleSignInAccount.email ,
          medium: "google" ,
          phone:_countryDialCode+_phoneController.text,
          token: googleSignInAuthentication.accessToken,
          uniqueId: googleSignInAccount.id
        );
       
      socialLogin(authController,socialLogInBody,false,true,false);
      
    }
    }
  },

  child: Container(
    padding: EdgeInsets.all(10),
    child: Image.asset("assets/image/google.png",width: 30))),
SizedBox(width:50),
GestureDetector(
  onTap: () async {
 if(authController.acceptTerms ){
   if(GeneralPlatform.isIOS || GeneralPlatform.isMacOS)
  logInApple(authController);else{
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
    child: Image.asset("assets/image/apple.png",width: 30,color:Colors.white))),
//SizedBox(width:50),
/*GestureDetector(
  onTap: () async {
 if(authController.acceptTerms ){
  if(kIsWeb){
var facebookLogin = FacebookLogin();
facebookLogin.isLoggedIn.then((value) => print("ww $value"));
    var facebookLoginResult = await facebookLogin.logIn(customPermissions:["email"]);
    
         
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
  }else{
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
  child: Image.asset("assets/image/facebook.png",width: 30)),

  */
],),

 SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
 SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                      !authController.isLoading ? Row(children: [
                        Expanded(child: CustomButton(
                          buttonText: 'sign_up'.tr,
                          transparent: true,
                          onPressed: () => Get.toNamed(RouteHelper.getSignUpRoute()),
                        )),
                        Expanded(child: CustomButton(
                          buttonText: 'sign_in'.tr,
                          onPressed: authController.acceptTerms ? () => _login(authController, _countryDialCode) : null,
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
          ),
        )),
      ),
    );
  }

  void _login(AuthController authController, String countryDialCode) async {
    String _phone = _phoneController.text.trim();
    String _password = _passwordController.text.trim();
    String _numberWithCountryCode = countryDialCode+_phone;
    bool _isValid = false;
    _numberWithCountryCode = await getInternationalPhoneNumber(_countryDialCode,_phone);
    if(_numberWithCountryCode.isNotEmpty) {
        _isValid = true;
    }
    if(!_isValid || _phone.isEmpty){
      _isValid = false;
    }
    if (!_isValid) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (!_isValid) {
      showCustomSnackBar('invalid_phone_number'.tr);
    }else if (_password.isEmpty) {
      showCustomSnackBar('enter_password'.tr);
    }else if (_password.length < 6) {
      showCustomSnackBar('password_should_be'.tr);
    }else {

      authController.login(_numberWithCountryCode, _password).then((status) async {
        if (status.isSuccess) {
          if (authController.isActiveRememberMe) {
            authController.saveUserNumberAndPassword(_phone, _password, countryDialCode);
          } else {
            authController.clearUserNumberAndPassword();
          }
          String _token = status.message.substring(1, status.message.length);
          if(Get.find<SplashController>().configModel.customerVerification && int.parse(status.message[0]) == 0) {
            List<int> _encoded = utf8.encode(_password);
            String _data = base64Encode(_encoded);
        
            Get.toNamed(RouteHelper.getVerificationRoute(
              _numberWithCountryCode, 
              _token, 
              RouteHelper.signUp, 
              _data,
              status["email"]
            ));
          }else {
            Get.toNamed(RouteHelper.getAccessLocationRoute('sign-in'));
          }
        }else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }



socialLogin(AuthController authController,SocialLogInBody  data,bool fb,bool gm,bool apple){
    authController.loginWithSocialMedia(data,fb,gm,apple).then((status) async {
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


    void fbLogin() async {
   try{
  
  var facebookLogin = FacebookLogin();

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
      
        
        break;
    }
   }catch(e){
      print(e);
    }
  
  }


  Future facebookLogin() async {
  final result =
      await FacebookAuth.i.login(permissions: ['public_profile', 'email']);
  if (result.status == LoginStatus.success) {
    final userData = await FacebookAuth.i.getUserData();
    return userData;
  }
  return null;
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
