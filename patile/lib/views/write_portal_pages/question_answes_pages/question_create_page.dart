// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/question_answer_services.dart';
import 'package:patile/shortDeisgnPatterns/input_decoration.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class QuestionCreatePage extends StatelessWidget {
  SolidController controller;

  QuestionCreatePage({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => isLoadingCubit()),
        ],
        child: QuestionCreateView(
          controller: controller,
        ));
  }
}

class QuestionCreateView extends StatelessWidget {
  var formKey = GlobalKey<FormState>();
  SolidController controller;
  Size? size;
  String title = "", content = "", activeUserId = "";

  QuestionCreateView({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    activeUserId = Provider.of<AuthenticationService>(context, listen: false)
        .activeUserId
        .toString();
    size = MediaQuery.of(context).size;
    return _body(context, controller);
  }

  Padding _body(BuildContext context, SolidController controller) {
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
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
              ],
              maxLength: 10,
              decoration: CustomInputDecorations()
                  .inputDecoration1(context, 'Soru Başlığı', null),
            ),
            SizedBox(height: size!.height * 0.01),
            TextFormField(
              onSaved: (newValue) => content = newValue!,
              inputFormatters: [
                LengthLimitingTextInputFormatter(35),
              ],
              maxLength: 35,
              maxLines: null,
              decoration: CustomInputDecorations()
                  .inputDecoration1(context, 'Soru İçeriği', null),
            ),
            SizedBox(height: size!.height * 0.015),
            InkWell(
              onTap: () => _shareToQuestion(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white),
                ),
                child: Center(
                  child: BlocBuilder<isLoadingCubit, bool>(
                    builder: (context, state) {
                      if (state) {
                        return const CustomProgressIndicator();
                      }
                      return const Text(
                        'Soruyu Paylaş',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
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
          .createQuestion(title, content, activeUserId, true);
      controller.hide();
    }
    context.read<isLoadingCubit>().isLoadingState(false);
  }
}
