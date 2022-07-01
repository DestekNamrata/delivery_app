import 'dart:convert';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_ex_delivery_app/services/server.dart';
import 'package:food_ex_delivery_app/views/home_page.dart';
import 'package:food_ex_delivery_app/views/main_screen.dart';
import 'package:food_ex_delivery_app/views/order/order_details.dart';
// import 'package:food_ex/Controllers/auth-controller.dart';
// import 'package:food_ex/utils/image.dart';
import 'package:get/get.dart';

import 'dart:async';

import 'package:pin_code_fields/pin_code_fields.dart';

import '../controllers/auth-controller.dart';
import '../controllers/global-controller.dart';
import '../controllers/order_details_controller.dart';
import '../services/api-list.dart';
import '../utils/images.dart';
import '../widgets/shimmer/oder_details_shimmer.dart';


// class VerifyPhonePage extends GetView<SignUpController> {
class VerifyPhonePage extends StatefulWidget {
  String? flagVerify,phone;
  final int? orderID;

  VerifyPhonePage({Key? key,@required this.flagVerify,this.orderID}):super(key: key);

  VerifyPhoneState createState()=>VerifyPhoneState();
}
class VerifyPhoneState extends State<VerifyPhonePage>{
  final AuthController controller = Get.put(AuthController());
  final settingsController = Get.put(GlobalController());

  final TextEditingController textEditingController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _counter = 10;
  late Timer _timer;
  bool loading=false;
  String? _verificationID;

  Server server = Server();

  get pin => null;
  var orderDetailsController;

  @override
  void initState() {
    super.initState();
    orderDetailsController=Get.put(OrderDetailsController(widget.orderID));
    _startTimer();

  }

  @override
  void dispose(){
    super.dispose();
    _timer.cancel();
  }

