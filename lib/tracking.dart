library tracking;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:tracking/map_widget.dart';


class Tracking extends StatefulWidget {
   Tracking(
      {
    Key? key,
    required this.height,
        required this.width,
    this.controllerForGoogleMap,
    required this.markers,
    this.title = "Title",
    this.textColor,
    this.subtitle = "Subtitle",
    this.subtitleColor,
    required this.destLatitude,
    required this.destLongitude,
    required this.polylinePoints,
    required this.apiKey,
    required this.polylines,
    required this.sourceIcon,
    required this.subscription,
    required this.destinationIcon,
    required this.currentLocation,
    required this.destinationLocation,
    required this.location,

    // this.onTap,
    this.padding,
    this.titleStyle,
    this.subtitleStyle,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Completer<GoogleMapController> ? controllerForGoogleMap;
  final Map<MarkerId, Marker> markers;
  final double destLatitude;
  final PolylinePoints polylinePoints ;
  final double destLongitude;
  final dynamic apiKey;
   String title;
   BitmapDescriptor? sourceIcon;
   late Location location;

   BitmapDescriptor destinationIcon;
  final Color? textColor;
  final   Map<PolylineId, Polyline> polylines;
   late LocationData destinationLocation;

  final String subtitle;
   StreamSubscription<LocationData> subscription;
   LocationData? currentLocation;

  final Color? subtitleColor;
  // final FancyContainersCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  @override
  State<Tracking> createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> with SingleTickerProviderStateMixin, WidgetsBindingObserver{






  onMapCreated(GoogleMapController controller) {

    widget.controllerForGoogleMap?.complete(controller);
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
              southwest: LatLng(
                  widget.currentLocation!.latitude! <= widget.destLatitude
                      ? widget.currentLocation?.latitude??1.0
                      : widget.destLatitude,
                  widget.currentLocation!.longitude! <= widget.destLongitude
                      ? widget.currentLocation?.latitude??1.0
                      : widget.destLongitude),
              northeast: LatLng(
                  widget.currentLocation!.latitude!  <= widget.destLatitude
                      ? widget.destLatitude
                      : widget.currentLocation!.latitude! ,
                  widget.currentLocation!.longitude! <= widget.destLongitude
                      ? widget.destLongitude
                      : widget.currentLocation!.longitude! )),100),
    );
    setMapPins();
    getPolyline();
    // controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(currentLocation?.latitude ?? 0.0,
    //   currentLocation?.longitude ?? 0.0,), 14));

  }

  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        points: polylineCoordinates,
        width: 4,
        geodesic: true,
        color: Colors.red);
    widget.polylines[id] = polyline;

    setState(() {

    });
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    // widget.controllerForEnrouteScreen = Completer();
    widget.location = Location();
    setSourceAndDestinationIcons();
    widget.subscription =
        widget.location.onLocationChanged.listen((clocation) {
          widget.currentLocation = clocation;
          setMapPins();
          getPolyline();
          // sendLatLongToFirebase(location: "location");
        });

    super.initState();
  }
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
  
  void getPolyline() async {

    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await widget.polylinePoints.getRouteBetweenCoordinates(
      widget.apiKey,
      PointLatLng(widget.currentLocation?.latitude??1.0, widget.currentLocation?.longitude??1.0),
      PointLatLng(widget.destLatitude, widget.destLongitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      debugPrint(result.errorMessage);
    }
    _addPolyLine(polylineCoordinates);
  }
  // Future<void> sendLatLongToFirebase({required location}) async {
  //   await FirebaseFirestore.instance
  //       .collection('$location')
  //       .doc("${PreferenceUtils.getString(Strings.loginUserId)}")
  //       .set({
  //     "latitude": currentLocation?.latitude,
  //     "longitude": currentLocation?.longitude,
  //     "name": "${PreferenceUtils.getString(Strings.loginName)}"
  //   });
  // }

  Future<void> setSourceAndDestinationIcons() async {
    // sourceIcon = await BitmapDescriptor.fromAssetImage(
    //     const ImageConfiguration(devicePixelRatio: 2.5), Assets.redMarker);
    widget.destinationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5), "assets/png/map_component1.png");
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {

    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    widget.markers[markerId] = marker;

  }
  setMapPins() {
    widget.markers.clear();
    // _addMarker(
    //   LatLng(currentLocation?.latitude??1.0, currentLocation?.longitude??1.0),
    //   "origin",
    //   sourceIcon!,
    // );
    _addMarker(
      LatLng(widget.destLatitude,widget.destLongitude),
      "destination",
      widget.destinationIcon,
    );
    setState(() {

    });
  }


  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        print('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        if(mounted) setState(() {});
        print('appLifeCycleState resumed');
        break;
      case AppLifecycleState.paused:
        print('appLifeCycleState paused');
        break;
      case AppLifecycleState.detached:

        print('appLifeCycleState detached');
        break;
    }
  }
  
  
  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
      zoom: 12,
      tilt: 40,
      bearing: 20,
      target: widget.currentLocation != null
          ? LatLng(widget.currentLocation?.latitude ?? 0.0,
        widget.currentLocation?.longitude ?? 0.0,)
          : const LatLng(0.0, 0.0),
    );

    return widget.currentLocation == null
        ? Container(
      color: Colors.white,
      height: widget.height,
      width: widget.width,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    )
        : WillPopScope(
      onWillPop: () async => false,
      // onWillPop: () async => isRideStartApiHit!,
      child: SafeArea(
          child: Scaffold(
            body: SizedBox(
                height: widget.height,
                width: widget.width,
                child: MapWidget.map(
                    controller:widget.controllerForGoogleMap!,
                    polylines: widget.polylines.values,
                    markers: widget.markers.values,
                    // circles: circles,
                    initialCameraPosition: initialCameraPosition,
                    onMapCreated: onMapCreated,
                    currentLocation: true
                ),),
          )),
    );
  }
}
