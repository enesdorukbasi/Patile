// ignore_for_file: must_be_immutable, empty_catches

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/question_answer_services.dart';
import 'package:patile/cores/firebase_services/firestore_services/user_vet_services.dart';
import 'package:patile/models/firebase_models/answer.dart';
import 'package:patile/models/firebase_models/question.dart';
import 'package:patile/models/firebase_models/user_local.dart';
import 'package:patile/models/firebase_models/vet.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/shortDeisgnPatterns/input_decoration.dart';
import 'package:patile/views/profile_pages/profile_page.dart';
import 'package:patile/widgets/answer_card.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';

class QuestionDetailsPage extends StatelessWidget {
  Question question;

  QuestionDetailsPage({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => isLoadingCubit()),
      ],
      child: QuestionDetailsView(
        question: question,
      ),
    );
  }
}

class QuestionDetailsView extends StatelessWidget {
  Question question;
  UserLocal? userLocal;
  String activeUserId = "";
  Vet? vet;
  Size? size;
  TextEditingController textEditingController = TextEditingController();
  QuestionDetailsView({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    activeUserId = Provider.of<AuthenticationService>(context, listen: false)
        .activeUserId
        .toString();
    Question questionStream;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBars().transparentBackgroundAppBar(
          context,
          question.title.toUpperCase(),
          [
            StreamBuilder<DocumentSnapshot>(
              stream: QuestionAndAnswersFirestoreServices()
                  .getQuestionById(question.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 0,
                    width: 0,
                  );
                }

                questionStream = Question.createQuestionByDoc(snapshot.data!);

                if (question.publishedUserId == activeUserId) {
                  return PopupMenuButton<String>(
                    onSelected: (value) {
                      if (questionStream.isOk == true) {
                        switch (value) {
                          case 'Sorum Devam Ediyor':
                            QuestionAndAnswersFirestoreServices()
                                .updateQuestion(questionStream);
                            break;
                          case 'Sorumu Sil':
                            QuestionAndAnswersFirestoreServices()
                                .deleteQuestion(question.id);
                            break;
                        }
                      } else {
                        switch (value) {
                          case 'Sorum Çözüldü':
                            QuestionAndAnswersFirestoreServices()
                                .updateQuestion(questionStream);
                            break;
                          case 'Sorumu Sil':
                            QuestionAndAnswersFirestoreServices()
                                .deleteQuestion(question.id);
                            Navigator.pop(context);
                            break;
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      if (questionStream.isOk == true) {
                        return {'Sorum Devam Ediyor', 'Sorumu Sil'}
                            .map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      } else {
                        return {'Sorum Çözüldü', 'Sorumu Sil'}
                            .map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      }
                    },
                  );
                } else {
                  return const SizedBox(
                    height: 0,
                    width: 0,
                  );
                }
              },
            )
          ],
          true,
          true,
          null,
        ),
        body: Column(
          children: [
            _questionBody(context),
            // Expanded(child: answerList()),
            Expanded(child: answerList()),
            Align(
              alignment: Alignment.bottomCenter,
              child: answerBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget answerList() {
    return StreamBuilder(
      stream: QuestionAndAnswersFirestoreServices().getAllAnswers(question.id),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const CustomProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text("Bir hata ile karşılaşıldı."),
          );
        }

        List<DocumentSnapshot> docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('Bu soruya henüz cevap verilmemiş.'));
        }

        return SizedBox(
          height: size!.height * 0.72,
          child: ListView.builder(
            padding: EdgeInsets.only(
              top: size!.height * 0.01,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return AnswerCard(answerDoc: docs[index]);
            },
          ),
        );
      },
    );
  }

  Align answerBody(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Stack(
        children: [
          TextFormField(
            controller: textEditingController,
            maxLines: null,
            inputFormatters: [
              LengthLimitingTextInputFormatter(55),
            ],
            decoration: CustomInputDecorations().inputDecoration2(
              context,
              'Cevap Ver',
              null,
              IconButton(
                padding: const EdgeInsets.only(
                  top: 2,
                  bottom: 2,
                ),
                onPressed: () {
                  if (textEditingController.text != "") {
                    QuestionAndAnswersFirestoreServices().createComment(
                      textEditingController.text,
                      question.id,
                      activeUserId,
                      null,
                    );
                    textEditingController.text = "";
                  }
                },
                icon: FaIcon(
                  Icons.send,
                  color: Theme.of(context).primaryColor,
                  size: size!.height * 0.06,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionBody(BuildContext context) {
    return Container(
      height: size!.height * 0.2,
      width: size!.width * 1,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          // Expanded(
          //   child: Center(
          //     child: Text(
          //       question.content.toUpperCase(),
          //       textAlign: TextAlign.center,
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontWeight: FontWeight.bold,
          //         fontSize: size!.height * 0.02,
          //       ),
          //     ),
          //   ),
          // ),
          Center(
            child: Text(
              question.content.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size!.height * 0.02,
              ),
            ),
          ),
          Align(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: FutureBuilder<String>(
                    future: getUserOrVet(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ProfilePage(vet: vet, userLocal: userLocal),
                          ));
                        },
                        child: Container(
                          width: size!.width * 0.15,
                          height: size!.width * 0.13,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(31),
                              topRight: Radius.circular(31),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(snapshot.data!),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: size!.width * 0.1,
                    height: size!.width * 0.1,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                      ),
                    ),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: QuestionAndAnswersFirestoreServices()
                          .getQuestionById(question.id),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        return Center(
                          child: FaIcon(
                            snapshot.data!.get('isOk')
                                ? FontAwesomeIcons.check
                                : FontAwesomeIcons.hourglassStart,
                            color: Colors.white,
                            size: size!.width * 0.05,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getUserOrVet() async {
    String url =
        "https://firebasestorage.googleapis.com/v0/b/patilefiredb.appspot.com/o/images%2FsystemImages%2Fnon_user.jpg?alt=media&token=16b877a1-1ac4-458b-b40a-463bccf22806";
    try {
      userLocal = await UserAndVetFirestoreServices()
          .getUserButNotNull(question.publishedUserId);
      url = userLocal!.pphoto;
    } catch (ex) {}
    try {
      vet = await UserAndVetFirestoreServices()
          .getVetButNotNull(question.publishedUserId);
      url = vet!.pphoto;
    } catch (ex) {}
    return url;
  }
}
