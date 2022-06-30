import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_ex_delivery_app/controllers/notification_order_controller.dart';
import 'package:food_ex_delivery_app/models/imageFile.dart';
import 'package:food_ex_delivery_app/services/api-list.dart';
import 'package:food_ex_delivery_app/services/server.dart';
import 'package:food_ex_delivery_app/utils/font_size.dart';
import 'package:food_ex_delivery_app/utils/images.dart';
import 'package:food_ex_delivery_app/utils/size_config.dart';
import 'package:food_ex_delivery_app/utils/theme_colors.dart';
import 'package:food_ex_delivery_app/views/order/image_uploadOrders.dart';
import 'package:food_ex_delivery_app/views/order/notification/no_order_notification_page.dart';
import 'package:food_ex_delivery_app/views/order/order_details.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class PendingOrder extends StatefulWidget {
  const PendingOrder({Key? key}) : super(key: key);

  @override
  _PendingState createState() => _PendingState();
}

class _PendingState extends State<PendingOrder> {
  String acceptDialogue = "Are you sure you want to accept the order?";
  String cancelDialogue = "Are you sure you want to cancel the order?";
  String DialogueAccept = "Order Accept?";
  String DialogueCancel = "Order Cancel?";

  final order_Controller = Get.put(OrderListController());
  File? _image;
  final picker = ImagePicker();
  ImageFile? imageFile;
  TextEditingController _orderIdController = TextEditingController();
  var base64Image;
  Server server = Server();

  @override
  void initState() {
    super.initState();
  }

