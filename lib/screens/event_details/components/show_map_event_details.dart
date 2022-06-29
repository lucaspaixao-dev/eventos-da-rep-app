import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../widgets/app_snack_bar.dart';

class ShowMapEventDetails extends StatelessWidget {
  const ShowMapEventDetails({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.title,
  }) : super(key: key);

  final double latitude;
  final double longitude;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ElevatedButton.icon(
        onPressed: () {
          openMapsSheet(context, latitude, longitude, title);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        icon: const Icon(
          Icons.map,
          color: Colors.white,
        ),
        label: const Text(
          "Localização",
        ),
      ),
    );
  }

  openMapsSheet(
    BuildContext context,
    double lat,
    double long,
    String title,
  ) async {
    try {
      final coords = Coords(lat, long);
      final availableMaps = await MapLauncher.installedMaps;

      showMaterialModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Wrap(
                children: <Widget>[
                  for (var map in availableMaps)
                    ListTile(
                      onTap: () => map.showMarker(
                        coords: coords,
                        title: title,
                      ),
                      title: Text(map.mapName),
                      leading: SvgPicture.asset(
                        map.icon,
                        height: 30.0,
                        width: 30.0,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    } catch (_) {
      SnackBar snackBar = buildErrorSnackBar(
          "Ocorreu um erro ao abrir o mapa, tente novamente mais tarde.");
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
