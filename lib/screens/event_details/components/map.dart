import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  final String id;
  final double latitude;
  final double longitude;

  const Map({
    Key? key,
    required this.id,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    final CameraPosition position = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: 14.4746,
    );

    final Marker marker = Marker(
      markerId: MarkerId(widget.id),
      position: LatLng(widget.latitude, widget.longitude),
    );

    Set<Marker> makers = {marker};

    return Scaffold(
      body: GoogleMap(
        markers: makers,
        mapType: MapType.hybrid,
        initialCameraPosition: position,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
