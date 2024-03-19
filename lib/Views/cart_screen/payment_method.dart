// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_finalproject/Views/collection_screen/loading_indicator.dart';
import 'package:flutter_finalproject/Views/widgets_common/our_button.dart';
import 'package:flutter_finalproject/consts/colors.dart';
import 'package:flutter_finalproject/consts/lists.dart';
import 'package:flutter_finalproject/consts/styles.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_finalproject/controllers/cart_controller.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:omise_flutter/omise_flutter.dart'; // เพิ่ม Omise SDK ที่นี่

import '../home_screen/navigationBar.dart';

class PaymentMethods extends StatelessWidget {
  const PaymentMethods({super.key});
  
  @override
  Widget build(BuildContext context) {
    var controller = Get.find<CartController>();

    const publicKey = "pkey_test_5yzhwpn9nih3syz8e2v";
    OmiseFlutter omise = OmiseFlutter(publicKey);

    return Obx(() =>  Scaffold(
        backgroundColor: whiteColor,
        bottomNavigationBar: SizedBox(
          height: 70,
          child: controller.placingOrder.value ? Center(
            child: loadingIndcator(),
          ) : ourButton(
              onPress: () async {
                await controller.placeMyOrder(
                  orderPaymentMethod: paymentMethods[controller.paymentIndex.value],
                  totalAmount: controller.totalP.value
                ); 

                await controller.clearCart();
                VxToast.show(context, msg: "Order placed successfully");

                Get.offAll(MainNavigationBar());
              },
              color: primaryApp,
              textColor: whiteColor,
              title: "Place my order"),
              
    ),),
    );
  }
}
