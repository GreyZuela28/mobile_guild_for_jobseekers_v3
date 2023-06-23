import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_guild_for_jobseekers_v3/utils/connection_status.dart';
import 'package:uuid/uuid.dart';

class ListOfApplicantsScreen extends StatefulWidget {
  final String jobId;
  const ListOfApplicantsScreen({
    super.key,
    required this.jobId,
  });

  @override
  State<ListOfApplicantsScreen> createState() => _ListOfApplicantsScreenState();
}

class _ListOfApplicantsScreenState extends State<ListOfApplicantsScreen> {
  DateTime now = DateTime.now();
  // Create a new instance of the UUID class
  var uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Applicants"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("jobs")
            .doc(widget.jobId)
            .collection("applicants")
            .orderBy("name")
            // .orderBy("date", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.size == 0) {
            return const Center(
              child: Text('No Applicant'),
            );
          }

          if (snapshot.hasData) {
            return ListView.separated(
              padding: const EdgeInsets.only(top: 10, right: 5, left: 5),
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemBuilder: (BuildContext context, int index) {
                final document = snapshot.data!.docs.elementAt(index).data();
                DateTime documentDate = document['date'].toDate();
                int daysPassed = now.difference(documentDate).inDays;
                String displayDate =
                    DateFormat('yyyy-MM-dd').format(documentDate);
                String displayText =
                    daysPassed == 0 ? 'New' : '$daysPassed days ago';
                return ListTile(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () {
                    context.pushNamed("applicant", queryParams: {
                      "profilePic": document["profilePic"],
                      "email": document["email"],
                      "name": document["name"],
                      "description": document["description"],
                      "mobileNumber": document["mobileNumber"].toString(),
                      "address": document["address"],
                      "date": document["date"].toString(),
                      "resumeFile": document["resumeFile"],
                    });
                  },
                  splashColor: Colors.grey[300],
                  tileColor: Colors.amberAccent,
                  leading: CircleAvatar(
                    radius: 25,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: document["profilePic"],
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, size: 45),
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                  // leading: const Icon(Icons.people),
                  title: Text(document["name"]),
                  subtitle: Text(document["address"]),
                  trailing: PopupMenuButton(
                    onSelected: (index) {},
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          onTap: () {
                            //start an online meet
                            ConnectionStatus.checkInternetConnection()
                                .then((value) {
                              if (value == ConnectivityResult.none) {
                                ConnectionStatus.showInternetError(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Start Online Meet"),
                                  ),
                                );
                              }
                            });
                          },
                          value: 0,
                          child: Row(
                            children: const [
                              Icon(Icons.meeting_room_rounded),
                              SizedBox(width: 8.0),
                              Text("Start Meet"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            //Send notification to the applicant
                            ConnectionStatus.checkInternetConnection()
                                .then((value) {
                              if (value == ConnectivityResult.none) {
                                ConnectionStatus.showInternetError(context);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Column(
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.check_outlined),
                                              SizedBox(width: 5.0),
                                              Text(
                                                "Confirmation",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 1,
                                            margin: const EdgeInsets.only(
                                                top: 10, bottom: 20),
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                      content: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                              "Are you sure to hire this applicant?"),
                                          const SizedBox(height: 10),
                                          Container(
                                            height: 1,
                                            margin: const EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            // Add your action here

                                            var newDocument = uuid.v1();

                                            DocumentSnapshot job =
                                                await FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                    .collection("jobs")
                                                    .doc(widget.jobId)
                                                    .get();
                                            // ignore: unnecessary_null_comparison

                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(document["id"])
                                                .collection("notification")
                                                .doc(newDocument)
                                                .set({
                                              "notificationId": newDocument,
                                              "profilePic": job["profilePic"],
                                              "name": job["employer"],
                                              "jobTitle": job["jobTitle"],
                                              "description":
                                                  "Congratulations!, You have been hired",
                                              "date": DateTime.now(),
                                            });

                                            // ignore: use_build_context_synchronously
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text("Hired!"),
                                              ),
                                            );
                                            // ignore: use_build_context_synchronously
                                            context.pop();
                                          },
                                          child: const Text("OK"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context.pop();
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                      ],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 0),
                                      buttonPadding: const EdgeInsets.all(10),
                                      backgroundColor: Colors.white,
                                      elevation: 5,
                                      semanticLabel: "Alert dialog",
                                    );
                                  },
                                );
                              }
                            });
                          },
                          value: 1,
                          child: Row(
                            children: const [
                              Icon(Icons.approval_outlined),
                              SizedBox(width: 8.0),
                              Text("Hire"),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            ConnectionStatus.checkInternetConnection()
                                .then((value) {
                              if (value == ConnectivityResult.none) {
                                ConnectionStatus.showInternetError(context);
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Column(
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.warning_outlined),
                                              SizedBox(width: 5.0),
                                              Text(
                                                "Warning",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 1,
                                            margin: const EdgeInsets.only(
                                                top: 10, bottom: 20),
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                      content: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                              "Are you sure to delete this applicant?"),
                                          const SizedBox(height: 10),
                                          Container(
                                            height: 1,
                                            margin: const EdgeInsets.only(
                                                top: 10, bottom: 10),
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            FirebaseFirestore.instance
                                                .collection("users")
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .collection("jobs")
                                                .doc(widget.jobId)
                                                .collection("applicants")
                                                .doc(document["email"])
                                                .delete();

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text("Applicant deleted"),
                                              ),
                                            );
                                            context.pop();
                                          },
                                          child: const Text("OK"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            context.pop();
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                      ],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 0),
                                      buttonPadding: const EdgeInsets.all(10),
                                      backgroundColor: Colors.white,
                                      elevation: 5,
                                      semanticLabel: "Alert dialog",
                                    );
                                  },
                                );
                              }
                            });
                          },
                          value: 2,
                          child: Row(
                            children: const [
                              Icon(Icons.delete_outline, color: Colors.red),
                              SizedBox(width: 8.0),
                              Text("delete",
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                  // trailing: Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     Text(displayText),
                  //     IconButton(
                  //       onPressed: () {
                  //         showDialog(
                  //           context: context,
                  //           builder: (BuildContext context) {
                  //             return Dialog(
                  //               child: Column(
                  //                 mainAxisSize: MainAxisSize.min,
                  //                 children: [
                  //                   ListView(
                  //                     padding: const EdgeInsets.all(10),
                  //                     shrinkWrap: true,
                  //                     children: [
                  //                       const SizedBox(height: 8),
                  //                       ElevatedButton.icon(
                  //                         onPressed: () {
                  //                           //start an online meet

                  //                           ScaffoldMessenger.of(context)
                  //                               .showSnackBar(
                  //                             const SnackBar(
                  //                               content:
                  //                                   Text("Start Online Meet"),
                  //                             ),
                  //                           );
                  //                           context.pop();
                  //                         },
                  //                         icon:
                  //                             Icon(Icons.meeting_room_rounded),
                  //                         label: Text("Start Meet"),
                  //                         style: ElevatedButton.styleFrom(
                  //                           padding: EdgeInsets.all(20),
                  //                         ),
                  //                       ),
                  //                       const SizedBox(height: 8),
                  //                       ElevatedButton.icon(
                  //                         onPressed: () {
                  //                           //Send notification to the applicant

                  //                           ScaffoldMessenger.of(context)
                  //                               .showSnackBar(
                  //                             const SnackBar(
                  //                               content: Text("Hired!"),
                  //                             ),
                  //                           );
                  //                           context.pop();
                  //                         },
                  //                         icon: Icon(Icons.approval_outlined),
                  //                         label: Text("Hire"),
                  //                         style: ElevatedButton.styleFrom(
                  //                           padding: EdgeInsets.all(20),
                  //                         ),
                  //                       ),
                  //                       const SizedBox(height: 8),
                  //                       ElevatedButton.icon(
                  //                         onPressed: () {
                  //                           // Handle button tap
                  //                           FirebaseFirestore.instance
                  //                               .collection("users")
                  //                               .doc(FirebaseAuth
                  //                                   .instance.currentUser!.uid)
                  //                               .collection("jobs")
                  //                               .doc(widget.jobId)
                  //                               .collection("applicants")
                  //                               .doc(document["email"])
                  //                               .delete();

                  //                           ScaffoldMessenger.of(context)
                  //                               .showSnackBar(
                  //                             const SnackBar(
                  //                               content:
                  //                                   Text("Applicant deleted"),
                  //                             ),
                  //                           );
                  //                           context.pop();
                  //                         },
                  //                         icon: Icon(Icons.delete_outline),
                  //                         label: Text("delete"),
                  //                         style: ElevatedButton.styleFrom(
                  //                             padding: EdgeInsets.all(20),
                  //                             foregroundColor:
                  //                                 Colors.redAccent),
                  //                         // style: ButtonStyle(
                  //                         //     foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  //                         //   ),
                  //                       ),
                  //                       const SizedBox(height: 8),
                  //                     ],
                  //                   ),
                  //                 ],
                  //               ),
                  //             );
                  //           },
                  //         );
                  //       },
                  //       icon: Icon(Icons.more_vert),
                  //     ),
                  //     // IconButton(
                  //     //   onPressed: () {
                  //     //     FirebaseFirestore.instance
                  //     //         .collection("users")
                  //     //         .doc(FirebaseAuth.instance.currentUser!.uid)
                  //     //         .collection("jobs")
                  //     //         .doc(widget.jobId)
                  //     //         .collection("applicants")
                  //     //         .doc(document["mobileNumber"])
                  //     //         .delete();
                  //     //   },
                  //     //   color: Colors.red,
                  //     //   splashColor: Colors.red,
                  //     //   highlightColor: Colors.redAccent,
                  //     //   tooltip: "Delete",
                  //     //   // hoverColor: Colors.redAccent,
                  //     //   icon: Icon(Icons.delete_outlined),
                  //     //   selectedIcon: Icon(Icons.delete),
                  //     //   // label: Text("delete"),
                  //     // ),
                  //   ],
                  // ),
                );
              },
            );
          }

          return const Center(
            child: Text("No Notification"),
          );
        },
      ),
    );
  }
}
