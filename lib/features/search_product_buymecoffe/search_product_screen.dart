// ignore_for_file: unnecessary_string_interpolations, prefer_const_constructors, avoid_print, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:priyanshuadvanceconceptofflutter/features/search_product_buymecoffe/product_res.dart';
import 'package:priyanshuadvanceconceptofflutter/features/search_product_buymecoffe/search_home_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'common_desing_appbar.dart';

class AllProductsScreen extends StatefulWidget {
  final String searchText;
  const AllProductsScreen({super.key, required this.searchText});

  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  TextEditingController searchController = TextEditingController();
  final HomeSearchController controller = Get.find<HomeSearchController>();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    callSearchQuery();
  }

  callSearchQuery() {
    searchController.text = widget.searchText;
    filterProducts(widget.searchText);
    print("---------search value is ${searchController.value.text}---------------");
    print("---------search value is ${widget.searchText}---------------");
    setState(() {});
  }


  void filterProducts(String query) {
    // Preprocess the query to remove special characters
    query = query.replaceAll(RegExp(r"[^\w\s]"), "");

    List<ProductResponse> tempList = [];
    if (query.isNotEmpty) {
      tempList = controller.productList.where((product) {
        // Check if the query matches with title, description, category, or price
        return product.title.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase()) ||
            product.price
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    } else {
      tempList = controller.productList;
    }
    setState(() {
      controller.filteredProductList = tempList;
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _searchText = val.recognizedWords;
            searchController.text = _searchText;
            filterProducts(_searchText);
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: CommonDesignAppBar(
        title: Text("All Products"),
        backgroundColor: Colors.orange,
        showLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed:() {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                height: 55,
                width: 360,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(Icons.search),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search In Products',
                              ),
                              onChanged: (value) {
                                filterProducts(value);                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _listen,
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: controller.filteredProductList.length,
                itemBuilder: (context, index) {
                  final product = controller.filteredProductList[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          print(product.title);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  product.image,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 16,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          '${product.rating.rate} (${product.rating.count})',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '${product.category}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      product.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

