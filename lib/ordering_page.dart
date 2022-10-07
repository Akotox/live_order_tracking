import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_location_tracking/constants.dart';
import 'package:location/location.dart';

class OrderTackingPage extends StatefulWidget {
  const OrderTackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTackingPage> createState() => _OrderTackingPageState();
}

class _OrderTackingPageState extends State<OrderTackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng source = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.066055);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;
    });

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLocation) {
      currentLocation = newLocation;

      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 13.5,
            target: LatLng(newLocation.latitude!, newLocation.longitude!),
          ),
        ),
      );

      setState(() {});
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(source.latitude, source.longitude),
        PointLatLng(destination.latitude, destination.longitude));
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  void setCustomMarkerIcon(){
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/icons/sourceloc.png").then((icon){
      sourceIcon = icon;
    });
     BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/icons/destinationloc.png").then((icon){
      destinationIcon = icon;
    });
     BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/icons/userloc.png").then((icon){
      currentLocationIcon = icon;
    });

  }

  @override
  void initState() {
    getPolyPoints();
    getCurrentLocation();
    setCustomMarkerIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Track Order',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ),
      body: currentLocation == null
          ? const Text('loading')
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 13.5),
              polylines: {
                Polyline(
                    polylineId: PolylineId('route'),
                    points: polylineCoordinates,
                    color: primaryColor,
                    width: 6),
              },
              markers: {
                 Marker(
                  markerId: const MarkerId('source'),
                  icon: sourceIcon,
                  position: source,
                ),
                 Marker(
                  markerId: const MarkerId('destination'),
                  icon: destinationIcon,
                  position: destination,
                ),
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  icon: currentLocationIcon,
                  position: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                )
              },
              onMapCreated: (mapController) {
                _controller.complete(mapController);
              },
            ),
    );
  }
}
