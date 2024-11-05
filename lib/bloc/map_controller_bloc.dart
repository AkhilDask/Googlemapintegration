  
  
 import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapControllerBloc{ 
  
  LatLng? custmomerLatLng;

  final customerPositionController = StreamController<LatLng>.broadcast();
  Stream get getCustomerLatLng => customerPositionController.stream;

  updateCustomerPosition(LatLng? position) {
    if (
        //custmomerLatLng != null &&
        position != null) {
      custmomerLatLng = position;

      customerPositionController.sink.add(custmomerLatLng!);
    }
  }
 }

 final mapControllerBloc = MapControllerBloc();