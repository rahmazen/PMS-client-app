import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api.dart';

class ServicesPage extends StatefulWidget {
  final dynamic service;

  const ServicesPage({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: widget.service != null
            ?
        Column(
          children: [
            Stack(
              children: [
                // Image container
                Container(
                  height: 450,
                  width: double.infinity,
                  child: Image.network(
                    '${Api.url}${widget.service['image']}',
                    fit: BoxFit.cover,
                  ),
                ),
                // Back button positioned on top of the image
                Positioned(
                  top: 40,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.blueGrey[600],
                          size: 15
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10.0),

            // Service details section
            Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Text(
                    widget.service['subtitle'],
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.blueGrey[800],
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    widget.service['title'],
                    style: GoogleFonts.playfair(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),

                  const SizedBox(height: 12.0),

                  Text(
                    widget.service['description'],
                    style: GoogleFonts.nunito(
                      fontSize: 14.0,
                      color: Colors.blueGrey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16.0),
            //const Divider(),
          ],
        ) :Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 70,
                color: Colors.blueGrey[300],
              ),
              SizedBox(height: 20),
              Text(
                "Informations about this service are not available for the moment .",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[600],
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  "back to home",
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),






    );
  }
}
