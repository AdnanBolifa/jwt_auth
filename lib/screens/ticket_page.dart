import 'package:flutter/material.dart';
import 'package:jwt_auth/data/location_config.dart';
import 'package:jwt_auth/data/problem_config.dart';
import 'package:jwt_auth/data/ticket_config.dart';
import 'package:jwt_auth/data/solution_config.dart';
import 'package:jwt_auth/screens/survey_page.dart';
import 'package:jwt_auth/services/api_service.dart';
import 'package:jwt_auth/services/location_services.dart';
import 'package:jwt_auth/widgets/map_box.dart';
import 'package:jwt_auth/widgets/text_field.dart';
import 'package:jwt_auth/widgets/comment_section.dart';

class AddTicket extends StatefulWidget {
  final Widget? comments;
  final Ticket? ticket;
  const AddTicket({Key? key, this.comments, this.ticket}) : super(key: key);

  @override
  _AddReportScreenState createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddTicket> {
  //Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController accController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController sectorController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  String name = '';
  String account = '';
  String phone = '';
  String place = '';
  String sector = '';
  double? longitude;
  double? latitude;

  List<Problem> problemsCheckbox = [];
  List<Solution> solutionsCheckbox = [];
  List<String> textTrueProblem = [];
  List<String> textTrueSolution = [];
  late List<bool> problemCheckboxGroup;
  late List<bool> solutionCheckboxGroup;

  void init() {
    if (widget.ticket != null) {
      name = nameController.text = widget.ticket!.userName;
      phone = phoneController.text = widget.ticket!.mobile;
      place = placeController.text = widget.ticket!.place!;
      sector = sectorController.text = widget.ticket!.sector!;
      account = accController.text = widget.ticket!.acc!;
      longitude = widget.ticket!.locationData!.longitude;
      latitude = widget.ticket!.locationData!.latitude;
    }
    if (latitude != 0 && longitude != 0) {
      locationController.text = '$latitude, $longitude';
    }
  }

  @override
  void initState() {
    super.initState();
    init();

    ApiService().fetchProblems().then((problems) {
      setState(() {
        problemsCheckbox = problems;
        problemCheckboxGroup =
            List.generate(problemsCheckbox.length, (index) => false);

        if (widget.ticket != null) {
          for (var item in widget.ticket!.problems!) {
            for (var i = 0; i < problemsCheckbox.length; i++) {
              if (item == problemsCheckbox[i].id) {
                textTrueProblem.add(problemsCheckbox[i].name);
                problemCheckboxGroup[i] = true;
              }
            }
          }
        }
      });
    });

    // Fetch solutions and update the state when done.
    ApiService().fetchSolutions().then((solutions) {
      setState(() {
        solutionsCheckbox = solutions;
        solutionCheckboxGroup =
            List.generate(solutionsCheckbox.length, (index) => false);

        if (widget.ticket != null) {
          for (var item in widget.ticket!.solutions!) {
            for (var i = 0; i < solutionsCheckbox.length; i++) {
              if (item == solutionsCheckbox[i].id) {
                textTrueSolution.add(solutionsCheckbox[i].name);
                solutionCheckboxGroup[i] = true;
              }
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    placeController.dispose();
    sectorController.dispose();
    accController.dispose();
    super.dispose();
  }

  TextEditingController locationController = TextEditingController();
  final LocationService locationService = LocationService();
  LocationData? locationData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            margin: const EdgeInsets.all(8.0), // Margin for spacing
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ElevatedButton(
              onPressed: () {
                _submitReport();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text(
                'حفظ',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w300),
              ),
            ),
          ),
        ],
        title: const Text(
          'إضافة بلاغ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Text Fields
              textReports(
                'الاسم',
                'خالد جمعة',
                name,
                nameController,
                (value) {
                  setState(() {
                    name = value;
                  });
                },
              ),

              Row(
                children: [
                  Expanded(
                    child: textReports(
                      'الهاتف',
                      '091XXXXXXX',
                      name,
                      phoneController,
                      (value) {
                        setState(() {
                          phone = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: textReports(
                      'الحساب',
                      'HTIX00000',
                      account,
                      accController,
                      (value) {
                        setState(() {
                          account = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Expanded(
                    child: textReports(
                      'المكان',
                      'ش طرابلس',
                      place,
                      placeController,
                      (value) {
                        setState(() {
                          place = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: textReports(
                      'البرج',
                      'س',
                      sector,
                      sectorController,
                      (value) {
                        setState(() {
                          sector = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 100, // Set the default minimum height to 100
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Stack(
                    children: [
                      const Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'المشاكل',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: textTrueProblem.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              dense: true,
                              leading: Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.fiber_manual_record,
                                  size: 12,
                                  color: Colors.black,
                                ),
                              ),
                              title: Text(
                                textTrueProblem[index],
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: IconButton(
                            onPressed: () {
                              _showBottomSheetProblem(context);
                            },
                            icon: const Icon(Icons.edit, color: Colors.black),
                            iconSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Checkboxes - Group Solutions
              const SizedBox(height: 15.0),

              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 100, // Set the default minimum height to 100
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Stack(
                    children: [
                      const Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'الحلول',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: textTrueSolution.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              dense: true,
                              leading: Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.fiber_manual_record,
                                  size: 12,
                                  color: Colors.black,
                                ),
                              ),
                              title: Text(
                                textTrueSolution[index],
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: IconButton(
                            onPressed: () {
                              _showBottomSheetSolution(context);
                            },
                            icon: const Icon(Icons.edit, color: Colors.black),
                            iconSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        locationData = await locationService.getUserLocation();
                        locationController.text =
                            '${locationData!.latitude}, ${locationData!.longitude}';
                        setState(() {
                          longitude = locationData!.longitude;
                          latitude = locationData!.latitude;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(60, 80),
                          backgroundColor: Colors.grey[300]),
                      child: const Center(
                        // Center the text
                        child: Text(
                          "جلب احداثيات الموقع",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: locationController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'احداثيات الموقع',
                          hintStyle:
                              TextStyle(fontSize: 14, color: Colors.grey),
                          hintText: 'xx.xxxx, xx.xxxx',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              //*Map
              const SizedBox(height: 10),
              if (latitude != 0 && longitude != 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    width: 400,
                    height: 200,
                    child: MapBox(
                        latitude: latitude!,
                        longitude: longitude!,
                        zoomLvl: 15),
                  ),
                ),
              const SizedBox(
                height: 15,
              ),

              const SizedBox(height: 16.0),
              if (widget.ticket != null)
                CommentSection(
                    id: widget.ticket!.id,
                    user: widget.ticket!,
                    comments: widget.ticket!.comments),
            ],
          ),
        ),
      ),
    );
  }

  void _submitReport() {
    List<int> selectedSolutionIds = solutionCheckboxGroup
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => solutionsCheckbox[entry.key].id)
        .toList();

    List<int> selectedProblemIds = problemCheckboxGroup
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => problemsCheckbox[entry.key].id)
        .toList();
    //go to update or add functions
    if (widget.ticket == null) {
      ApiService().addReport(
          name,
          account,
          phone,
          place,
          sector,
          selectedProblemIds,
          selectedSolutionIds,
          locationData!.longitude!,
          locationData!.latitude!);
    } else {
      ApiService().updateReport(
          //!bug when updating GPS
          name: nameController.text,
          acc: accController.text,
          phone: phoneController.text,
          place: placeController.text,
          sector: sectorController.text,
          id: widget.ticket!.id,
          problems: selectedProblemIds,
          solution: selectedSolutionIds,
          longitude: longitude,
          latitude: latitude);
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return SurveyPage(ticket: widget.ticket);
    }));
  }

  void _updateSelectedProblems() {
    textTrueProblem.clear();
    for (int index = 0; index < problemsCheckbox.length; index++) {
      if (problemCheckboxGroup[index]) {
        textTrueProblem.add(problemsCheckbox[index].name);
      }
    }
  }

  void _updateSelectedSolution() {
    textTrueSolution.clear();
    for (int index = 0; index < solutionsCheckbox.length; index++) {
      if (solutionCheckboxGroup[index]) {
        textTrueSolution.add(solutionsCheckbox[index].name);
      }
    }
  }

  void _showBottomSheetProblem(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ListView.builder(
              itemCount: problemsCheckbox.length,
              itemBuilder: (BuildContext context, int index) {
                return CheckboxListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          problemsCheckbox[index].name,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  value: problemCheckboxGroup[index],
                  onChanged: (value) {
                    setState(() {
                      problemCheckboxGroup[index] = value!;
                    });
                  },
                );
              },
            );
          },
        );
      },
    ).then((result) {
      _updateSelectedProblems();
      setState(() {});
    });
  }

  void _showBottomSheetSolution(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ListView.builder(
              itemCount: solutionsCheckbox.length,
              itemBuilder: (BuildContext context, int index) {
                return CheckboxListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          solutionsCheckbox[index].name,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  value: solutionCheckboxGroup[index],
                  onChanged: (value) {
                    setState(() {
                      solutionCheckboxGroup[index] = value!;
                    });
                  },
                );
              },
            );
          },
        );
      },
    ).then((result) {
      _updateSelectedSolution();
      setState(() {});
    });
  }
}
