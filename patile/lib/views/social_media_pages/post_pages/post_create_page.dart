// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:io';

import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/blocs/widget_blocs/image_cubits.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/social_media_services.dart';
import 'package:patile/cores/firebase_services/storage_services/storage_service.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/shortDeisgnPatterns/flash_messages.dart';
import 'package:patile/shortDeisgnPatterns/input_decoration.dart';
import 'package:patile/widgets/button_custom_progress_indicator.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';

class PostCreatePage extends StatelessWidget {
  const PostCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => isLoadingCubit()),
        BlocProvider(create: (context) => ImageListChangeCubit()),
      ],
      child: PostCreateView(),
    );
  }
}

class PostCreateView extends StatelessWidget {
  Size? size;
  String content = "";
  String activeUserId = "";
  var formKey = GlobalKey<FormState>();
  final ImagePicker imagePicker = ImagePicker();

  List<XFile>? imageFileList = [];
  List<File>? uploadImageList = [];
  List<String> imageUrlList = [];

  PostCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    activeUserId = Provider.of<AuthenticationService>(context, listen: false)
        .activeUserId
        .toString();
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBars().colorBackgroundAppbar(context, 'Post Oluştur', []),
      body: Form(
        key: formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: size!.width * 0.02),
          children: [
            SizedBox(height: size!.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    context.read<ImageListChangeCubit>().changeImages([]);
                    selectImages(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(size!.height * 0.035),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: FaIcon(
                      Icons.image_search,
                      color: Colors.white,
                      size: size!.height * 0.035,
                    )),
                  ),
                ),
              ],
            ),
            SizedBox(height: size!.height * 0.02),
            BlocBuilder<ImageListChangeCubit, List<XFile>>(
              builder: (context, state) {
                if (state.isNotEmpty) {
                  uploadImageList = state.map((e) => File(e.path)).toList();

                  return SizedBox(
                    width: size!.width * 1,
                    height: size!.height * 0.14,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        SizedBox(
                          width: size!.width * 1,
                          height: size!.height * 0.14,
                          child: DynamicHeightGridView(
                            itemCount: state.length,
                            crossAxisCount: state.length,
                            builder: (BuildContext context, int index) {
                              File file = File(state[index].path);

                              return Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: FileImage(file),
                                      fit: BoxFit.cover),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            SizedBox(height: size!.height * 0.02),
            TextFormField(
              maxLength: 30,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Açıklama alanı boş bırakılamaz.";
                }
              },
              onSaved: (newValue) => content = newValue!,
              decoration: CustomInputDecorations()
                  .inputDecoration1(context, 'Açıklama', null),
            ),
            SizedBox(height: size!.height * 0.02),
            BlocBuilder<isLoadingCubit, bool>(
              builder: (context, state) {
                return InkWell(
                  onTap: () {
                    if (!state) {
                      _shareToPost(context);
                    }
                  },
                  child: Container(
                    width: size!.width * 0.4,
                    height: size!.height * 0.04,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: state
                          ? const ButtonCustomProgressIndicator()
                          : const Text(
                              'Gönderiyi Paylaş',
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
          ],
        ),
      ),
    );
  }

  void selectImages(BuildContext context) async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
      context.read<ImageListChangeCubit>().changeImages(imageFileList!);
    }
  }

  _shareToPost(BuildContext context) async {
    try {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        context.read<isLoadingCubit>().isLoadingState(true);

        if (uploadImageList == null || uploadImageList!.isEmpty) {
          ScaffoldMessenger.of(context)
              .showSnackBar(FlashMessages().flasMessages1(
            title: 'Hata!',
            message: 'Görsel eklenmeden gönderi paylaşılamaz.',
            type: FlashMessageTypes.error,
            svgPath: 'assets/svgs/error_svg.svg',
          ));
          context.read<isLoadingCubit>().isLoadingState(false);
          return;
        }

        imageUrlList =
            await StorageService().postImagesUpload(uploadImageList!);

        await SocialMediaFireStoreServices().createPost(
            images: imageUrlList,
            likedUsers: [],
            content: content,
            publishedUserId: activeUserId);

        context.read<isLoadingCubit>().isLoadingState(false);
        Navigator.pop(context);
      }
    } catch (ex) {
      context.read<isLoadingCubit>().isLoadingState(false);
      ScaffoldMessenger.of(context).showSnackBar(FlashMessages().flasMessages1(
        title: 'Hata!',
        message: 'Bir hata oluştu.',
        type: FlashMessageTypes.error,
        svgPath: 'assets/svgs/error_svg.svg',
      ));
    }
  }
}
