// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:lottie/lottie.dart';
import 'package:priyanshuadvanceconceptofflutter/features/search_product_buymecoffe/product_res.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

import 'home_curve_design.dart';
import 'search_product_screen.dart';

class HomeSearchController extends GetxController {
  RxBool isActive = false.obs;
  Rx<TextEditingController> searchController = TextEditingController().obs;

  RxBool showRetryOption = false.obs; // Added observable for retry option

  RxString wordsSpoken = "".obs;

  void startListening(void Function() stopListeningCallback) {
    isActive.value = true;
    showRetryOption.value = false;

    Timer(Duration(seconds: 10), () {
      isActive.value = false;
      showRetryOption.value = true;
      stopListeningCallback(); // Stop listening after 10 seconds
      print("spoken word is ------- ${wordsSpoken.value}");
      if (showRetryOption.value = true && wordsSpoken.value.isNotEmpty) {
        Get.back();
        Get.to(
          AllProductsScreen(
            searchText: wordsSpoken.value,
          ),
        );
      }
    });
  }

  List<ProductResponse> productList = List.empty(growable: true);
  List<ProductResponse> filteredProductList = List.empty(growable: true);
}

class SearchProductView extends StatefulWidget {
  const SearchProductView({Key? key}) : super(key: key);

  @override
  State<SearchProductView> createState() => _SearchProductViewState();
}

class _SearchProductViewState extends State<SearchProductView> {
  final HomeSearchController controller = Get.put(HomeSearchController());

  void _showBottomDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Colors.black
                      .withOpacity(0), // Fully transparent background
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 270,
                color: Colors.transparent,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 50,
                        width: 100,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white30,
                        ),
                        child: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Material(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            color: Colors.white,
                          ),
                          child: Obx(() {
                            if (controller.isActive.value) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    controller.wordsSpoken.value.isEmpty
                                        ? "Listening...."
                                        : "${controller.wordsSpoken.value}",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 20),
                                  Lottie.asset(
                                    "assets/lottie/listening.json",
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ],
                              );
                            } else if (controller.wordsSpoken.value.isEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Sorry! Didn't hear that",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black),
                                  ),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () {
                                      controller.wordsSpoken.value = "";
                                      _startListening();
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green,
                                      ),
                                      child: const Icon(
                                        Icons.mic,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  const Text(
                                    "Tap the microphone to try again",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Container(); // Empty container if no state is active
                            }
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(animation1),
          child: child,
        );
      },
    );
  }

  final SpeechToText _speechToText = SpeechToText();

  bool speechEnabled = false;

  @override
  void initState() {
    super.initState();
    initSpeech();
    fetchProducts();
  }

  fetchProducts() async {
    final response =
    await http.get(Uri.parse('https://fakestoreapi.com/products/'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        controller.productList = jsonData
            .map((product) => ProductResponse.fromJson(product))
            .toList();
        controller.filteredProductList = controller.productList;
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  void initSpeech() async {
    speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
    controller.startListening(_stopListening); // Pass stopListening as callback
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      controller.wordsSpoken.value = "${result.recognizedWords}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          homeHeaderWidget(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10).copyWith(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Happy Shopping",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontFamily: 'fonts',
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Priyanshu",
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontFamily: 'fonts',
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {

                        },
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.card_travel_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 55,
                    width: 360,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => AllProductsScreen(searchText: '',),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.search,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text("Search In Products"),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            controller.wordsSpoken.value = "";
                            _startListening();
                            _showBottomDialog(context);
                          },
                          icon: Icon(
                            Icons.mic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 1,
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Popular Categories",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontFamily: 'fonts',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                          },
                          child: Text(
                            "View All",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              fontFamily: 'fonts',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CategoriesSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class homeHeaderWidget extends StatelessWidget {
  const homeHeaderWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return custom_home_curve_design(
      child: Container(
        color: Colors.orange,
        padding: EdgeInsets.all(0),
        child: SizedBox(
          height: 400,
          child: Stack(
            children: [
              Positioned(
                top: -150,
                right: -250,
                child: Container(
                  height: 400,
                  width: 400,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 100,
                right: -300,
                child: Container(
                  height: 400,
                  width: 400,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              child
            ],
          ),
        ),
      ),
    );
  }
}

class custom_home_curve_design extends StatelessWidget {
  const custom_home_curve_design({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: customCurveEdge(),
      child: child,
    );
  }
}

class CategoriesSection extends StatelessWidget {
  final List<String> categories = [
    'T-shirt',
    'Jeans',
    'Hoodie',
    'Jacket',
    'Shoes',
    'Skirt',
  ];


  final List<String> categoryImages = [
    'https://nobero.com/cdn/shop/files/Untitleddesign_27.png?v=1711978684',
    'https://nobero.com/cdn/shop/files/JoggersWebImages-0013.webp?v=1717764234',
    'https://cdn.shopify.com/s/files/1/0337/9413/0052/files/coordinates_large.jpg?v=1725282119',
    'https://cdn.shopify.com/s/files/1/0337/9413/0052/files/VERDIGRIS-BLUE_531e9125-1574-4f9b-bbfc-810752cc7cfb_large.jpg?v=1725626164',
    'https://static.nike.com/a/images/t_PDP_864_v1/f_auto,b_rgb:f5f5f5/99486859-0ff3-46b4-949b-2d16af2ad421/custom-nike-dunk-high-by-you-shoes.png',
    'https://cdn.shopify.com/s/files/1/0337/9413/0052/files/trials-explorer2_large.jpg?v=1719046917',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      // color: Colors.black,
      child: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(
                left: 5,
                right: 5,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        categoryImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 5), // Space between the image and the text
                  Text(
                    categories[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
