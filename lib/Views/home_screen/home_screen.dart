// ignore_for_file: unnecessary_import, library_private_types_in_public_api

import 'package:flutter_finalproject/consts/consts.dart';
import 'package:flutter_finalproject/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_finalproject/Views/collection_screen/item_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  static Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection(productsCollection).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching featured products: $e");
      return [];
    }
  }
}

class HomeScreen extends StatefulWidget {
  final dynamic data;
  const HomeScreen({super.key, this.data});

  @override
  _HomeScreenState createState() => _HomeScreenState(data);
}

class _HomeScreenState extends State<HomeScreen> {
  final CardSwiperController controllercard = CardSwiperController();
  var controller = Get.put(HomeController());
  final dynamic data;
  var isFav = false.obs;
  Map<String, dynamic>? selectedProduct;
  Map<String, dynamic>? previousSwipedProduct;

  _HomeScreenState(this.data);

  // void RemoveWishlist(Map<String, dynamic> product) {
  //   FirebaseFirestore.instance
  //       .collection(productsCollection)
  //       .where('p_name', isEqualTo: product['p_name'])
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //     if (querySnapshot.docs.isNotEmpty) {
  //       DocumentSnapshot doc = querySnapshot.docs.first;
  //       List<dynamic> wishlist = doc['p_wishlist'];
  //       if (!wishlist.contains(currentUser!.uid)) {
  //         doc.reference.update({
  //           'p_wishlist': FieldValue.arrayRemove([currentUser!.uid])
  //         }).then((value) {
  //           VxToast.show(context, msg: "Removed from Favorite");
  //         }).catchError((error) {
  //           print('Error adding ${product['p_name']} to Favorite: $error');
  //         });
  //       }
  //     }
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // Initialize controllercard here
  }

  @override
  void dispose() {
    controllercard.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.error != null) {
              return Center(
                  child: Text('An error occurred: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No data available'));
            }

            List<Map<String, dynamic>> products = snapshot.data!;
            return CardSwiper(
              scale: 0.5,
              isLoop: false,
              controller: controllercard,
              cardsCount: products.length,
              cardBuilder: (BuildContext context, int index,
                  int percentThresholdX, int percentThresholdY) {
                previousSwipedProduct = selectedProduct;
                selectedProduct = products[index];
                Map<String, dynamic> product = products[index];
                return Column(
                  children: [
                    Container(
                      width: 450,
                      height: 505,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 15,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Image.network(
                            product['p_imgs'][0],
                            height: 400,
                            width: 360,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: whiteColor,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['p_name'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontFamily: bold,
                                    ),
                                  ),
                                  const SizedBox( height: 2),
                                  Text(
                                    product['p_aboutProduct'],
                                    style: const TextStyle(
                                      color: fontGrey,
                                      fontSize: 14,
                                      fontFamily: light,
                                    ),
                                  ),
                                  Text(
                                    product['p_price'],
                                    style: const TextStyle(
                                      color: fontGreyDark,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Image.asset(
                            icDislikeButton,
                            width: 67,
                          ),
                          onPressed: ()
                            => controllercard.swipe(CardSwiperDirection.left),
                        ),
                        IconButton(
                          icon: Image.asset(
                            icViewMoreButton,
                            width: 67,
                          ),
                          onPressed: () {
                            Get.to(() => ItemDetails(
                                  title: product['p_name'],
                                  data: product,
                                ));
                          },
                        ),
                        IconButton(
                          icon: Image.asset(
                            icLikeButton,
                            width: 67,
                          ),
                        onPressed: () => [
                          controllercard.swipe(CardSwiperDirection.right),
                          controller.addToWishlist(product),
                        ],
                        ),
                      ],
                    ),
                  ],
                );
              },
              onSwipe: (previousIndex, currentIndex, direction){
                if(direction==CardSwiperDirection.right){
                  controller.addToWishlist(previousSwipedProduct!);
                }
                else if(direction==CardSwiperDirection.left){
                  //
                }
                else if(direction==CardSwiperDirection.top){
                  Get.to(() => ItemDetails(
                    title: previousSwipedProduct!['p_name'],
                    data: previousSwipedProduct!,
                ));
                }
                return true;
              },
              
            );
          },
        ),
      ),
    );
  }
}
Future<List<Map<String, dynamic>>> fetchProducts() async {
  return FirestoreServices.getFeaturedProducts();
}