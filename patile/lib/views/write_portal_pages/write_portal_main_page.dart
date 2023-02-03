// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/blocs/widget_blocs/bottom_sheet_cubits.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/question_answer_services.dart';
import 'package:patile/models/firebase_models/question.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/shortDeisgnPatterns/input_decoration.dart';
import 'package:patile/widgets/button_custom_progress_indicator.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:patile/widgets/question_card.dart';
import 'package:provider/provider.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class WritePortalPage extends StatelessWidget {
  const WritePortalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => isLoadingCubit()),
        BlocProvider(create: (context) => OnBottomSheetStatus())
      ],
      child: WritePortalView(),
    );
  }
}

class WritePortalView extends StatelessWidget {
  Size? size;
  var formKey = GlobalKey<FormState>();
  String title = "", content = "", activeUserId = "";
  SolidController solidController = SolidController();
  WritePortalView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    activeUserId = Provider.of<AuthenticationService>(context, listen: false)
        .activeUserId
        .toString();
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBars().transparentBackgroundAppBar(
          context, 'Soru-Cevap', [], true, false, null),
      bottomNavigationBar: _bottomSheet(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: QuestionAndAnswersFirestoreServices().getAllQuestions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CustomProgressIndicator();
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Bir hata oluştu.',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            );
          }

          List<Question> questions = snapshot.data!.docs
              .map((e) => Question.createQuestionByDoc(e))
              .toList();

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return QuestionCard(question: questions[index]);
            },
          );
        },
      ),
    );
  }

  _bottomSheet(BuildContext context) {
    return BlocBuilder<OnBottomSheetStatus, bool>(
      builder: (context, state) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SolidBottomSheet(
              maxHeight: size!.height * 0.8,
              minHeight: !state ? 0 : size!.height * 0.8,
              toggleVisibilityOnTap: true,
              draggableBody: true,
              controller: solidController,
              onShow: () {
                context.read<OnBottomSheetStatus>().statusChange(true);
              },
              onHide: () {
                context.read<OnBottomSheetStatus>().statusChange(false);
              },
              headerBar: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      right: size!.width * 0.01,
                      bottom: size!.width * 0.01,
                    ),
                    child: Container(
                      width: size!.width * 0.15,
                      height: size!.width * 0.15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                          ),
                        ],
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Center(
                        child: state
                            ? InkWell(
                                onTap: () => solidController.hide(),
                                child: const FaIcon(
                                  Icons.keyboard_double_arrow_down,
                                  color: Colors.white,
                                ),
                              )
                            : InkWell(
                                onTap: () => solidController.show(),
                                child: const FaIcon(
                                  Icons.keyboard_double_arrow_up,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              body: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                    ),
                  ],
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                child: _body(context),
              ),
            );
          },
        );
      },
    );
  }

  Padding _body(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(size!.width * 0.04),
      child: Form(
        key: formKey,
        child: ListView(
          children: [
            SizedBox(height: size!.height * 0.01),
            Center(
              child: Text(
                'Soru Sor',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size!.width * 0.1,
                ),
              ),
            ),
            SizedBox(height: size!.height * 0.015),
            TextFormField(
              onSaved: (newValue) => title = newValue!,
              maxLength: 10,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Soru başlığı alanı boş geçilemez.";
                }
              },
              decoration: CustomInputDecorations()
                  .inputDecoration1(context, 'Soru Başlığı', null),
            ),
            SizedBox(height: size!.height * 0.01),
            TextFormField(
              onSaved: (newValue) => content = newValue!,
              maxLength: 100,
              validator: (value) {
                if (value!.length < 10) {
                  return "Soru içeriği minimum 10 karakter içermelidir.";
                }
              },
              maxLines: null,
              decoration: CustomInputDecorations()
                  .inputDecoration1(context, 'Soru İçeriği', null),
            ),
            SizedBox(height: size!.height * 0.015),
            BlocBuilder<isLoadingCubit, bool>(
              builder: (context, state) {
                return InkWell(
                  onTap: () {
                    if (!state) {
                      _shareToQuestion(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Center(
                      child: state
                          ? const ButtonCustomProgressIndicator()
                          : const Text(
                              'Soruyu Paylaş',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: size!.height * 0.01),
          ],
        ),
      ),
    );
  }

  Future<void> _shareToQuestion(BuildContext context) async {
    context.read<isLoadingCubit>().isLoadingState(true);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      await QuestionAndAnswersFirestoreServices()
          .createQuestion(title, content, activeUserId, false);
      solidController.hide();
    }
    context.read<isLoadingCubit>().isLoadingState(false);
  }
}
