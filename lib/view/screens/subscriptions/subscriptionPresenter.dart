import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/screens/subscriptions/SubscriptionModel.dart';
import 'package:efood_multivendor/view/screens/subscriptions/SubscriptionModelView.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class SubscriptionPresenter extends ChangeNotifier{
  String url="";
  PageController pageController=PageController(initialPage: 0);
  int size_index=0;
  List<int> productList=[];

  
addProduct(int _product_id){
  if(productList.length>0){

 if(productList.contains(_product_id)){
  productList.remove(_product_id);

  }else
    productList.add(_product_id);
  }else{
  productList.add(_product_id);
  }
  notifyListeners();
}


  changeSize(int index){
size_index=index;
notifyListeners();
  }

  clearSizeIndex(){
    size_index=0;
    notifyListeners();
  }

  clearData(BuildContext context){
    productList=[];
      clearSizeIndex();
      subscriptionSchedule=[];
       orderTime=(TimeOfDay.now().hour.toString()+":"+TimeOfDay.now().minute.toString()).toString();
     addSchedule(context);
      notifyListeners();

  }




 TextEditingController streetNumberController = TextEditingController();
   TextEditingController houseController = TextEditingController();
  TextEditingController floorController = TextEditingController();
    final FocusNode streetNode = FocusNode();
  final FocusNode houseNode = FocusNode();
  final FocusNode floorNode = FocusNode();



 // DateTime selectedDate = DateTime.now();

  Future<void> selectDate(int j,BuildContext context) async {
    DateTime now = new DateTime.now();
   DateTime last;
    if(now.day>=15){
   last=   DateTime(now.year,now.month+1,DateTime(now.year, now.month + 1, 0).day);
    }else{
last=DateTime(now.year,now.month,DateTime(now.year, now.month + 1, 0).day);
    }
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate:    subscriptionSchedule[j].selectedDate,
        firstDate: DateTime(now.year, now.month,now.day),
        lastDate: last
        );
    if (picked != null && picked !=    subscriptionSchedule[j].selectedDate) {
           subscriptionSchedule[j].selectedDate = picked;
       
        formatDate( subscriptionSchedule[j].selectedDate);
        notifyListeners();
    }
  }
   TimeOfDay _timeOfDay = TimeOfDay.now();
   String orderTime=(TimeOfDay.now().hour.toString()+":"+TimeOfDay.now().minute.toString()).toString();

  void updateTimeSlot(int i,int index, {bool notify = true}) {
    if(subscriptionSchedule[i].timeList.isNotEmpty){
      subscriptionSchedule[i].timeList.clear();
    }
    subscriptionSchedule[i].timeList.add(index);
   
    notifyListeners();
  }

Future selectTime(BuildContext context) async {
  var time = await showTimePicker(
     
      context: context,
      initialTime: _timeOfDay);

  if (time != null) {
   
      orderTime = "${time.hour}:${time.minute}".toString();
 notifyListeners();
  }
}
  formatDate(DateTime _date){
     var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(_date);
    return formattedDate;
  }

  formeTime(TimeOfDay _twime){
    
  return   (_twime.hour.toString()+":"+_twime.minute.toString()).toString();

  } 
  List<SubscriptionSchedule> subscriptionSchedule=[];

  int total=0;
  int totalQuantity(){
    //verify la quentite doit etre egale size qte
    total=0;
      for(int i=0;i<subscriptionSchedule.length;i++){
        /*if(!subscriptionSchedule[i].quantityController.text.isEmpty){
           total=total+int.parse(subscriptionSchedule[i].quantityController.text);  
        }*/
        
     }
     notifyListeners();
     return total;
  }
  
  addSchedule(BuildContext context){
    bool _add=true;
    bool _time=true;
    int total=0;
   for(int i=0;i<subscriptionSchedule.length;i++){
    if(subscriptionSchedule[i].timeList.isEmpty){
      _time=false;
      showCustomSnackBar("add_delivery_time".tr);
    }
    total=0;
    for(int j=0;j<Provider.of<SubscriptionsModelView>(context,listen:false).my_subscriptionlist[Provider.of<SubscriptionsModelView>(context,listen:false).index]
    .productListModel.length;j++){
if(subscriptionSchedule[i].quantityController[j].text.isEmpty){
  total=total+1;
      }
      if(total==Provider.of<SubscriptionsModelView>(context,listen:false).my_subscriptionlist[Provider.of<SubscriptionsModelView>(context,listen:false).index]
    .productListModel.length){
        _add=false;
      }
    }
      
    }

    if(!_add){
      showCustomSnackBar("add_product_qte".tr);
       return;
    }
   if(!_time){
    return;
   }

    DateTime now = new DateTime.now();
    subscriptionSchedule.add(new SubscriptionSchedule(
          date:  formatDate( DateTime.now()),
          selectedDate: DateTime(now.year, now.month,now.day+1), 
          time: formeTime(TimeOfDay.now()),
    ));


    for(var e in 
    Provider.of<SubscriptionsModelView>(context,listen:false)
                  .my_subscriptionlist[Provider.of<SubscriptionsModelView>(context,listen:false).index]
                  .productListModel)
                  {
                 
                    subscriptionSchedule.last.quantityController.add(new TextEditingController());

                  }
    notifyListeners();
  }

  removeSchedule(int index){
    if(subscriptionSchedule.length==1){
      return;
    }

  /*/  if(subscriptionSchedule[index].quantityController.text.isNotEmpty)
total=total-int.parse(subscriptionSchedule[index].quantityController.text);
*/
subscriptionSchedule.removeAt(index);

notifyListeners();
  }

  String getQuantity(BuildContext context,int _index, int schedule_index) {
    int total_qte=0;
    for(int i=0;i<subscriptionSchedule.length;i++){
      if(subscriptionSchedule[i].quantityController[_index].text.isEmpty){

      }else
       total_qte=total_qte+ int.parse(subscriptionSchedule[i].quantityController[_index].text);
    }
int max=Provider.of<SubscriptionsModelView>(context,listen:false).my_subscriptionlist[Provider.of<SubscriptionsModelView>(context,listen:false).index].
productListModel[_index].quantity;
   max=max-total_qte;

 return max.toString();
  }

}