  showCustomImageDialog(BuildContext context,String orderId){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //image
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: <Widget>[
                            _buildAvatar(),
                            Positioned(
                              bottom: 0,
                                child: IconButton(

                              icon:
                              Icon(Icons.camera_alt_outlined,color: Colors.black,size:30.0,),
                              onPressed:(){
                                _openCamera(context,orderId);
                              },
                            ))
                          ],
                        )
                      ],
                    ),

                    SizedBox(height: 15.0,),

                    TextField(
                      controller: _orderIdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Order Id',
                        labelStyle: TextStyle(
                            color: Colors.grey, fontSize: 14),
                        hintText: 'Enter your Order Id here',
                        hintStyle: TextStyle(
                            color: Colors.grey, fontSize: 14),

                        fillColor: Colors.black,
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: ThemeColors.greyTextColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            width: 0.2,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 320.0,
                        child: RaisedButton(
                          onPressed: () {
                            if(_image==null){
                              Fluttertoast.showToast(msg: "Please select image");
                            }
                         else if(_orderIdController.text.isEmpty){
                            Fluttertoast.showToast(msg: "Please enter order Id");
                          }else if(!_orderIdController.text.toString().contains(orderId)){
                            Fluttertoast.showToast(msg: "Please enter valid Order Id");
                         }else{
                           Navigator.of(context).pop();
                              saveImageOrderId(base64Image, orderId);
                            }
                          },
                          child: Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: ThemeColors.baseThemeColor,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildAvatar(){
    if(_image!=null){
      return Container(
        width: 130,
        height: 130,
        // margin: EdgeInsets.only(top:20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
            Colors.green,  // red as border color
          ),
          color:
          Colors.black,

        ),

        child:
        ClipRRect(
          child: Image.file(
            _image!,
            fit: BoxFit.fill,
          ),

          borderRadius: BorderRadius.circular(10),

        ),

      );
    }else{
      return Container(
        width: 130,
        height: 130,
        // margin: EdgeInsets.only(top:20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
            Colors.black,  // red as border color
          ),
          color:
          Colors.white,

        ),

        child:
        ClipRRect(
          child: Image.asset(Images.profileBackground,
            fit: BoxFit.fill,
          ),

          borderRadius: BorderRadius.circular(10),

        ),

      );
    }

  }

  //method to open camera
  _openCamera(BuildContext context, String orderId) async {
    final imageCamera = await picker.getImage(source: ImageSource.camera);
    imageFile=new ImageFile();
    if (imageCamera != null) {
      _cropImage(imageCamera,orderId);
      // state = AppState.picked;
    }
  }

  Future<Null> _cropImage(PickedFile imageCropped, String orderId) async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: imageCropped.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          // CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio4x3,
        ]
            : [
          // CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio4x3,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {

      setState(() {
        _image = croppedFile;
        imageFile!.imagePath=_image!.path;
        var bytes = File(_image!.path).readAsBytesSync();
        base64Image = base64Encode(bytes);

      });
      // Navigator.pop(context);
    }
  }


  //to save image and orderId
  saveImageOrderId(String imageBase64, String id) async {
    order_Controller.loader = true;
    Future.delayed(Duration(milliseconds: 10), () {
      order_Controller.update();
    });

    var jsonMap = {
      'file': imageBase64,
    };
    String jsonStr = jsonEncode(jsonMap);
    server
        .putRequest(
        endPoint: APIList.getImageNotificationOrder! + id + '/upload_order_image',
        body: jsonStr)
        .then((response) {
      final jsonResponse = json.decode(response.body);
      print(jsonResponse);
      if (response != null && response.statusCode == 200) {
        order_Controller.onInit();
        Future.delayed(Duration(milliseconds: 10), () {
          order_Controller.update();
        });

        showAlertDialog(
            context,
            DialogueAccept,
            acceptDialogue,
            '5',
            id);
        print('upload proccess started');
      } else {
        Get.rawSnackbar(message: 'Please enter valid input');
        Future.delayed(Duration(milliseconds: 10), () {
          order_Controller.update();
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderListController>(
      init: OrderListController(),
      builder: (orders) => Expanded(
        child: orders.orderList.isEmpty
            ? NoOrderNotification()
            : ListView.builder(
                itemCount: orders.orderList.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      width: SizeConfig.screenWidth,
                      //height: SizeConfig.screenHeight!/3.5,
                      child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.access_time),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(orders.orderList[index].timeFormat
                                            .toString()),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5, bottom: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(right: 5),
                                            height: 30,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                //  elevation: 0.0,
                                                primary:
                                                    Colors.green, // background
                                                // foreground
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10), // <-- Radius
                                                ),
                                              ),
                                              onPressed: () async {
                                                // setState(() {
                                                  // showAlertDialog(
                                                  //     context,
                                                  //     DialogueAccept,
                                                  //     acceptDialogue,
                                                  //     '5',
                                                  //     orders.orderList[index].id
                                                  //         .toString());
                                                  Get.to(()=>ImageUploadOrders(orderId: orders.orderList[index].id
                                                      .toString(),));
                                                  // showCustomImageDialog(context,orders.orderList[index].id
                                                  //             .toString());
                                                // });
                                              },
                                              child: Text(
                                                'Accept',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 30,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                //  elevation: 0.0,
                                                primary:
                                                    Colors.red, // background
                                                onPrimary:
                                                    Colors.white, // foreground
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10), // <-- Radius
                                                ),
                                              ),
                                              onPressed: () async {
                                                setState(() {
                                                  showAlertDialog(
                                                      context,
                                                      DialogueCancel,
                                                      cancelDialogue,
                                                      '10',
                                                      orders.orderList[index].id
                                                          .toString());
                                                });
                                              },
                                              child: Text(
                                                'Reject',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 1),
                                  child: Divider(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 10, left: 5, right: 5),
                                  child: Row(
                                    children: [
                                      //order id
                                      Text(
                                        "Order Id: #",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          //    color: Colors.deepOrange
                                        ),
                                      ),
                                      Text(
                                        orders.orderList[index].id!.toString(),
                                        style: TextStyle(
                                          color: ThemeColors.scaffoldBgColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: FontSize.xMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 5),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Time: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16
                                            // color: Colors.grey
                                            ),
                                      ),
                                      Text(
                                        orders.orderList[index].createdAt
                                            .toString(),
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          //fontWeight: FontWeight.w300,
                                          fontSize: 13,
                                          color: Colors.grey,
                                          fontFamily: 'AirbnbCerealBold',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 5),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Payment mode: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,

                                          fontSize: 16,
                                          // color: Colors.grey
                                        ),
                                      ),
                                      Text(
                                        orders.orderList[index]
                                            .payment_method_name
                                            .toString(),
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          // fontWeight: FontWeight.w300,
                                          fontSize: 13,
                                          color: Colors.grey,
                                          fontFamily: 'AirbnbCerealBold',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                )
                              ],
                            ),
                          ),
                          elevation: 1,
                          // shadowColor: Colors.blueGrey,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            side: BorderSide(
                              width: 0.05,
                            ),
                          )));
                }),
      ),
    );
  }

  //show alertDialogue

  showAlertDialog(
      BuildContext context, dialogueAccept, String alertMessage, status, id) {
    //  int? oId = int.parse(id);

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        order_Controller.changeStatus(status, id);
        Navigator.of(context).pop();
        Get.to(() => OrderDetailsById(
              orderId: int.parse(id),
            ));
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(dialogueAccept),
      content: Text(alertMessage),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
