import 'package:flutter/material.dart';

class PopularEventTile extends StatefulWidget {
  final String desc;
  final String date;
  final String address;
  final String imgeAssetPath;

  const PopularEventTile({
    Key? key,
    required this.address,
    required this.date,
    required this.imgeAssetPath,
    required this.desc,
  }) : super(key: key);

  @override
  State<PopularEventTile> createState() => _PopularEventTileState();
}

class _PopularEventTileState extends State<PopularEventTile> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xff29404E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 16),
              width: MediaQuery.of(context).size.width - 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: mediaQuery.size.width * 0.50,
                    child: Text(
                      widget.desc,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.calendar_month,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        widget.date,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      SizedBox(
                        width: mediaQuery.size.width * 0.35,
                        child: Text(
                          widget.address,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
              child: Image.network(
                widget.imgeAssetPath,
                height: 100,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
