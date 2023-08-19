import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Screens/home/widget/food_list.dart';
import '../../Screens/home/widget/food_list_view.dart';
import '../../Screens/home/widget/restaurant_info.dart';
import '../../constants/colors.dart';
import '../../models/restaurant.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  final Restaurant restaurant;

  const HomePage({Key key, this.restaurant}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selected = 0;
  final pageController = PageController();
  Restaurant get restaurant {
    return widget.restaurant;
  }
  @override
  Widget build(BuildContext context) {
    print("HOME PAGE widget.restaurant.id ${widget.restaurant.toJson()}");
    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar(
            leftIcon: Icons.arrow_back,
            // rightIcon: Icons.search,
            leftCallback: ()=> Get.back(),
          ),
          RestaurantInfo(restaurant: restaurant,),
          FoodList(
            selected: selected,
            restaurant: restaurant,
            callback: (int index) {
              setState(() {
                selected = index;
              });
              pageController.jumpToPage(index);
            },
          ),
          Expanded(
              child: FoodListView(
            selected: selected,
            callback: (int index) {
              setState(() {
                selected = index;
              });
            },
            pageController: pageController,
            restaurant: restaurant,
          )),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            height: 60,
            child: SmoothPageIndicator(
              controller: pageController,
              count: 0,
              effect: CustomizableEffect(
                dotDecoration: DotDecoration(
                  width: 8,
                  height: 8,
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                activeDotDecoration: DotDecoration(
                  width: 10,
                  height: 10,
                  color: kBackground,
                  borderRadius: BorderRadius.circular(10),
                  dotBorder: DotBorder(
                    color: kPrimaryColor,
                    padding: 2,
                    width: 2,
                  ),
                ),
              ),
              onDotClicked: (index) => pageController.jumpToPage(index),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        elevation: 2,
        backgroundColor: kPrimaryColor,
        child: Icon(
          Icons.shopping_bag_outlined,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}
