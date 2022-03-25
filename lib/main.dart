import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
  String temperature = 'Weather';
  String weather = '';
  String city = '';
  String max = '';
  String min = '';
  String apparenttemp = '';
  String humidity = '';
  String windspeed = '';
  String visibility = '';
  String airpressure = '';
  String clouds = '';
  String date = DateTime.now().day.toString() +
      '  ' +
      DateFormat.MMMM().format(DateTime.now()).toString() +
      '  ' +
      DateFormat('EEEE').format(DateTime.now()) +
      '  ';
  var historicalDates = [];
  var historicalDatesTemp = [];
  var iconurls = [];
  var historicdesc = [];
  @override
  void initState() {
    // TODO: implement initState
    _determinePosition();
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
      getData();
    } catch (e) {
      print(e);
    }
  }

  void getData() async {
    String url = 'https://api.openweathermap.org/data/2.5/weather?lat=' +
        currentposition!.latitude.toString() +
        '&lon=' +
        currentposition!.longitude.toString() +
        '&appid=b00a6fcec885b5e53be85ac4d7847543';
    DateTime currentPhoneDate = DateTime.now();
    for (int i = 0; i < 6; i++) {
      Timestamp myTimeStamp =
          Timestamp.fromDate(currentPhoneDate.subtract(Duration(days: i)));
      historicalDatesTemp
          .add(await gethistoricaldata(myTimeStamp.seconds.toString()));
      String date = DateTime.now().subtract(Duration(days: i)).day.toString() +
          '  ' +
          DateFormat.MMMM()
              .format(DateTime.now().subtract(Duration(days: i)))
              .toString() +
          '  ' +
          DateFormat('EEEE')
              .format(DateTime.now().subtract(Duration(days: i)))
              .toString()
              .substring(0, 3);
      // historicalDates.add(DateFormat('dd-MM-yyyy')
      //     .format(DateTime.now().subtract(Duration(days: i)))
      //     .toString());
      historicalDates.add(date);
    }
    // print(historicalDates);
    print(iconurls);
    // print(url);
    Response response = await get(Uri.parse(url));
    Map data = jsonDecode(response.body);
    String temp = double.parse((data['main']['temp'] - 273).toString())
        .toStringAsPrecision(2);
    String weathero = (data['weather'][0]['main']).toString();
    String maxo = double.parse((data['main']['temp_max'] - 273).toString())
        .toStringAsPrecision(2);
    String mino = double.parse((data['main']['temp_min'] - 273).toString())
        .toStringAsPrecision(2);
    String apparenttempo =
        double.parse((data['main']['feels_like'] - 273).toString())
            .toStringAsPrecision(2);
    String humidityo =
        double.parse((data['main']['humidity']).toString()).toString();
    String airpressureo =
        double.parse((data['main']['pressure']).toString()).toString();
    String visibilityo =
        double.parse((data['visibility'] / 1000).toString()).toString();

    String windspeedo =
        double.parse((data['wind']['speed']).toString()).toString();
    String cloudso =
        double.parse((data['clouds']['all']).toString()).toString();
    print(temp);

    // print(DateTime.fromMillisecondsSinceEpoch(1647960048 * 1000));
    // print(DateTime.fromMillisecondsSinceEpoch(1648065600 * 1000));
    // print(DateTime.fromMillisecondsSinceEpoch(1648152000 * 1000));

    setState(() {
      temperature = temp;
      weather = weathero;
      max = maxo;
      min = mino;
      apparenttemp = apparenttempo;
      windspeed = windspeedo;
      humidity = humidityo;
      airpressure = airpressureo;
      visibility = visibilityo;
      clouds = cloudso;
    });
  }

  Future<String> gethistoricaldata(String timestamp) async {
    String urlhistory =
        'https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=' +
            currentposition!.latitude.toString() +
            '&lon=' +
            currentposition!.longitude.toString() +
            '&dt=' +
            timestamp +
            '&appid=b00a6fcec885b5e53be85ac4d7847543';

    print(urlhistory);
    Response response = await get(Uri.parse(urlhistory));
    Map data = jsonDecode(response.body);
    String temp = double.parse((data['current']['temp'] - 273).toString())
        .toStringAsPrecision(2);
    String iconcode = data['current']['weather'][0]['icon'];
    var iconurl = "http://openweathermap.org/img/w/" + iconcode + ".png";
    iconurls.add(iconurl);
    String weather = data['current']['weather'][0]['main'];
    historicdesc.add(weather);
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    h = size.height;
    w = size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            city,
            style: TextStyle(letterSpacing: 2, color: Colors.white),
          ),
        ),
        body: weather == ''
            ? Center(child: CircularProgressIndicator())
            : Container(
                padding: EdgeInsets.only(left: w * 0.02),
                child: ListView(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: h * 0.1,
                    ),
                    Row(
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          temperature,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 60),
                        ),
                        SizedBox(
                          width: w * 0.02,
                        ),
                        Column(
                          children: [
                            Text(
                              '\u2103 ',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              height: h * 0.01,
                            ),
                            Text(
                              weather,
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: h * 0.01,
                    ),
                    Row(
                      children: [
                        Text(
                          date,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(max + '\u2103 ' + ' / ' + min + '\u2103 ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13))
                      ],
                    ),
                    SizedBox(
                      height: h * 0.03,
                    ),
                    Container(
                      height: h * 0.1,
                      width: w * 0.5,
                      child: const Divider(
                        thickness: 2, // thickness of the line
                        indent:
                            20, // empty space to the leading edge of divider.
                        endIndent:
                            20, // empty space to the trailing edge of the divider.
                        color: Colors
                            .black, // The color to use when painting the line.
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'DATE',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            Text(
                              'Desc',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            Text('Temp',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                    datetemp(historicalDatesTemp[1], historicalDates[1],
                        historicdesc[1], iconurls[1]),
                    datetemp(historicalDatesTemp[0], historicalDates[0],
                        historicdesc[0], iconurls[0]),
                    Text(
                      'Weather details',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: h * 0.03,
                    ),
                    Container(
                      width: w - w * 0.03,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          details(
                              'Apparent temperature', apparenttemp + '\u2103 '),
                          SizedBox(
                            width: w * 0.1,
                          ),
                          details('Humidity', humidity + ' %'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: h * 0.03,
                    ),
                    Container(
                      width: w - w * 0.03,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          details('Visibility', visibility + ' km '),
                          SizedBox(
                            width: w * 0.3,
                          ),
                          details('Air Pressure', airpressure + ' hPa '),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: h * 0.03,
                    ),
                    Container(
                      width: w - w * 0.03,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          details('Wind speed', windspeed + ' m/s'),
                          SizedBox(
                            width: w * 0.3,
                          ),
                          details('Cloudiness', clouds + ' % '),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }

  Widget details(String title, String contents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
        ),
        SizedBox(
          height: h * 0.01,
        ),
        Text(contents,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25))
      ],
    );
  }

  Widget datetemp(String temp, String date, String desc, String iconurl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          date,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        SizedBox(
          width: w * 0.17,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.network(
              iconurl,
              width: 30.0,
              height: 30,
            ),
            Text(
              desc,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            )
          ],
        ),
        SizedBox(
          width: w * 0.31,
        ),
        Text(temp, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15))
      ],
    );
  }
}
