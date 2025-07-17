import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

TextStyle drawerTextStyle = GoogleFonts.poppins(
  fontSize: 16,
  color: Colors.black,
  fontWeight: FontWeight.w500,
);

TextStyle hometitle = GoogleFonts.poppins(
  fontSize: 14,
  color: Colors.black,
  fontWeight: FontWeight.w600,
);
TextStyle filterTextStyle = GoogleFonts.montserrat(
  fontSize: 13,
  color: Colors.black,
  fontWeight: FontWeight.w300,
);
TextStyle subfilterTextStyle = GoogleFonts.montserrat(
  fontSize: 12,
  color: Colors.grey,
  fontWeight: FontWeight.w400,
);

TextStyle exploreheaderStyle = GoogleFonts.montserrat(
  color: Colors.blue[900],
  fontWeight: FontWeight.bold,
  fontSize: 14,
);

TextStyle sideTextStyleOrderPrivew = GoogleFonts.montserrat(
  fontSize: 13,
  color: Colors.black,
  fontWeight: FontWeight.w600,
);

class DialogExit {
  static Future<void> showLoadingDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to Exit an App'),
        actions: <Widget>[
          MaterialButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          MaterialButton(
            onPressed: () {
              exit(0);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}


class GoogleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GoogleLoginButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Image.asset('assets/google.png', height: 24), // Add logo
      label: Text("Sign in with Google"),
      onPressed: onPressed,
    );
  }
}


class RoundedButtonClass extends StatelessWidget {
  final String buttonText;
  bool selectedVal;
  dynamic ontapbutton;
  RoundedButtonClass({
    required this.buttonText,
    required this.selectedVal,
    this.ontapbutton,
  });
  FocusNode myFocusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialButton(
          // minWidth: ,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(45.0),
            side: BorderSide(
              color: Colors.grey[500]!,
              width: 0.5,
            ),
          ),
          child: Text(buttonText,
              style: selectedVal
                  ? GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    )
                  : GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    )),
          color: selectedVal ? Colors.blue : Colors.white,
          onPressed: ontapbutton),
    );
  }
}

// ignore: must_be_immutable
class RoundedButton extends StatelessWidget {
  final String buttonText;
  bool selectedVal;
  dynamic ontapbutton;
  RoundedButton({
    required this.buttonText,
    required this.selectedVal,
    this.ontapbutton,
  });
  FocusNode myFocusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      child: MaterialButton(
          height: 40,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(45.0),
            side: BorderSide(
              color: Colors.grey[500]!,
              width: 0.5,
            ),
          ),
          child: Text(buttonText,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              )),
          color: MyColorsNew.appcolor,
          onPressed: ontapbutton),
    );
  }
}

class MyDropDownListCusotmProfile2 extends StatelessWidget {
  MyDropDownListCusotmProfile2(
      {this.lText,
      this.onChanged,
      this.currentSelectdValue,
      required this.list,
      this.defaultHeaderStyle,
      this.headerStyle,
      this.valueFieldName,
      this.title,
      this.tit,
      this.textFieldName});

