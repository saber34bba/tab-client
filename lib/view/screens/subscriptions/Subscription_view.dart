import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/theme_controller.dart';
import 'package:efood_multivendor/data/api/api_client.dart';
import 'package:efood_multivendor/data/model/response/config_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/cart_widget.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_image.dart';
import 'package:efood_multivendor/view/base/veg_filter_widget.dart';
import 'package:efood_multivendor/view/screens/subscriptions/SubscriptionModel.dart';
import 'package:efood_multivendor/view/screens/subscriptions/SubscriptionModelView.dart';
import 'package:efood_multivendor/view/screens/subscriptions/subscriptionCart.dart';
import 'package:efood_multivendor/view/screens/subscriptions/subscriptionPresenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:efood_multivendor/view/base/custom_app_bar.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class Subscription_view extends StatefulWidget{
  final bool showAppbar;
  Subscription_view({@required this.showAppbar});

  @override
  State<StatefulWidget> createState() {
  return _Subscription_view();
  }

}

class _Subscription_view extends State<Subscription_view> with TickerProviderStateMixin{
    TabController _tabController;
    double width;
    @override 
    void initState() {
      
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(widget.showAppbar){
           Provider.of<SubscriptionsModelView>(context,listen: false).getSubscriptions();
      }else{
           Provider.of<SubscriptionsModelView>(context,listen: false).getMy_Subscriptions(false);
      }
    });
     _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    super.initState();
  }
SubscriptionPresenter subscriptionPresenter;
  SubscriptionsModelView subscriptionsModelView;
  @override
  Widget build(BuildContext context) {
    subscriptionPresenter=Provider.of<SubscriptionPresenter>(context);
    subscriptionsModelView=Provider.of<SubscriptionsModelView>(context);
    width=MediaQuery.of(context).size.width;
      return Scaffold(
    appBar: 
    
    widget.showAppbar? CustomAppBar(title: 'subscriptions'.tr):null,
 body: Padding(
            padding: EdgeInsets.only(
              left: Dimensions.PADDING_SIZE_SMALL,
              right: Dimensions.PADDING_SIZE_SMALL,
              top: ResponsiveHelper.isDesktop(context) ? Dimensions.PADDING_SIZE_SMALL : 0,
             
            ),
            child: Container(
              width: width,
              height: MediaQuery.of(context).size.height,
              child: RefreshIndicator(

                onRefresh:()async{
                    await Future.delayed(Duration(seconds: 2));
               return   refresh();
                },
                child: 
                
                
                widget.showAppbar? 
                subscriptionsModelView.loading  &&
                !subscriptionsModelView.subscriptionlist.isEmpty?
                  SingleChildScrollView(
                      child: Column(children: [
                        SizedBox(height:30),
                        for(int i=0;i<10;i++)
                         loadingWidget(),
                        
                      ]),
                    ):
                
                subscriptionsModelView.subscriptionlist.length>0? subscriptionsListView():
                
                  Container():
                  subscriptionsModelView.my_subscriptionlist.length>0? Container(
                    height:MediaQuery.of(context).size.height,
                    child: my_subscriptionsListView()):
                  SingleChildScrollView(
                    child: Column(children: [
                                  
                                   
                      subscriptionsModelView.loading?    SingleChildScrollView(
                        child: Column(children: [
                          SizedBox(height:30),
                          for(int i=0;i<10;i++)
                           loadingWidget(),
                          
                        ]),
                      ):Container(),
                  
                      Container(height: 100,),
                                  ]),
                  ),
              ),
            ),
          ),
        );
  
   }


Widget subscriptionsListView(){
  return   
  
  ResponsiveHelper.isDesktop(context)? desktiopSubscriotionlist():
  mobileSubscriptionList();
}

