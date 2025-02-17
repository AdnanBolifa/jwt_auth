import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwt_auth/data/multi_survey_config.dart';
import 'package:jwt_auth/data/ticket_config.dart';
import 'package:jwt_auth/main.dart';
import 'package:jwt_auth/screens/home.dart';
import 'package:jwt_auth/services/api_service.dart';
import 'package:jwt_auth/services/debouncer.dart';

class SurveyPage extends StatefulWidget {
  final Ticket? ticket;

  const SurveyPage({Key? key, required this.ticket}) : super(key: key);

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  bool hasError = false;
  Map<int, int> questionRatings = {}; //radio button
  List<MultiSurvey> survey = []; //survey quesiton
  List<TextEditingController> notesControllers = [];
  List<int> selectedRatings = []; //rating abr
  final Debouncer _debouncer = Debouncer();
  bool isSubmitting = false;
  @override
  void initState() {
    super.initState();
    _getSurvey();
  }

  void _handleError() {
    setState(() {
      hasError = true;
    });
  }

  void _retryFetchingData() {
    // Clear the error flag and attempt to fetch data again.
    setState(() {
      hasError = false;
    });
    _getSurvey();
  }

  Future<void> _getSurvey() async {
    try {
      final multi = await ApiService().fetchSurvey();
      setState(() {
        survey = multi;
        selectedRatings = List.generate(survey.length, (index) => 0);
      });
    } catch (e) {
      ApiService().handleErrorMessage(msg: 'Error fetching survey data: $e');
      if (kDebugMode) {
        print("Error fetching survey data: $e");
      }
      _handleError();
    }
  }

  Future<bool> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('الاستبيان'),
        centerTitle: true,
      ),
      body: hasError
          ? _buildErrorWidget()
          : FutureBuilder(
              future: checkInternetConnectivity(),
              builder: (context, snapshot) {
                return snapshot.hasError || snapshot.data == false
                    ? _buildNoInternetWidget()
                    : survey.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : _buildSurveyWidget();
              },
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "حدث عطل ما!",
              style: TextStyle(fontSize: 16),
            ),
            ElevatedButton(
                onPressed: () {
                  _retryFetchingData();
                },
                child: const Text('حاول مجددا'))
          ],
        ),
      ),
    );
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "لا يوجد اتصال بالانترنت",
              style: TextStyle(fontSize: 16),
            ),
            ElevatedButton(
                onPressed: () {
                  _retryFetchingData();
                },
                child: const Text('حاول مجددا'))
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyWidget() {
    return SingleChildScrollView(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < survey.length; i++)
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuestionText(i),
                      if (survey[i].type == 'rating') _buildRatingBar(i),
                      const SizedBox(height: 10),
                      if (survey[i].type == 'multi') _buildMultiAnswers(i),
                      const SizedBox(height: 10),
                      if (survey[i].type == 'text') _buildTextFormField(i),
                    ],
                  ),
                ),
              const SizedBox(height: 20.0),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionText(int i) {
    return Text(
      '${survey[i].question}',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRatingBar(int i) {
    return Center(
      child: RatingBar.builder(
        initialRating: selectedRatings[i].toDouble(),
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {
          setState(() {
            selectedRatings[i] = rating.toInt();
          });
        },
      ),
    );
  }

  Widget _buildMultiAnswers(int i) {
    return Wrap(
      children: [
        for (int j = 0; j < survey[i].answers!.length; j++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildRadio(i, j),
              Text(
                survey[i].answers![j].text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTextFormField(int index) {
    while (index >= notesControllers.length) {
      notesControllers.add(TextEditingController());
    }
    return TextFormField(
      controller: notesControllers[index],
      decoration: const InputDecoration(
        hintText: 'اضف ملاحظاتك',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(12.0),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16.0),
      ),
      onPressed: () {
        setState(() {
          isSubmitting = true;
        });
        _debouncer.run(() async {
          List<Map<String, dynamic>> answersList = [];
          for (int i = 0; i < survey.length; i++) {
            if (survey[i].type == 'multi') {
              answersList.add({
                "question": survey[i].id,
                "answer": questionRatings[i],
              });
            }
            if (survey[i].type == 'rating') {
              answersList.add({
                "question": survey[i].id,
                "answer": selectedRatings[i],
              });
            }
            if (survey[i].type == 'text') {
              answersList.add({
                "question": survey[i].id,
                "answer": notesControllers[i].text,
              });
            }
          }
          //! No null or empty values uncomment this.
          // bool isValid =
          //     answersList.every((answer) => answer['answer'] != null && answer['answer'].toString().isNotEmpty && answer['answer'] != 0);
          // if (!isValid) {
          //   Fluttertoast.showToast(msg: 'الرجاء تعبئة الحقول');
          //   setState(() {
          //     isSubmitting = false;
          //   });
          //   return;
          // }
          try {
            await ApiService().submitSurvey(widget.ticket!.id, answersList);
          } catch (e) {
            ApiService().handleErrorMessage(msg: 'ERROR: $e');
          }
          setState(() {
            isSubmitting = false;
          });
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        });
      },
      child: isSubmitting
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : const Text(
              'إرسال',
              style: TextStyle(fontSize: 18),
            ),
    );
  }

  Widget buildRadio(int question, int value) {
    return Row(
      children: [
        Radio(
          value: value + 1, //start the radio button from one not zero
          groupValue: questionRatings[question] ?? -1,
          onChanged: (int? rating) {
            setState(() {
              questionRatings[question] = rating!;
            });
          },
        ),
      ],
    );
  }
}