  final String? lText;
  final String? tit;
  final onChanged;
  final String? defaultHeaderStyle;
  final TextStyle? headerStyle;
  final String? title;
  String? currentSelectdValue;
  final String? valueFieldName;
  final String? textFieldName;
  List list = [];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      // shadowColor: Colors.yellow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
      child: FormField<String>(
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: new BorderRadius.circular(5.0),
                borderSide: BorderSide(color: Colors.grey),
              ),
              enabledBorder: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(5.0),
                borderSide: BorderSide(color: Colors.grey),
              ),
              contentPadding: EdgeInsets.only(left: 10, right: 10, bottom: 0),
              labelText: lText,
              labelStyle: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                //letterSpacing: 1,
                textStyle: TextStyle(),
              ),
            ),
            child: Container(
              //height: 200,
              width: MediaQuery.of(context).size.width / 1.2,
              margin: EdgeInsets.only(left: 7, right: 15),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  // underline: SizedBox(),
                  dropdownColor: Colors.white,
                  value: list.any((element) =>
                          element[valueFieldName].toString() ==
                          currentSelectdValue)
                      ? currentSelectdValue
                      : null,
                  // isDense: true,
                  isExpanded: true,
                  // iconSize: 35.0,
                  iconDisabledColor: Colors.black,
                  iconEnabledColor: Colors.black,
                  style: TextStyle(color: Colors.black),
                  onChanged: (String? newValue) {
                    onChanged(newValue);
                    currentSelectdValue = newValue;
                    state.didChange(newValue);
                  },
                  items: list.map((value) {
                    return DropdownMenuItem<String>(
                        value: value[valueFieldName].toString(),
                        child: Container(
                          // height: 40,
                          // width: MediaQuery.of(context).size.width / 1.2,
                          //   color: Colors.blue,
                          // margin: EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.centerRight,
                          child: Text(
                            value[textFieldName],
                            textAlign: TextAlign.right,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ));
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

TextStyle drawerTopTextStyle = GoogleFonts.montserrat(
  fontSize: 16,
  color: Colors.white,
  fontWeight: FontWeight.w600,
);

TextStyle mainpageheading = GoogleFonts.poppins(
  fontSize: 13.0,
  color: Colors.grey[200],
  fontWeight: FontWeight.w500,
);

class ProductListTotalsave {
  static double qty = 0.0;
  static double totalnetPrice = 0.0;
  static double totalsalingprice = 0.0;
  static double totalMrp = 0.0;
  static double totalpricediscount = 0.0;
  static double totalsaving = 0;
  static double totaldiscount = 0;
}

TextStyle pageHeading = GoogleFonts.poppins(
  fontSize: 15.0,
  color: Colors.grey[200],
  fontWeight: FontWeight.w500,
);

// ignore: camel_case_types
class finalselectedCardList {
  static List pressbutton = [];
}

TextStyle b2bFooterData = GoogleFonts.poppins(
  fontSize: 15.0,
  color: Colors.black,
  fontWeight: FontWeight.w600,
);


TextStyle b2bFooterNormal = GoogleFonts.poppins(
  fontSize: 13.0,
  color: Colors.black,
  fontWeight: FontWeight.w500,
);
TextStyle drawerTextStylenewText = GoogleFonts.montserrat(
  fontSize: 10.0,
  color: Colors.white,
  fontWeight: FontWeight.w600,
);
TextStyle bottom = GoogleFonts.poppins(
  fontSize: 12.0,
  fontWeight: FontWeight.bold,
);
TextStyle bottom1 = GoogleFonts.poppins(
  fontSize: 16.0,
  color: Colors.black,
  fontWeight: FontWeight.bold,
);

class MyColorsNew {
  static const Color drwaerIconColor = Colors.black;
  static const Color buttonColor = Color(0xff0a7abb);
  static const Color cartbutton = Color(0xff1ca49a);
  static const Color appcolor = Color(0xff0a7abb);
}

TextStyle textStyleMyAccountsSubTitle = GoogleFonts.montserrat(
  fontSize: 9,
  color: Colors.black45,
  fontStyle: FontStyle.normal,
);

TextStyle textStyleMyAccountsHeaderEnable = GoogleFonts.montserrat(
  fontSize: 13.0,
  color: Colors.blue[900],
  fontWeight: FontWeight.bold,
  fontStyle: FontStyle.normal,
);

TextStyle profileSubHeading3 = GoogleFonts.montserrat(
  fontSize: 13,
  color: Colors.black,
  fontWeight: FontWeight.w400,
);
TextStyle headerTextStyle = GoogleFonts.montserrat(
  fontSize: 14,
  color: Colors.green,
  fontWeight: FontWeight.bold,
);
TextStyle headerTextStyle1 = GoogleFonts.montserrat(
  fontSize: 16,
  color: Colors.green,
  fontWeight: FontWeight.bold,
  decoration: TextDecoration.underline,
);

TextStyle headerTextStyleMyAccount = GoogleFonts.montserrat(
  fontSize: 14.0,
  color: Colors.black,
  fontWeight: FontWeight.bold,
  fontStyle: FontStyle.normal,
);

TextStyle dangertext = GoogleFonts.poppins(
  fontSize: 15.0,
  color: Colors.red,
  fontWeight: FontWeight.w500,
  fontStyle: FontStyle.normal,
);

//Logout app dialog.....................
class DialogLogout {
  static Future<void> showLoadingDialog(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to logout an App'),
        actions: <Widget>[
          MaterialButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          MaterialButton(
            onPressed: () {
              preferences.clear();
              exit(0);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}

class Prolistshimmer extends StatelessWidget {
  Prolistshimmer({
    this.link,
  });
  int? link;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        // backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
          margin: EdgeInsets.only(top: 10.0, left: 10, right: 10),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            loop: 2,
            // enabled: _enabled,
            child: ListView.builder(
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 80,
                      width: 80,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: 30.0,
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: 15.0,
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: 15.0,
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(),
                              SizedBox(
                                width: 160,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(45.0)),
                                  height: 25,
                                  width: 80,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              itemCount: link,
            ),
          ),
        ));
  }
}

/*
bool minMaxStockCheck(
    String minStock_param_defalut,
    String maxStock_param_defalut,
    String stock_param_default,
    String inputQty_param_default) {
  double minStock_param = double.parse(minStock_param_defalut);
  double maxStock_param = double.parse(maxStock_param_defalut);
  double stock_param = double.parse(stock_param_default);
  double inputQty_param = double.parse(inputQty_param_default);
 
  bool condition = true;
  if (minStock_param <= inputQty_param) {
    if ((maxStock_param == 0 ||
        maxStock_param == 0.0 ||
        maxStock_param == 00)) {
      if (stock_param >= inputQty_param) {
        condition = true;
      } else {
        Fluttertoast.showToast(
            msg: "InSufficient stock.1 Avl Stock" + stock_param.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.grey[850],
            textColor: Colors.white,
            fontSize: 16.0);
        condition = false;
      }
    } else {
      if (maxStock_param >= inputQty_param) {
        if (stock_param >= inputQty_param) {
          condition = true;
        } else {
          Fluttertoast.showToast(
              msg: "InSufficient stock. 2 Avl Stock" + stock_param.toString(),  
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.grey[850],
              textColor: Colors.white,
              fontSize: 16.0);
          condition = false;
        }
      } else {
        Fluttertoast.showToast(
            msg: "Max Product Qty allowed " + maxStock_param.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.grey[850],
            textColor: Colors.white,
            fontSize: 16.0);
        condition = false;
      }
    }
  } else {
    Fluttertoast.showToast(
        msg: "Min Product Qty should be " + minStock_param.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.grey[850],
        textColor: Colors.white,
        fontSize: 16.0);
    condition = false;
  }

  return condition;
}
*/

bool minMaxStockCheck(
    String minStock_param_default,
    String maxStock_param_default,
    String stock_param_default,
    String inputQty_param_default) {
  // Parse string inputs to double
  double minStock = double.tryParse(minStock_param_default) ?? 0.0;
  double maxStock = double.tryParse(maxStock_param_default) ?? 0.0;
  double stock = double.tryParse(stock_param_default) ?? 0.0;
  double inputQty = double.tryParse(inputQty_param_default) ?? 0.0;

  // Check if input quantity meets the minimum stock requirement
  if (inputQty < minStock) {
    Fluttertoast.showToast(
        msg: "Minimum product quantity should be $minStock",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.grey[850],
        textColor: Colors.white,
        fontSize: 16.0);
    return false;
  }

  // Check if input quantity exceeds the maximum stock limit (if maxStock > 0)
  if (maxStock > 0 && inputQty > maxStock) {
    Fluttertoast.showToast(
        msg: "Maximum product quantity allowed is $maxStock",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.grey[850],
        textColor: Colors.white,
        fontSize: 16.0);
    return false;
  }

  // Check if the available stock is sufficient
  if (inputQty > stock) {
    Fluttertoast.showToast(
        msg: "Insufficient stock. Available stock: $stock",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.grey[850],
        textColor: Colors.white,
        fontSize: 16.0);
    return false;
  }
  return true; // All checks passed
}

bool isMaxQuantityValid(String maxQuantity) {
  try {
    double parsedMaxQuantity = double.parse(maxQuantity);
    //double parsedMinQuantity = double.parse(minQuantity);

    if ((parsedMaxQuantity == 0 || parsedMaxQuantity == 0.00)) {
      return false;
    }
    print("return true...............");
    return true; // Valid maxQuantity
  } catch (e) {
    print("catch false print.................");

    return false;
  }
}

bool isMinQuantityValid(String minQuantity) {
  try {
    double parsedMinQuantity = double.parse(minQuantity);

    // Return false if maxQuantity is 0 or negative
    if (parsedMinQuantity == 0) {
      return false;
    }
    print("return true...............");
    return true; // Valid maxQuantity
  } catch (e) {
    print("catch false print.................");
    // If parsing fails, assume invalid maxQuantity
    return false;
  }
}

TextStyle header = GoogleFonts.poppins(
    fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black);
TextStyle subheader = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey);

TextStyle invoiceheader = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black);
TextStyle invoicesubheader = GoogleFonts.poppins(
    fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black);

class AddtoCardBtn extends StatelessWidget {
  final pressminus;
  final pressplus;
  final String? text;

  const AddtoCardBtn({
    super.key,
    this.pressminus,
    this.pressplus,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      height: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MaterialButton(
            minWidth: 10,
            padding: EdgeInsets.all(0),
            onPressed: pressminus,
            shape: CircleBorder(),
            child: Icon(
              Icons.remove_circle_outline,
              color: Colors.grey,
              size: 25,
            ),
          ),
          Container(
            child: Center(
              child: Text(text!, style: subheader),
            ),
          ),
          MaterialButton(
            padding: EdgeInsets.all(0),
            minWidth: 10,
            splashColor: Colors.red,
            onPressed: pressplus,
            shape: CircleBorder(),
            child: Icon(
              Icons.add_circle,
              size: 25,
              color: MyColorsNew.appcolor,
            ),
          ),
        ],
      ),
    );
  }
}

