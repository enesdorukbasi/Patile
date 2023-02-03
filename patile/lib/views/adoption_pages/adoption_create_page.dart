// ignore_for_file: must_be_immutable, use_build_context_synchronously, unnecessary_null_comparison

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patile/blocs/json_blocs/il_ilce_cubits.dart';
import 'package:patile/blocs/json_blocs/pet_type_breed_cubits.dart';
import 'package:patile/blocs/widget_blocs/general_cubits.dart';
import 'package:patile/blocs/widget_blocs/image_cubits.dart';
import 'package:patile/cores/firebase_services/authentication_service.dart';
import 'package:patile/cores/firebase_services/firestore_services/adoption_services.dart';
import 'package:patile/cores/firebase_services/storage_services/storage_service.dart';
import 'package:patile/shortDeisgnPatterns/appbars.dart';
import 'package:patile/shortDeisgnPatterns/flash_messages.dart';
import 'package:patile/shortDeisgnPatterns/input_decoration.dart';
import 'package:patile/widgets/button_custom_progress_indicator.dart';
import 'package:patile/widgets/custom_progress_indicator.dart';
import 'package:provider/provider.dart';

class AdoptionCreatePage extends StatelessWidget {
  const AdoptionCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => PageNumber()),
        BlocProvider(create: (context) => isLoadingCubit()),
        BlocProvider(create: (context) => getIlNamesCubit()),
        BlocProvider(create: (context) => getIlceNamesCubit()),
        BlocProvider(create: (context) => getTypeNameListCubit()),
        BlocProvider(create: (context) => getBreedNameListCubit()),
        BlocProvider(create: (context) => Image1Cubit()),
        BlocProvider(create: (context) => Image2Cubit()),
        BlocProvider(create: (context) => Image3Cubit()),
      ],
      child: AdoptionCreateView(),
    );
  }
}

class AdoptionCreateView extends StatelessWidget {
  Size? size;
  var formKey = GlobalKey<FormState>();
  bool bodyOneIsActive = true;
  File? photo1, photo2, photo3;
  String title = "",
      content = "",
      old = "",
      il = "",
      ilce = "",
      petType = "",
      petBreed = "";

  AdoptionCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBars().colorBackgroundAppbar(context, 'İlan Oluştur', null),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: BlocBuilder<PageNumber, int>(
          builder: (context, state) {
            bodyOneIsActive = state == 0 ? true : false;
            return Stack(
              children: [
                Visibility(
                  visible: bodyOneIsActive,
                  child: _body1(context),
                ),
                Visibility(
                  visible: !bodyOneIsActive,
                  child: _body2(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Form _body1(BuildContext context) {
    context.read<getIlNamesCubit>().getIl();
    context.read<getTypeNameListCubit>().getTypes();
    return Form(
        key: formKey,
        child: ListView(
          children: [
            SizedBox(height: size!.height * 0.04),
            TextFormField(
              onSaved: (newValue) => title = newValue.toString(),
              decoration: CustomInputDecorations()
                  .inputDecoration1(context, 'Başlık', null),
            ),
            SizedBox(height: size!.height * 0.01),
            TextFormField(
              maxLines: null,
              onSaved: (newValue) => content = newValue.toString(),
              decoration: CustomInputDecorations()
                  .inputDecoration1(context, 'Açıklama', null),
            ),
            SizedBox(height: size!.height * 0.01),
            TextFormField(
              keyboardType: TextInputType.number,
              onSaved: (newValue) => old = newValue.toString(),
              decoration: CustomInputDecorations()
                  .inputDecoration1(context, 'Yaş', null),
            ),
            SizedBox(height: size!.height * 0.01),
            BlocBuilder<getIlNamesCubit, List<String>>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField(
                      decoration: CustomInputDecorations()
                          .inputDecoration1(context, 'İl Seçiniz', null),
                      items: state.map((String e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (String? selectedValue) {
                        il = selectedValue.toString();
                        context
                            .read<getIlceNamesCubit>()
                            .getIlce(selectedValue!);
                      },
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: size!.height * 0.01),
            BlocBuilder<getIlceNamesCubit, List<String>>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField(
                      decoration: CustomInputDecorations()
                          .inputDecoration1(context, 'İlçe Seçiniz', null),
                      items: state.map((String e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (String? selectedValue) {
                        ilce = selectedValue.toString();
                      },
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: size!.height * 0.01),
            BlocBuilder<getTypeNameListCubit, List<String>>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField(
                      decoration: CustomInputDecorations()
                          .inputDecoration1(context, 'Pati Türü Seçiniz', null),
                      items: state.map((String e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (String? selectedValue) {
                        petType = selectedValue.toString();
                        context
                            .read<getBreedNameListCubit>()
                            .getBreeds(selectedValue!);
                      },
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: size!.height * 0.01),
            BlocBuilder<getBreedNameListCubit, List<String>>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButtonFormField(
                      decoration: CustomInputDecorations().inputDecoration1(
                          context, 'Pati Cinsi Seçiniz', null),
                      items: state.map((String e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (String? selectedValue) {
                        petBreed = selectedValue.toString();
                      },
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: size!.height * 0.04),
            GestureDetector(
              onTap: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  context.read<PageNumber>().changePage(1);
                }
              },
              child: Container(
                height: size!.height * 0.05,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    'Devam Et',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Center _body2(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () async {
                  String selectedPicker = await _selectPhoto(1, context);
                  if (selectedPicker == "gallery") {
                    await _selectAGallery(1, context);
                  } else if (selectedPicker == "takePhoto") {
                    await _takeAPhoto(1, context);
                  }
                },
                child: BlocBuilder<Image1Cubit, String>(
                  builder: (context, state) {
                    return CircleAvatar(
                      radius: 50,
                      backgroundImage: state != null || state != " "
                          ? FileImage(File(state))
                          : null,
                    );
                  },
                ),
              ),
              InkWell(
                onTap: () async {
                  String selectedPicker = await _selectPhoto(2, context);
                  if (selectedPicker == "gallery") {
                    await _selectAGallery(2, context);
                  } else if (selectedPicker == "takePhoto") {
                    await _takeAPhoto(2, context);
                  }
                },
                child: BlocBuilder<Image2Cubit, String>(
                  builder: (context, state) {
                    return CircleAvatar(
                      radius: 50,
                      backgroundImage: state != null || state != ""
                          ? FileImage(File(state))
                          : null,
                    );
                  },
                ),
              ),
              InkWell(
                onTap: () async {
                  String selectedPicker = await _selectPhoto(3, context);
                  if (selectedPicker == "gallery") {
                    await _selectAGallery(3, context);
                  } else if (selectedPicker == "takePhoto") {
                    await _takeAPhoto(3, context);
                  }
                },
                child: BlocBuilder<Image3Cubit, String>(
                  builder: (context, state) {
                    return CircleAvatar(
                      radius: 50,
                      backgroundImage: state != null || state != ""
                          ? FileImage(File(state))
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: size!.height * 0.05),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.read<PageNumber>().changePage(0);
                  },
                  child: Container(
                    height: size!.height * 0.05,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        'Geri Git',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: size!.width * 0.01),
              Expanded(
                child: BlocBuilder<isLoadingCubit, bool>(
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: () {
                        if (!state) {
                          _shareAdvertMethod(context);
                        }
                      },
                      child: Container(
                        height: size!.height * 0.05,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: state
                              ? const ButtonCustomProgressIndicator()
                              : const Text(
                                  'Paylaş',
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
              ),
            ],
          )
        ],
      ),
    );
  }

  _selectPhoto(int photoNumber, BuildContext context) async {
    if (photoNumber >= 2 && photo1 == null) {
      AlertDialog alert = const AlertDialog(
          title: Text("Uyarı!"),
          content: Text("İlk önce birince daire için görsel seçiniz."));

      showDialog(
        context: context,
        builder: (context) {
          return alert;
        },
      );
      return;
    } else if (photo1 != null && photo2 == null && photoNumber == 3) {
      AlertDialog alert = const AlertDialog(
          title: Text("Uyarı!"),
          content: Text("Önce ikinci daire için görsel seçiniz."));

      showDialog(
        context: context,
        builder: (context) {
          return alert;
        },
      );
      return;
    }

    String selectedPicker = "";

    await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(title: Text("Fotoğraf $photoNumber"), children: [
          SimpleDialogOption(
            onPressed: () async {
              selectedPicker = "takePhoto";
              Navigator.pop(context);
            },
            child: const Text("Kamerayı Kullan"),
          ),
          SimpleDialogOption(
            onPressed: () async {
              selectedPicker = "gallery";
              Navigator.pop(context);
            },
            child: const Text("Galeriden Seç"),
          )
        ]);
      },
    );
    return selectedPicker;
  }

  _takeAPhoto(int imageNumber, BuildContext context) async {
    var image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    if (image != null) {
      if (imageNumber == 1) {
        photo1 = File(image.path);
        context.read<Image1Cubit>().image1Change(image.path);
      } else if (imageNumber == 2) {
        photo2 = File(image.path);
        context.read<Image2Cubit>().image2Change(image.path);
      } else {
        photo3 = File(image.path);
        context.read<Image3Cubit>().image3Change(image.path);
      }
    }
    // setState(() {
    //   if (image != null) {
    //     if (imageNumber == 1) {
    //       photo1 = File(image.path);
    //     } else if (imageNumber == 2) {
    //       photo2 = File(image.path);
    //     } else {
    //       photo3 = File(image.path);
    //     }
    //   }
    // });
  }

  _selectAGallery(int imageNumber, BuildContext context) async {
    // Navigator.pop(context);
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80);
    if (image != null) {
      if (imageNumber == 1) {
        photo1 = File(image.path);
        context.read<Image1Cubit>().image1Change(image.path);
      } else if (imageNumber == 2) {
        photo2 = File(image.path);
        context.read<Image2Cubit>().image2Change(image.path);
      } else {
        photo3 = File(image.path);
        context.read<Image3Cubit>().image3Change(image.path);
      }
    }
    // setState(() {
    //   if (image != null) {
    //     if (imageNumber == 1) {
    //       photo1 = File(image.path);
    //     } else if (imageNumber == 2) {
    //       photo2 = File(image.path);
    //     } else {
    //       photo3 = File(image.path);
    //     }
    //   }
    // });
  }

  Future<void> _shareAdvertMethod(BuildContext context) async {
    try {
      String publishedUserId =
          Provider.of<AuthenticationService>(context, listen: false)
              .activeUserId
              .toString();

      context.read<isLoadingCubit>().isLoadingState(true);

      //Photo Uploads
      String? photo1Url, photo2Url, photo3Url;
      if (photo1 != null) {
        photo1Url = await StorageService().AdvertImageUpload(photo1!);
        if (photo2 != null) {
          photo2Url = await StorageService().AdvertImageUpload(photo2!);
          if (photo3 != null) {
            photo3Url = await StorageService().AdvertImageUpload(photo3!);
          }
        }
      }

      if (photo1Url!.isEmpty) {
        context.read<isLoadingCubit>().isLoadingState(false);
        ScaffoldMessenger.of(context).showSnackBar(
          FlashMessages().flasMessages1(
              title: 'Hata!',
              message:
                  'İlan paylaşmak için en az bir görsel eklemek gerekmektedir.',
              type: FlashMessageTypes.error,
              svgPath: 'assets/svgs/error_svg.svg'),
        );
        return;
      }

      //Creating Advert
      await AdoptionFirestoreServices().createAdoption(
          title: title,
          content: content,
          il: il,
          ilce: ilce,
          petType: petType,
          petBreed: petBreed,
          old: old.toString(),
          photoOneUrl: photo1Url,
          photoTwoUrl: photo2Url ?? "",
          photoThreeUrl: photo3Url ?? "",
          publishedUserId: publishedUserId);

      context.read<Image1Cubit>().image1Change("");
      context.read<Image2Cubit>().image2Change("");
      context.read<Image3Cubit>().image3Change("");
      context.read<isLoadingCubit>().isLoadingState(false);
      Navigator.pop(context);
    } catch (ex) {
      context.read<isLoadingCubit>().isLoadingState(false);
      ScaffoldMessenger.of(context).showSnackBar(
        FlashMessages().flasMessages1(
            title: 'Hata!',
            message: 'Bir hata oluştu.',
            type: FlashMessageTypes.error,
            svgPath: 'assets/svgs/error_svg.svg'),
      );
    }
  }
}