  void _startTimer() {
    _counter = 30;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_counter > -1) {
        setState(() {
          _counter--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  Future<void> sendOtpFirebase(number) async{
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91",

      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        loading = false;
        if (e.code == 'invalid-phone-number') {
          // Get.bottomSheet(ErrorAlert(
          //   message: "Phone number is not valid".tr,
          //   onClose: () {
          //     Get.back();
          //   },
          // ));
          Fluttertoast.showToast(msg: "Phone number is not valid".tr);
        }
      },
      codeSent: (String vId, int? resendToken) {
        loading = false;
        controller.verificationId = vId;
        _startTimer();
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

  }

  orderStatus(String status, int? id) async {
    // loader = true;
    // Future.delayed(Duration(milliseconds: 10), () {
    //   update();
    // });

    var jsonMap = {
      'status': int.parse(status),
    };
    String jsonStr = jsonEncode(jsonMap);
    server
        .putRequest(
        endPoint:
        APIList.notificationOrderStatus! + id.toString() + '/update',
        body: jsonStr)
        .then((response) {
      if (response != null && response.statusCode == 200) {


        Get.to(() => MainScreen());

      } else {
        Get.rawSnackbar(message: 'Please enter valid input');

      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Get.isDarkMode
          ? Color.fromRGBO(19, 20, 21, 1)
          : Color.fromRGBO(243, 243, 240, 1),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(children: <Widget>[
            Positioned(
              height: 400,
              left: 90,
              right: 90,
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 0.099),
                child: Image(
                  image: AssetImage(Get.isDarkMode
                      ? Images.splashImage
                      : Images.splashImage),
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Container(
            //   width: MediaQuery.of(context).size.width,
            //   height: 22,
            //   margin: EdgeInsets.only(top: 0.075, right: 16, left: 30),
            //   alignment: Alignment.centerLeft,
            //   child: Image.asset(Images.splashImage),
            //   //  Text(
            //   //   "$APP_NAME",
            //   //   style: TextStyle(
            //   //       fontFamily: 'Inter',
            //   //       fontWeight: FontWeight.w700,
            //   //       fontSize: 18.sp,
            //   //       letterSpacing: -1,
            //   //       color: Get.isDarkMode
            //   //           ? Color.fromRGBO(255, 255, 255, 1)
            //   //           : Color.fromRGBO(0, 0, 0, 1)),
            //   // ),
            // ),
            // Obx(() =>
                Positioned(
              bottom: 0,
              child:
              Container(
                width: MediaQuery.of(context).size.width,
                height: 300.0,
                padding: EdgeInsets.only(
                    top: 10.0,
                    left: 10.0,
                    right: 10.0,
                    bottom: 10.0),
                decoration: BoxDecoration(
                    color: Get.isDarkMode
                        ? Color.fromRGBO(37, 48, 63, 1)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Text(
                        "Verify phone".tr,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 20.0,
                            letterSpacing: -2,
                            color: Get.isDarkMode
                                ? Color.fromRGBO(255, 255, 255, 1)
                                : Color.fromRGBO(0, 0, 0, 1)),
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    // Container(
                    //     alignment: Alignment.centerLeft,
                    //     child: RichText(
                    //         text: TextSpan(
                    //             text: "Code is sent to ".tr,
                    //             style: TextStyle(
                    //                 fontFamily: 'Inter',
                    //                 fontWeight: FontWeight.w500,
                    //                 fontSize: 16.0,
                    //                 color: Get.isDarkMode
                    //                     ? Color.fromRGBO(255, 255, 255, 1)
                    //                     : Color.fromRGBO(0, 0, 0, 1)),
                    //             children: <TextSpan>[
                    //               TextSpan(
                    //                   text: controller.phoneController.text,
                    //                   style: TextStyle(
                    //                       fontFamily: 'Inter',
                    //                       fontWeight: FontWeight.w700,
                    //                       fontSize: 16.0,
                    //                       color: Get.isDarkMode
                    //                           ? Color.fromRGBO(255, 255, 255, 1)
                    //                           : Color.fromRGBO(0, 0, 0, 1)))
                    //             ]))),
                    Container(
                      margin: EdgeInsets.only(top: 20.0),
                      child: Form(
                        key: formKey,
                        child: Padding(
                            padding: EdgeInsets.symmetric(),
                            child: PinCodeTextField(
                              appContext: context,
                              pastedTextStyle: TextStyle(
                                color: Color.fromRGBO(235, 237, 242, 1),

                                fontWeight: FontWeight.bold,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[0-9]+')),
                              ],
                              length: 6,
                              obscureText: false,
                              obscuringCharacter: '*',
                              animationType: AnimationType.fade,
                              hintCharacter: "0",
                              hintStyle: TextStyle(

                                  fontWeight: FontWeight.w500,
                                  fontSize: 20.0,
                                  color: Get.isDarkMode
                                      ? Color.fromRGBO(130, 139, 150, 0.26)
                                      : Color.fromRGBO(
                                      136, 136, 126, 0.26)),

                              pinTheme: PinTheme(
                                borderWidth: 1,
                                shape: PinCodeFieldShape.underline,
                                fieldHeight:40.0,
                                fieldWidth: 40.0,
                                activeColor: Get.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                selectedColor: Get.isDarkMode
                                    ? Color.fromRGBO(37, 48, 63, 1)
                                    : Colors.white,
                                activeFillColor: Get.isDarkMode
                                    ? Color.fromRGBO(37, 48, 63, 1)
                                    : Colors.white,
                                inactiveColor:
                                Color.fromRGBO(224, 224, 221, 1),
                                selectedFillColor: Get.isDarkMode
                                    ? Color.fromRGBO(37, 48, 63, 1)
                                    : Colors.white,
                                inactiveFillColor: Get.isDarkMode
                                    ? Color.fromRGBO(37, 48, 63, 1)
                                    : Colors.white,
                              ),
                              cursorColor: Get.isDarkMode
                                  ? Color.fromRGBO(255, 255, 255, 1)
                                  : Color.fromRGBO(0, 0, 0, 1),
                              animationDuration:
                              Duration(milliseconds: 300),
                              textStyle: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 25.0,
                                color: Get.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              backgroundColor: Get.isDarkMode
                                  ? Color.fromRGBO(37, 48, 63, 1)
                                  : Colors.white,
                              enableActiveFill: true,
                              errorAnimationController:
                              controller.errorController,
                              controller: textEditingController,
                              keyboardType: TextInputType.number,
                              onCompleted: (v) {},
                              onChanged: (value) {
                                controller.onChangeSmsCode(value);
                              },
                              beforeTextPaste: (text) {
                                return true;
                              },
                            ),
                        ),
                      ),
                    ),
                    // Container(
                    //   alignment: Alignment.center,
                    //   margin: EdgeInsets.only(top: 0.03.sh),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: <Widget>[
                    //       Text(
                    //         "Didn’t recieve code?".tr,
                    //         style: TextStyle(
                    //             fontFamily: 'Inter',
                    //             fontWeight: FontWeight.w500,
                    //             fontSize: 14.sp,
                    //             letterSpacing: -0.5,
                    //             color: Get.isDarkMode
                    //                 ? Color.fromRGBO(255, 255, 255, 1)
                    //                 : Color.fromRGBO(0, 0, 0, 1)),
                    //       ),
                    //       Text(
                    //         " ${"Request again".tr}",
                    //         style: TextStyle(
                    //             fontFamily: 'Inter',
                    //             fontWeight: FontWeight.w500,
                    //             fontSize: 14.sp,
                    //             letterSpacing: -0.5,
                    //             color: Color.fromRGBO(69, 165, 36, 1)),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 5.0,),
                    _counter!=-1
                        ?

                    Align(
                        alignment: Alignment.bottomRight,
                        child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.access_time_filled_sharp,
                              color: Colors.black,
                            ),
                            SizedBox(height: 10.0,),
                            Text(_counter.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16.0,fontFamily: 'Sofia Pro'),)

                          ],
                        ))
                        :
                    Align(
                        alignment: Alignment.bottomRight,
                        child:
                        InkWell(
                            onTap: (){
                              var number;
                              // if (Get.arguments['flagVerify'] == "0") {
                              //   number = signIncontroller.phone.value;
                              // } else {
                              //   number = controller.phone.value;
                              // }
                              sendOtpFirebase(number);
                            },
                            child:Text("Resend OTP",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16.0,fontFamily: 'Sofia Pro'),))),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: 45.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: Color.fromRGBO(69, 165, 36, 1)),
                        margin: EdgeInsets.only(top: 10.0),
                        alignment: Alignment.center,
                        child: TextButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<
                                  EdgeInsetsGeometry>(EdgeInsets.all(0))),
                          onPressed: (){
                            orderStatus('20',widget.orderID);


                            // if(widget.flagVerify=="0"){
                            //   controller.loginOnTap(context: context,phone: widget.phone);
                            // }else {
                            //   controller.signupOnTap(context: context,
                            //   name: widget.name,
                            //   phoneNumber: widget.phone,
                            //   password: widget.password,
                            //   confirmPassword: widget.cnfPass,
                            //   );
                            // }
                            // controller.loginOnTap(context: context,phone: widget.phone);

                          },
                          child: Text(
                            "Verify".tr,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 18.0,
                                color: Color.fromRGBO(255, 255, 255, 1)),
                          ),
                        )),
                  ],
                ),
              ),
            )
        // )
          ]),
        ),
      ),

    );
  }
}