Widget mobileSubscriptionList(){
  return Container(
    height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: subscriptionsModelView.subscriptionlist.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context,int index){
                            SubscriptionModel subscriptionModel=subscriptionsModelView.subscriptionlist[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.transparent,
                              onTap: (){
 Provider.of<SubscriptionsModelView>(context, listen: false).clearData();     
 Provider.of<SubscriptionsModelView>(context,listen: false)
 .selectSubscription(index);
 Navigator.of(context).push(
  PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 0),
    reverseTransitionDuration: Duration(milliseconds: 0), 
    pageBuilder: (BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return SubscriptionCart(
                                showSecondPage: false,
                              );
    },
    transitionsBuilder: (BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ),
);},
                              child: Ink(                 
                              width:width ,
                              padding: EdgeInsets.all(10),
                              child:Column(children: [
                              Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                   ClipRRect(
                                        borderRadius: BorderRadius.
                                        all( Radius.circular(Dimensions.RADIUS_SMALL)),
                                        child: CustomImage(
                                          image: subscriptionModel.image,
                                          height: context.width * 0.2, 
                                          width:context.width * 0.2, fit: BoxFit.cover,
                                        )
                                      ),
                                      SizedBox(width: 15,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                        Text(
                                          Get.find<ApiClient>().getHeader()["X-localization"]=="ar"?
                                          subscriptionModel.name_ar: 
                                           Get.find<ApiClient>().getHeader()["X-localization"]=="en"?
                                          subscriptionModel.name_en:
                                         subscriptionModel.name_fr  , style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall),), 
                                        SizedBox(height: 5,),
                                        subscriptionModel.sizeList.isNotEmpty?
                                        Text(subscriptionModel.sizeList.first.price.toString()+" Dh ",
                                        style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall),):Container(),
                                       
                        Container(
                      width: width*0.5,
                      child: Row(children: [
                        Text(
                      "prix".tr,
                      overflow: TextOverflow.clip,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                        SizedBox(width: 5,),
                        Text(
                      subscriptionModel.prix,
                      overflow: TextOverflow.clip,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                      SizedBox(width: 2,),
                         Text(
                       Get.find<SplashController>().configModel.currencySymbol,
                      overflow: TextOverflow.clip,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                      ],)
                      ),                  
                       SizedBox(height: 5),
                       Container(
                      width: width*0.5,
                      child: Row(children: [
                        Text(
                      "quantity".tr,
                      overflow: TextOverflow.clip,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                        SizedBox(width: 5,),
                        Text(
                      subscriptionModel.total_quantity.toString(),
                      overflow: TextOverflow.clip,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                      SizedBox(width: 2,),
                         Text(
                       "dishes".tr,
                      overflow: TextOverflow.clip,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                      ],)
                      ),
                                        SizedBox(height: 5),
                                        Container(
                                        width: width*0.5,
                                        child: Text(
                                          
                                            Get.find<ApiClient>().getHeader()["X-localization"]=="ar"?
                                         subscriptionModel.des_ar.length>100?
                                        subscriptionModel.des_ar.substring(0,100)+"...":
                                        subscriptionModel.des_ar: 
                                           Get.find<ApiClient>().getHeader()["X-localization"]=="en"?
                                         subscriptionModel.des_en.length>100?
                                        subscriptionModel.des_en.substring(0,100)+"...":
                                        subscriptionModel.des_en:
                                          subscriptionModel.des_fr.length>100?
                                        subscriptionModel.des_fr.substring(0,100)+"...":
                                        subscriptionModel.des_fr,
                                        overflow: TextOverflow.clip,
                                       
                                        style: robotoMedium.copyWith(
                                        color: Colors.grey,
                                        fontSize: Dimensions.fontSizeSmall),
                                        ),
                                        ),
                                      ],)
                              ]),
                              SizedBox(height: 10,),
                                                     Row(children: [
                                 Container(
                                  width:context.width * 0.2,
                                ),
                                Expanded(child: Container(height: 1,color:Colors.grey[200]))
                                                     ],)
                              ],)
                              ),
                            ),
                          );
                        }),
                      );
}

