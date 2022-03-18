import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget
{
  static Widget map({
    required Completer<GoogleMapController> controller,
    required currentLocation,
    required polylines, required markers, required initialCameraPosition, required onMapCreated})
  {
    return  GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialCameraPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled:true,
        tiltGesturesEnabled: true,
        compassEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        trafficEnabled: false,
        indoorViewEnabled: true,
        rotateGesturesEnabled: true,
        polylines: Set<Polyline>.of(polylines),
        markers:
        Set<Marker>.of(markers),
        onMapCreated: onMapCreated,

    );

  }

}