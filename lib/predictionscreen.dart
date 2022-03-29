import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PredictionScreen extends StatefulWidget {
  List<Map<String, String>> prediction = [];
  PredictionScreen(List<Map<String, String>> prediction) {
    this.prediction = prediction;
  }
  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  double h = 0.0, w = 0.0;
  List<String> months = [
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec'
  ];
  String currentAddress = 'My Address';
  Position? currentposition;
  List<String> predictiondates = [];
  List<String> predictedtemperatures = [];
  String city = '';
  @override
  void initState() {
    // TODO: implement initState
    _determinePosition();
    dateformatting();
    tempformatting();
    super.initState();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Please enable Your Location Service');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(Position);
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      setState(() {
        currentposition = position;
        currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
        city = place.locality.toString();
      });
    } catch (e) {
      print(e);
    }
  }

  void dateformatting() {
    for (int i = 0; i < widget.prediction.length; i++) {
      String date = DateTime.parse(widget.prediction[i]['date']!).day.toString() +
          '  ' +
          DateFormat.MMMM().format(DateTime.parse(widget.prediction[i]['date']!)).toString() +
          '  ' +
          DateFormat('EEEE')
              .format(DateTime.parse(widget.prediction[i]['date']!))
              .toString()
              .substring(0, 3);
      predictiondates.add(date);
    }
    print(predictiondates);
  }

  void tempformatting() {
    for (int i = 0; i < widget.prediction.length; i++) {
      String temp = double.parse(widget.prediction[i]['temperature']!).toStringAsFixed(2);
      predictedtemperatures.add(temp);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    h = size.height;
    w = size.width;
    return predictedtemperatures.length == 0
        ? CircularProgressIndicator()
        : Scaffold(
            appBar: AppBar(
              title: Text(
                city + '  Prediction',
                style: TextStyle(letterSpacing: 2, color: Colors.white),
              ),
            ),
            body: Padding(
              padding:  EdgeInsets.only(right:w*0.1,left: w*0.1),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      SizedBox(
                        width: w * 0.05,
                      ),
                      Text('Temp',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        datetempcolumn(predictiondates),
                        datetempcolumn(predictedtemperatures)
                      ])
                ],
              ),
            ),
          );
  }

  Widget datetempcolumn(List<String> s) {
    print(s);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // SizedBox(height: h*0.015,),
        Text(
          s[0],
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        // SizedBox(
        //   height: h*0.012,
        // ),
        Text(
          s[1],
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        // SizedBox(
        //   height: h*0.012,
        // ),
        Text(
          s[2],
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        // SizedBox(
        //   height: h*0.012,
        // ),
        Text(
          s[3],
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        // SizedBox(
        //   height: h*0.012,
        // ),
        Text(
          s[4],
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        // SizedBox(
        //   height: h*0.012,
        // ),
        
        // SizedBox(
        //   height: h*0.012,
        // ),
        
      ],
    );
  }
}
