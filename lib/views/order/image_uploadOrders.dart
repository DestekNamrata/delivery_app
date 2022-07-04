import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_ex_delivery_app/controllers/notification_order_controller.dart';
import 'package:food_ex_delivery_app/models/imageFile.dart';
import 'package:food_ex_delivery_app/services/api-list.dart';
import 'package:food_ex_delivery_app/services/server.dart';
import 'package:food_ex_delivery_app/utils/font_size.dart';
import 'package:food_ex_delivery_app/utils/images.dart';
import 'package:food_ex_delivery_app/utils/theme_colors.dart';
import 'package:food_ex_delivery_app/views/order/order_details.dart';
import 'package:food_ex_delivery_app/widgets/loader.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadOrders extends StatefulWidget{
  String orderId;
  ImageUploadOrders({Key? key,required this.orderId}):super(key: key);
  _ImageUploadOrdersState createState()=>_ImageUploadOrdersState();
}

class _ImageUploadOrdersState extends State<ImageUploadOrders>{
  String acceptDialogue = "Are you sure you want to accept the order?";
  String cancelDialogue = "Are you sure you want to cancel the order?";
  String DialogueAccept = "Order Accept?";
  String DialogueCancel = "Order Cancel?";

  File? _image;
  final picker = ImagePicker();
  ImageFile? imageFile;
  TextEditingController _orderIdController = TextEditingController();
  var base64Image;
  Server server = Server();
  final order_Controller = Get.put(OrderListController());
  bool loading=false;


  Widget _buildAvatar() {
    if (_image != null) {
      return Container(
        width: 180,
        height: 180,
        // margin: EdgeInsets.only(top:20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
            Colors.green, // red as border color
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
    } else {
      return Container(
        width: 180,
        height: 180,
        // margin: EdgeInsets.only(top:20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
            Colors.black, // red as border color
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

  Widget buildAvatar(){
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

  //to save image and orderId
  saveImageOrderId(String imageBase64, String id) async {
    // order_Controller.loader = true;
    // Future.delayed(Duration(milliseconds: 10), () {
    //   order_Controller.update();
    // });
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
        // order_Controller.onInit();
        // Future.delayed(Duration(milliseconds: 10), () {
        //   order_Controller.update();
        // });
       setState(() {
         loading=false;
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
        Get.off(() => OrderDetailsById(
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  GetBuilder<OrderListController>(
        init: OrderListController(),
    builder: (orders) =>
      Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Order Id: #"+widget.orderId,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: FontSize.xLarge,
                color: Colors.white),
          ),
          backgroundColor: Colors.green,
          centerTitle: false,
          elevation: 0.0,
        ),
        body:Stack(
          children: [
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
                                _openCamera(context,widget.orderId);
                              },
                            ))
                      ],
                    )
                  ],
                ),

                SizedBox(height: 15.0,),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
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
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: RaisedButton(
                      onPressed: () {
                        if(_image==null){
                          Fluttertoast.showToast(msg: "Please select image");
                        }
                        else if(_orderIdController.text.isEmpty){
                          Fluttertoast.showToast(msg: "Please enter order Id");
                        }else if(!_orderIdController.text.toString().contains(widget.orderId)){
                          Fluttertoast.showToast(msg: "Please enter valid Order Id");
                        }else{
                          // Navigator.of(context).pop();
                          setState(() {
                            loading=true;

                          });
                          saveImageOrderId(base64Image, widget.orderId);
                        }
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: ThemeColors.baseThemeColor,
                    ),
                  ),
                ),

              ],
            ),
           loading==true
                ? Positioned(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.white60,
                child: Center(
                  child: Loader(),
                ),
              ),
            )
                : SizedBox.shrink(),
          ],
        )

    ));
  }

}