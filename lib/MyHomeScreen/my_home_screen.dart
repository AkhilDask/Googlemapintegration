import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MYHomeScreen extends StatefulWidget {
  @override
  State<MYHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MYHomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  List<Marker> myMarker = [];
  List<Marker> markerList = [
    const Marker(
        markerId: MarkerId('First'),
        position: LatLng(10.779162635869556, 76.65382888137789),
        infoWindow: InfoWindow(title: 'My Position'))
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myMarker.addAll(markerList);
  }

  static const CameraPosition _initialPosition = CameraPosition(
      target: LatLng(10.779162635869556, 76.65382888137789), zoom: 14);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: GoogleMap(
        initialCameraPosition: _initialPosition,
        markers: Set<Marker>.of(myMarker),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      )),
      floatingActionButton: FloatingActionButton(onPressed: () async {
        getaddressFromLatLong();
        GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(
            const CameraPosition(
                target: LatLng(10.7497066572638, 76.7388508930179), zoom: 14)));
      }),
    );
  }

  getaddressFromLatLong() async {
    List<Placemark> placemarkdata =
        await placemarkFromCoordinates(10.739477276137677, 76.6478704083615);
    print(
        'Address Data : ${placemarkdata.reversed.last.country},${placemarkdata.reversed.last.locality} ');
  }
}
