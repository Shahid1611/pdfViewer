

import 'dart:io';

import 'package:get/get.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:math';

class HomeController extends GetxController{
  var textStr = "".obs;
  var buttonsEnabled = true.obs;
  var pdfDoc ;



  /// Reads a random page of the document
  Future<void> readRandomPage() async {
    if (pdfDoc == null) {
      return;
    }
    buttonsEnabled.value = false;

    String text =
    await pdfDoc!.pageAt(Random().nextInt(pdfDoc!.length) + 1).text;
    textStr.value = text;
    buttonsEnabled.value = true;
    update();

  }

  /// Reads the whole document
  Future<void> readWholeDoc() async {
    if (pdfDoc == null) {
      return;
    }
    buttonsEnabled.value = false;

    String text = await pdfDoc!.text;

      textStr.value = text;
      buttonsEnabled.value = true;
    update();

  }



}