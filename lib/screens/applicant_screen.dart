import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_guild_for_jobseekers_v3/utils/connection_status.dart';

class ApplicantScreen extends StatefulWidget {
  final String profilePic;
  final String email;
  final String name;
  final String description;
  final int mobileNumber;
  final String address;
  final String date;
  String? resumeFile;

  ApplicantScreen({
    super.key,
    required this.profilePic,
    required this.email,
    required this.name,
    required this.description,
    required this.mobileNumber,
    required this.address,
    required this.date,
    this.resumeFile,
  });

  @override
  State<ApplicantScreen> createState() => _ApplicantScreenState();
}

class _ApplicantScreenState extends State<ApplicantScreen> {
  @override
  Widget build(BuildContext context) {
    Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(
      int.parse(widget.date.split('=')[1].split(',')[0]) * 1000 +
          (int.parse(widget.date.split('=')[2].split(')')[0]) / 1000).round(),
    );
    DateTime dateTime = timestamp.toDate();

    int daysPassed = DateTime.now().difference(dateTime).inDays;
    String displayDate = DateFormat('yyyy-MM-dd').format(dateTime);
    String displayText = daysPassed == 0 ? 'New' : '$daysPassed days ago';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Applicant Screen"),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              // image: DecorationImage(
              //   image: AssetImage("assets/background.png"),
              //   fit: BoxFit.fill,
              // ),
              gradient: LinearGradient(
                colors: [
                  Colors.yellow.withOpacity(0.5),
                  Colors.blue.withOpacity(0.5),
                ],
                stops: const [0.4, 1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.blue,
                                Colors.yellow,
                              ],
                              stops: [0.4, 1],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: const Offset(3, 6),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: const Offset(-3, -6),
                              ),
                            ],
                          ),
                          width: double.maxFinite,
                          margin: const EdgeInsets.only(
                            right: 10.0,
                            left: 10.0,
                            top: 30.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const SizedBox(height: 60.0),
                              const Center(
                                child: Text(
                                  "Applicant's Information:",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const SizedBox(height: 15.0),
                                    Text("Name : ${widget.name}"),
                                    const SizedBox(height: 5.0),
                                    Text("Email: ${widget.email}"),
                                    const SizedBox(height: 5.0),
                                    Text(
                                        "Mobile Number : 0${widget.mobileNumber}"),
                                    const SizedBox(height: 5.0),
                                    Text("Address : ${widget.address}"),
                                    const SizedBox(height: 5.0),
                                    widget.resumeFile == ""
                                        ? Column(
                                            children: [
                                              Text(
                                                  "Description : ${widget.description}"),
                                              const SizedBox(height: 5.0),
                                            ],
                                          )
                                        : const SizedBox(),
                                    Text("Upload Time : $displayText"),
                                    const SizedBox(height: 15.0),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        ConnectionStatus
                                                .checkInternetConnection()
                                            .then(
                                          (value) {
                                            if (value ==
                                                ConnectivityResult.none) {
                                              ConnectionStatus
                                                  .showInternetError(context);
                                            } else {
                                              context.pushNamed(
                                                "pdfscreen",
                                                queryParams: {
                                                  "jobFile": widget.resumeFile!,
                                                },
                                              );
                                            }
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.article_outlined),
                                      label: const Text("More Details"),
                                    ),
                                    const SizedBox(height: 15.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: const Offset(3, 6),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: const Offset(-2, -3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: widget.profilePic,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error, size: 45),
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
