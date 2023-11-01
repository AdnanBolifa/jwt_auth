import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_auth/data/location_config.dart';
import 'package:jwt_auth/data/ticket_config.dart';
import 'package:jwt_auth/screens/ticket_page.dart';
import 'package:jwt_auth/services/api_service.dart';
import 'package:jwt_auth/services/location_services.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  const TicketCard({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MaterialColor inProgress = Colors.green;
    MaterialColor idle = Colors.red;
    MaterialColor closed = Colors.grey;

    final LocationService locationService = LocationService();
    LocationData? locationData;
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                decoration: ticket.status == 'notstarted'
                    ? BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      )
                    : BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ticket.acc!} - ${ticket.userName}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    Text(
                      ticket.mobile,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    Text(
                      "[${ticket.createdAt!}]",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'المكان:  ${ticket.place!}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                      textDirection: TextDirection.ltr,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      ticket.lastComment!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              shape: BoxShape.rectangle,
                            ),
                            child: ElevatedButton(
                              onPressed: ticket.status == 'notstarted'
                                  ? () {
                                      final snackBar = SnackBar(
                                        content: Row(
                                          children: [
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              onTap: () {
                                                ScaffoldMessenger.of(context)
                                                    .hideCurrentSnackBar();
                                              },
                                              child: const Icon(
                                                Icons.close, // Close icon
                                                color: Colors.white,
                                              ),
                                            ),
                                            SnackBarAction(
                                              label: 'نعم',
                                              onPressed: () async {
                                                locationData =
                                                    await locationService
                                                        .getUserLocation();
                                                ApiService().startTimer(
                                                    locationData!, ticket.id);
                                                if (context.mounted) {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddTicket(
                                                              ticket: ticket),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                            const Expanded(
                                              child: Text(
                                                'هل انت متأكد من بدأ المهمة؟',
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                  : () {
                                      Fluttertoast.showToast(
                                          msg: 'هذه المهمة قد بدأت بالفعل');
                                    },
                              child: const Text(
                                'بدأ المهمة الان',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        //Call button
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.grey[300],
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      _makePhoneCall(ticket.mobile);
                                    },
                                    icon: const Icon(
                                      Icons.phone,
                                      size: 30,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 15,
              right: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ticket.status == 'inprogress'
                      ? inProgress
                      : (ticket.status == 'notstarted' ? idle : closed),
                ),
              ),
            ),
          ],
        ));
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
