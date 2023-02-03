// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:patile/models/firebase_models/question.dart';
import 'package:patile/views/write_portal_pages/question_answes_pages/question_details_page.dart';

class QuestionCard extends StatelessWidget {
  Size? size;
  Question question;

  QuestionCard({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size!.height * 0.01,
        horizontal: size!.width * 0.05,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => QuestionDetailsPage(question: question),
          ));
        },
        child: Container(
          width: double.infinity,
          height: size!.height * 0.1,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: _body(context),
        ),
      ),
    );
  }

  Row _body(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _questionImage(),
        Expanded(child: _bodyInTexts()),
        _questionStatus()
      ],
    );
  }

  Padding _questionStatus() {
    return Padding(
      padding: EdgeInsets.only(right: size!.width * 0.05),
      child: FaIcon(
        question.isOk
            ? FontAwesomeIcons.check
            : FontAwesomeIcons.hourglassStart,
        color: Colors.white,
      ),
    );
  }

  Center _bodyInTexts() {
    return Center(
      child: Text(
        question.title.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size!.height * 0.02,
        ),
      ),
    );
  }

  Padding _questionImage() {
    return Padding(
      padding: EdgeInsets.only(left: size!.width * 0.05),
      child: Container(
        width: size!.width * 0.15,
        height: size!.width * 0.15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          image: const DecorationImage(
            image: AssetImage('assets/images/question.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
