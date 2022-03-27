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
  List<String> historicalDates = [];
  List<String> historicalDatesTemp = [];
  List<String> iconurls = [];
  List<String> historicdesc = [];
  List<Map<String, String>> futuredata = [];
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
      await getData();
      getFuturedata();
    } catch (e) {
      print(e);
    }
  }

  Future<void> getData() async {
    String url = 'https://api.openweathermap.org/data/2.5/weather?lat=' +
        currentposition!.latitude.toString() +
        '&lon=' +
        currentposition!.longitude.toString() +
        '&appid=b00a6fcec885b5e53be85ac4d7847543';
    DateTime currentPhoneDate = DateTime.now();
    for (int i = 0; i < 2; i++) {
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

  Future<void> getFuturedata() async {
    await addFutureData(1);
    await addFutureData(2);
    await addFutureData(3);
    await addFutureData(4);
    await addFutureData(5);
    // for (int i = 0; i < 5; i++) {
    //   historicalDates.add(futuredata[i]['dt']!);
    //   historicalDatesTemp.add(futuredata[i]['temp']!);
    //   iconurls.add(futuredata[i]['url']!);
    //   historicdesc.add(futuredata[i]['desc']!);
    // }
    print(historicalDates);
    setState(() {
      
    });
  }

  Future<void> addFutureData(int i) async {
    String urlhistory = 'https://api.openweathermap.org/data/2.5/onecall?lat=' +
        currentposition!.latitude.toString() +
        '&lon=' +
        currentposition!.longitude.toString() +
        '&exclude=minutely,hourly&' +
        '&appid=b00a6fcec885b5e53be85ac4d7847543';
    Response response = await get(Uri.parse(urlhistory));
    Map data = jsonDecode(response.body);
    String date = DateTime.fromMillisecondsSinceEpoch(
                data["daily"][i]["dt"] * 1000)
            .day
            .toString() +
        '  ' +
        DateFormat.MMMM()
            .format(DateTime.fromMillisecondsSinceEpoch(
                data["daily"][i]["dt"] * 1000))
            .toString() +
        '  ' +
        DateFormat('EEEE')
            .format(DateTime.fromMillisecondsSinceEpoch(
                data["daily"][i]["dt"] * 1000))
            .substring(0, 3);
    String desc = data["daily"][i]["weather"][0]["main"];
    String iconcode = data['daily'][i]['weather'][0]['icon'];
    var iconurl = "http://openweathermap.org/img/w/" + iconcode + ".png";
    var hour = DateTime.now().hour;
    // double.parse((data['current']['temp'] - 273).toString())
    //     .toStringAsPrecision(2);
    var temp;
    if (hour >= 5 && hour < 12) {
      temp = data["daily"][i]["temp"]["morn"];
    }
    if (hour >= 12 && hour < 17) {
      temp = data["daily"][i]["temp"]["day"];
    }
    if (hour >= 17 && hour < 21) {
      temp = data["daily"][i]["temp"]["eve"];
    }
    if (hour >= 21 || hour < 5) {
      temp = data["daily"][i]["temp"]["night"];
    }
    futuredata.add(
        {"dt": date, "desc": desc, "url": iconurl, "temp": temp.toString()});
    historicalDates.add(date);
    historicalDatesTemp.add((temp - 273).toStringAsPrecision(2));
    historicdesc.add(desc);
    iconurls.add(iconurl);
    //print(futuredata);
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
        body: historicalDates.length<7
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
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
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
                              Text(
                                'Desc',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              Text('Temp',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ],
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                datetempcolumn(historicalDates),
                                iconcolumn(iconurls, historicdesc),
                                datetempcolumn(historicalDatesTemp)
                              ])
                        ],
                      ),
                    ),
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

  Widget datetempcolumn(List<String> s) {
    print(s);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
       // SizedBox(height: h*0.015,),
        Text(
          s[1],
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        // SizedBox(
        //   height: h*0.012,
        // ),
        Text(
          s[0],
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
        Text(
          s[5],
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        // SizedBox(
        //   height: h*0.012,
        // ),
        Text(
          s[6],
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    );
  }

  Widget iconcolumn(List<String> imageurl, List<String> desc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.network(
              imageurl[1],
              width: 30.0,
              height: 15,
            ),
            Text(
              desc[1],
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.network(
              imageurl[0],
              width: 30.0,
              height: 15,
            ),
            Text(
              desc[0],
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.network(
              imageurl[2],
              width: 30.0,
              height: 15,
            ),
            Text(
              desc[2],
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.network(
              imageurl[3],
              width: 30.0,
              height: 15,
            ),
            Text(
              desc[3],
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.network(
              imageurl[4],
              width: 30.0,
              height: 15,
            ),
            Text(
              desc[4],
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.network(
              imageurl[5],
              width: 30.0,
              height: 15,
            ),
            Text(
              desc[5],
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.network(
              imageurl[6],
              width: 30.0,
              height: 15,
            ),
            Text(
              desc[6],
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            )
          ],
        )
      ],
    );
  }
}