Widget desktiopSubscriotionlist(){
  return Container(
    height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: subscriptionsModelView.subscriptionlist.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context,int index){
                            SubscriptionModel subscriptionModel=subscriptionsModelView.subscriptionlist[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.transparent,
                              onTap: (){
 Provider.of<SubscriptionsModelView>(context, listen: false).clearData();     
 Provider.of<SubscriptionsModelView>(context,listen: false)
 .selectSubscription(index);
 Navigator.of(context).push(
  PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 0),
    reverseTransitionDuration: Duration(milliseconds: 0), 
    pageBuilder: (BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return SubscriptionCart(
                                showSecondPage: false,
                              );
    },
    transitionsBuilder: (BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ),
);},
                              child: Ink(                 
                              width:width ,
                              padding: EdgeInsets.all(10),
                              child:Column(children: [
                              Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                   ClipRRect(
                                        borderRadius: BorderRadius.
                                        all( Radius.circular(Dimensions.RADIUS_SMALL)),
                                        child: CustomImage(
                                          image: subscriptionModel.image,
                                          height: context.width * 0.1, 
                                          width:context.width * 0.1, fit: BoxFit.cover,
                                        )
                                      ),
                                      SizedBox(width: 15,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                        Text(
                                          
                                      Get.find<ApiClient>().getHeader()["X-localization"]=="ar"?
                                          subscriptionModel.name_ar: 
                                           Get.find<ApiClient>().getHeader()["X-localization"]=="en"?
                                          subscriptionModel.name_en:
                                         subscriptionModel.name_fr     , style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall),), 
                                        SizedBox(height: 5,),
                                        subscriptionModel.sizeList.isNotEmpty?
                                        Text(subscriptionModel.sizeList.first.price.toString()+" Dh ",
                                        style: robotoMedium.copyWith(
                                        fontSize: Dimensions.fontSizeSmall),):Container(),
                                       
                        Container(
                      width: width*0.5,
                      child: Row(children: [
                        Text(
                      "prix".tr,
                      overflow: TextOverflow.clip,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                        SizedBox(width: 5,),
                        Text(
                      subscriptionModel.prix,
                      overflow: TextOverflow.clip,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                      SizedBox(width: 2,),
                         Text(
                       Get.find<SplashController>().configModel.currencySymbol,
                      overflow: TextOverflow.clip,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                      ],)
                      ),                  
                       SizedBox(height: 5),
                       Container(
                      width: width*0.5,
                      child: Row(children: [
                        Text(
                      "quantity".tr,
                      overflow: TextOverflow.clip,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                        SizedBox(width: 5,),
                        Text(
                      subscriptionModel.total_quantity.toString(),
                      overflow: TextOverflow.clip,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                      SizedBox(width: 2,),
                         Text(
                       "dishes".tr,
                      overflow: TextOverflow.clip,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                      ],)
                      ),
                                        SizedBox(height: 5),
                                        Container(
                                        width: width*0.5,
                                        child: Text(
                                          Get.find<ApiClient>().getHeader()["X-localization"]=="ar"?
                                         subscriptionModel.des_ar.length>100?
                                        subscriptionModel.des_ar.substring(0,100)+"...":
                                        subscriptionModel.des_ar: 
                                           Get.find<ApiClient>().getHeader()["X-localization"]=="en"?
                                         subscriptionModel.des_en.length>100?
                                        subscriptionModel.des_en.substring(0,100)+"...":
                                        subscriptionModel.des_en:
                                          subscriptionModel.des_fr.length>100?
                                        subscriptionModel.des_fr.substring(0,100)+"...":
                                        subscriptionModel.des_fr
                                        ,
                                        overflow: TextOverflow.clip,
                                       
                                        style: robotoMedium.copyWith(
                                        color: Colors.grey,
                                        fontSize: Dimensions.fontSizeSmall),
                                        ),
                                        ),
                                      ],)
                              ]),
                              SizedBox(height: 10,),
                                                     Row(children: [
                                 Container(
                                  width:context.width * 0.2,
                                ),
                                Expanded(child: Container(height: 1,color:Colors.grey[200]))
                                                     ],)
                              ],)
                              ),
                            ),
                          );
                        }),
  );
}
Widget my_subscriptionsListView(){
  return
    ListView.builder(
    itemCount: subscriptionsModelView.my_subscriptionlist.length,
    shrinkWrap: true,
    itemBuilder: (BuildContext context,int index){
    
    SubscriptionModel subscriptionModel=subscriptionsModelView.my_subscriptionlist[index];
  return Material(
  color: Colors.transparent,
  child: InkWell(
    highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
  onTap: (){
  Provider.of<SubscriptionsModelView>(context,listen: false).clearData();      
  if(subscriptionModel.status==1){
  Provider.of<SubscriptionsModelView>(context,listen: false)
  .selectFromMySubscription(index);
      Navigator.push(
      context,
      MaterialPageRoute(
      builder: (context) => SubscriptionCart(showSecondPage:true)));
  }    
  },
        child: Container(
          margin: EdgeInsets.only(top: 10,right: 20,left:20),
          padding: EdgeInsets.only(bottom:subscriptionsModelView.my_subscriptionlist.length-1
          ==index?20:0,
          top: index==0?30:0
          ),
          child: Ink(   
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color:Colors.white),              
          width:width ,
          padding: EdgeInsets.all(10),
          child:Column(children: [
          Container(
            width: width,
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                 ClipRRect(
                      borderRadius: BorderRadius.
                      all( Radius.circular(Dimensions.RADIUS_SMALL)),
                      child: CustomImage(
                        image: subscriptionModel.image,
                        height: 
                        ResponsiveHelper.isDesktop(context)?
                        context.width * 0.08:
                        context.width * 0.15, 
                        width:   ResponsiveHelper.isDesktop(context)?
                        context.width * 0.08:
                        context.width * 0.15, fit: BoxFit.cover,
                      )
                    ),
                    SizedBox(width: 15,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                        Get.find<ApiClient>().getHeader()["X-localization"]=="ar"?
                                          subscriptionModel.name_ar: 
                                           Get.find<ApiClient>().getHeader()["X-localization"]=="en"?
                                          subscriptionModel.name_en:
                                         subscriptionModel.name_fr , style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall),), 
                      SizedBox(height: 5,),
                      subscriptionModel.sizeList.isNotEmpty?
                      Text(subscriptionModel.sizeList.first.price.toString()+" Dh ",
                      style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall),):Container(),
                   
                              SizedBox(height: 2),
                      Container(
                      width: width*0.4,
                      child: Text(
                          Get.find<ApiClient>().getHeader()["X-localization"]=="ar"?
                                         subscriptionModel.des_ar.length>100?
                                        subscriptionModel.des_ar.substring(0,100)+"...":
                                        subscriptionModel.des_ar: 
                                           Get.find<ApiClient>().getHeader()["X-localization"]=="en"?
                                         subscriptionModel.des_en.length>100?
                                        subscriptionModel.des_en.substring(0,100)+"...":
                                        subscriptionModel.des_en:
                                          subscriptionModel.des_fr.length>100?
                                        subscriptionModel.des_fr.substring(0,100)+"...":
                                        subscriptionModel.des_fr,
                      overflow: TextOverflow.clip,
                       textAlign: TextAlign.justify,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                      ), SizedBox(height: 5),

                      Container(
                      width: width*0.5,
                      child: Row(children: [
                        Text(
                      "ordered_at".tr,
                      overflow: TextOverflow.clip,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                      SizedBox(width: 5,),
                      Text(
                      subscriptionModel.created_at,
                      overflow: TextOverflow.clip,
                      style: robotoMedium.copyWith(
                      color: Colors.grey,
                      fontSize: Dimensions.fontSizeSmall),
                      ),
                      ],)
                      ),
                    ],),
                    SizedBox(width: 10,),
ResponsiveHelper.isDesktop(context)?
Expanded(child: Container()):Container(),
                    ResponsiveHelper.isDesktop(context)?
                       
             Expanded(
               child: Container(
                  width: width*0.1,            
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: subscriptionModel.status==1
                ?
                Colors.green.withOpacity(1):
                subscriptionModel.isordered?
                Theme.of(context).primaryColor:
                Colors.red
                                   ),
                         child: Text(subscriptionModel.status==1?"_paid".tr:
                         subscriptionModel.status==2?"declined".tr:
                         subscriptionModel.isordered?"ordered":
                         "unpaid".tr,style: robotoRegular.copyWith(
                          color: Colors.white
                         ),textAlign: TextAlign.center,),
                                           ),
             )
          :                   
          Expanded(
            child: Container(
                                     
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: subscriptionModel.status==1
              ?
              Colors.green.withOpacity(1):
              subscriptionModel.isordered?
              Theme.of(context).primaryColor:
              Colors.red
                                 ),
                       child: Text(subscriptionModel.status==1?"_paid".tr:
                       subscriptionModel.status==2?"declined".tr:
                       subscriptionModel.isordered?"ordered":
                       "unpaid".tr,style: robotoRegular.copyWith(
                        color: Colors.white
                       ),textAlign: TextAlign.center,),
                                         ),
          )
            ]),
          ),
          SizedBox(height: 10,),
                                 Row(children: [
             Container(
              width:context.width * 0.2,
            ),
            Expanded(child: Container(height: 1,color:Colors.grey[200]))
                                 ],)
          ],)
          ),
        ),
      ),
    );
  });
}
Widget loadingWidget (){
  return Shimmer(
              duration: Duration(seconds: 2),
              child: Column(children: [
                Row(children: [
                  Container(
                    height: 60, width: 60,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
                  ),
                  SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 15, width: 100, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                    Container(height: 15, width: 150, color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
                  ])),
                  Column(children: [
                    Container(
                      height: 20, width: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                      ),
                    ),
                    SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                    Container(
                      height: 20, width: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
                      ),
                    )
                  ]),
                ]),

                Divider(
                  color: Theme.of(context).disabledColor, height: Dimensions.PADDING_SIZE_LARGE,
                ),

              ]),
            );
}

Future <void> refresh()async {
      if(widget.showAppbar){

           Provider.of<SubscriptionsModelView>(context,listen: false).getSubscriptions();

      }else{
           
           Provider.of<SubscriptionsModelView>(context,listen: false).getMy_Subscriptions(true);

      }
      
}
}