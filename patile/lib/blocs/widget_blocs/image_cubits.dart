import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';

class Image1Cubit extends Cubit<String> {
  Image1Cubit() : super("");

  void image1Change(String path) {
    emit(path);
  }
}

class Image2Cubit extends Cubit<String> {
  Image2Cubit() : super("");

  void image2Change(String path) {
    emit(path);
  }
}

class Image3Cubit extends Cubit<String> {
  Image3Cubit() : super("");

  void image3Change(String path) {
    emit(path);
  }
}

class ProfilePhotoCubit extends Cubit<String> {
  ProfilePhotoCubit() : super("");

  void profilePhotoChange(String path) {
    emit(path);
  }
}

class CarouselIndexChangeCubits extends Cubit<int> {
  CarouselIndexChangeCubits() : super(0);

  void changeIndex(int index) {
    emit(index);
  }
}

class ImageListChangeCubit extends Cubit<List<XFile>> {
  ImageListChangeCubit() : super([]);

  void changeImages(List<XFile> images) {
    emit(images);
  }
}