class DownloadIcon extends StatelessWidget {
  final VoidCallback? pressPdf;
  final VoidCallback? pressExcel;
  final VoidCallback? pressCsv;
  final String? assetPdf;
  final String? assetExcel;
  final String? assetCsv;

  const DownloadIcon({
    Key? key,
    this.pressPdf,
    this.pressExcel,
    this.pressCsv,
    this.assetPdf,
    this.assetExcel,
    this.assetCsv,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // PDF Button with AssetImage
          InkWell(
            onTap: pressPdf,
            child: Container(
              margin: EdgeInsets.only(right: 15),
              child: Image.asset(
                assetPdf ?? 'assets/icons/pdf_icon.png',
                width: 28,
                height: 28,
              ),
            ),
          ),
          // Excel Button with AssetImage
          InkWell(
            onTap: pressExcel,
            child: Container(
              margin: EdgeInsets.only(right: 15),
              child: Image.asset(
                assetExcel ?? 'assets/icons/excel_icon.png',
                width: 28,
                height: 28,
              ),
            ),
          ),
          // CSV Button with AssetImage
          InkWell(
            onTap: pressCsv,
            child: Container(
              margin: EdgeInsets.only(right: 15),
              child: Image.asset(
                assetCsv ?? 'assets/icons/csv_icon.png',
                width: 28,
                height: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class NamedIcon extends StatelessWidget {
  final IconData? iconData;
  final String? text;
  final onTap;
  final notificationCount;

  const NamedIcon({
    super.key,
    this.onTap,
    this.text,
    this.iconData,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        /// color: Colors.blue,
        margin: EdgeInsets.only(right: 10),
        width: 60,
        //  height: 20,
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  iconData,
                  color: MyColorsNew.buttonColor,
                  size: 25,
                ),
              ],
            ),
           
            Positioned(
              right: 1,
              top: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                alignment: Alignment.center,
                child: Text(notificationCount,
                    style: GoogleFonts.poppins(
                      fontSize: 10.0,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}



class NamedIconReturn extends StatelessWidget {
  final IconData? iconData;
  final String? text;
  final onTap;
  final int? notificationCount;

  const NamedIconReturn({
    super.key,
    this.onTap,
    this.text,
    this.iconData,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {  
    return InkWell(
      onTap: onTap,
      child: Container(
        /// color: Colors.blue,
        margin: EdgeInsets.only(right: 10),
        width: 60,
        //  height: 20,
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  iconData,
                  color: MyColorsNew.buttonColor,
                  size: 25,
                ),
              ],
            ),
           
            Positioned(
              right: 1,
              top: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                alignment: Alignment.center,
                child: Text(notificationCount.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 10.0,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}


class NamedIcon1 extends StatelessWidget {
  final IconData? iconData;
  final String? text;
  final onTap;
  final notificationCount;

  const NamedIcon1({
    super.key,
    this.onTap,
    this.text,
    this.iconData,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        /// color: Colors.blue,
        margin: EdgeInsets.only(right: 0),
        width: 120,
        //  height: 20,
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  iconData,
                  color: MyColorsNew.buttonColor,
                  // size: 18,
                ),
              ],
            ),
            Positioned(
              left: 5,
              top: 0,
              // bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                alignment: Alignment.center,
                child: Text(notificationCount,
                    style: GoogleFonts.poppins(
                      fontSize: 8.0,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
