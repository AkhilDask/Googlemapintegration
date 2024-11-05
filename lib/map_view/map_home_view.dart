import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemapdemo/bloc/map_controller_bloc.dart';

class MapHomeView extends StatefulWidget {
  @override
  State<MapHomeView> createState() => _MapHomeViewState();
}

class _MapHomeViewState extends State<MapHomeView> {
  late GoogleMapController _mapController;
  LatLng? initialPosition;
  bool init = true;

  String? PUthroughFare, PUsubLocality, PUlocality, PUadministrativeArea;
  String? DOthroughFare, DOsubLocality, DOlocality, DOadministrativeArea;
  var distanceBetween;
  //StreamController<LatLng> streamController = StreamController();

  getCurrentLoc() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    if (mapControllerBloc.custmomerLatLng == null) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      initialPosition = LatLng(position.latitude, position.longitude);
      //streamController.add(initialPosition as LatLng);
      mapControllerBloc.updateCustomerPosition(initialPosition);
    } else {
      initialPosition = mapControllerBloc.custmomerLatLng;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initMethod();
  }

  initMethod() async {
    await getCurrentLoc();
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
    //streamController.close();
  }

  _getAddressFromLatLng(LatLng value, BuildContext context) async {
    final position = await GeolocatorPlatform.instance.getCurrentPosition();

    await placemarkFromCoordinates(mapControllerBloc.custmomerLatLng!.latitude,
            mapControllerBloc.custmomerLatLng!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];

      setState(() {
        PUthroughFare = place.thoroughfare;
        PUsubLocality = place.subLocality;
        PUlocality = place.locality;
        PUadministrativeArea =
            "${place.administrativeArea} , ${place.postalCode}";
      });
    }).catchError((e) {
      debugPrint(e);
    });

    await placemarkFromCoordinates(position.latitude, position.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];

      setState(() {
        DOthroughFare = place.thoroughfare;
        DOsubLocality = place.subLocality;
        DOlocality = place.locality;
        DOadministrativeArea =
            "${place.administrativeArea} , ${place.postalCode}";
        distanceBetween = (Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            mapControllerBloc.custmomerLatLng!.latitude,
            mapControllerBloc.custmomerLatLng!.longitude))/1000;
      });
    }).catchError((e) {
      debugPrint(e);
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        Size size = MediaQuery.of(context).size;
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 56, 198, 122),
          content: SizedBox(
            height: size.height * 0.2,
            width: size.width * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.25,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DROP OFF',
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(
                              width: size.width * 0.3,
                              child: Text(
                                "${PUthroughFare == null ? "" : "$PUthroughFare"} ${PUsubLocality == null ? "" : "$PUsubLocality,"} ${PUlocality == null ? "" : "$PUlocality,"} ${PUadministrativeArea == null ? "" : "$PUadministrativeArea,"}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 2),
                    SizedBox(
                      width: size.width * 0.25,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                              padding: EdgeInsets.only(left: 2),
                              child: Text('PICK UP',
                                  style: TextStyle(color: Colors.black))),
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: SizedBox(
                                width: size.width * 0.3,
                                child: Text(
                                  "${DOthroughFare == null ? "" : "$DOthroughFare"} ${DOsubLocality == null ? "" : "$DOsubLocality"} ${DOlocality == null ? "" : "$DOlocality,"} ${DOadministrativeArea == null ? "" : "$DOadministrativeArea,"}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white),
                                )),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Total Distance',
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  '$distanceBetween KM',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close', style: TextStyle(color: Colors.red),))
          ],
        );
      },
    );
  }

  Widget renderMap() {
    return SizedBox(
      child: GoogleMap(
        zoomControlsEnabled: false,
        myLocationEnabled: true,
        buildingsEnabled: true,
        indoorViewEnabled: false,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        onTap: (value) {
          _getAddressFromLatLng(value, context);
        },
        onCameraMove: (CameraPosition pos) {
          //streamController.add(pos.target);
          mapControllerBloc.updateCustomerPosition(pos.target);
        },
        initialCameraPosition: CameraPosition(
          target: initialPosition!,
          zoom: 14.4746,
        ),
        mapType: MapType.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: mapControllerBloc.getCustomerLatLng,
          initialData: mapControllerBloc.custmomerLatLng,
          builder: (context, snapshot) {
            if (mapControllerBloc.custmomerLatLng != null) {
              return Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        renderMap(),
                        const Positioned(child: Icon(Icons.pin_drop)),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Card(
                              color: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.2))),
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(25, 8, 25, 8),
                                child: Text(
                                  'Latitude ${mapControllerBloc.custmomerLatLng?.latitude}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              )),
                          const SizedBox(height: 10),
                          Card(
                            color: Colors.amber,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: Colors.blueAccent.withOpacity(0.2))),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(25, 8, 25, 8),
                              child: Text(
                                'Longitude ${mapControllerBloc.custmomerLatLng?.longitude}',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                        ],
                      ))
                ],
              );
            } else {
              return Container();
            }
          }),
    );
  }
}
