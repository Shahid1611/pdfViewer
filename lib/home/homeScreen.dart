import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:pdfextract/home/homeController.dart';
import 'package:text_to_speech/text_to_speech.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _homeController = Get.put(HomeController());
  var pdfDoc  ;
  final String defaultLanguage = 'en-US';

  TextToSpeech tts = TextToSpeech();

  double volume = 1; // Range: 0-1
  double rate = 1.0; // Range: 0-2
  double pitch = 1.0; // Range: 0-2

  String? language;
  String? languageCode;
  List<String> languages = <String>[];
  List<String> languageCodes = <String>[];
  String? voice;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initLanguages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: const Text('PDF Reader and Voice'),
          ),
          body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                TextButton(
                  child: Text(
                    "Pick PDF document",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.all(5),
                      backgroundColor: Colors.blueAccent),
                  onPressed: ()=>pickPDFText(),
                ),
                TextButton(
                  child: Text(
                    "Read random page",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.all(5),
                      backgroundColor: Colors.blueAccent),
                  onPressed: _homeController.buttonsEnabled.value ? _homeController.readRandomPage : () {},
                ),
                TextButton(
                  child: Text(
                    "Read whole document",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.all(5),
                      backgroundColor: Colors.blueAccent),
                  onPressed: _homeController.buttonsEnabled.value ? _homeController.readWholeDoc : () {

                  },
                ),
                 Padding(
                  child: Text(
                    pdfDoc == null
                        ? "Pick a new PDF document and wait for it to load..."
                        : "PDF document loaded, ${pdfDoc!.length} pages\n",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.all(15),
                ),
                Obx(() =>  Padding(
                  child: Text(
                    _homeController.textStr.value == "" ? "" : "Text: ",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.all(15),
                ),),

                Obx(() => Text(_homeController.textStr.value)),

                Row(
                  children: <Widget>[
                    const Text('Volume'),
                    Expanded(
                      child: Slider(
                        value: volume,
                        min: 0,
                        max: 1,
                        label: volume.round().toString(),
                        onChanged: (double value) {
                          initLanguages();
                          setState(() {
                            volume = value;
                          });
                        },
                      ),
                    ),
                    Text('(${volume.toStringAsFixed(2)})'),
                  ],
                ),


                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          child: const Text('Stop'),
                          onPressed: () {
                            tts.stop();
                          },
                        ),
                      ),
                    ),
                    if (supportPause)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                            child: const Text('Pause'),
                            onPressed: () {
                              tts.pause();
                            },
                          ),
                        ),
                      ),
                    if (supportResume)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                            child: const Text('Resume'),
                            onPressed: () {
                              tts.resume();
                            },
                          ),
                        ),
                      ),
                    Expanded(
                        child: Container(
                          child: ElevatedButton(
                            child: const Text('Speak'),
                            onPressed: () {
                              if(_homeController.textStr.value != null){
                                speak();

                              }
                            },
                          ),
                        ))
                  ],
                )

              ],
            ),

          ));

  }
  bool get supportPause => defaultTargetPlatform != TargetPlatform.android;

  bool get supportResume => defaultTargetPlatform != TargetPlatform.android;

  void speak() {
    tts.setVolume(volume);
    tts.setRate(rate);
    if (languageCode != null) {
      tts.setLanguage(languageCode!);
    }
    tts.setPitch(pitch);
    tts.speak(_homeController.textStr.value);
  }

  Future pickPDFText() async {
    var filePickerResult = await FilePicker.platform.pickFiles();
    if (filePickerResult != null) {
        pdfDoc = await PDFDoc.fromPath(filePickerResult.files.single.path!);
        _homeController.pdfDoc =pdfDoc;
        setState((){});

    }
  }

  Future<void> initLanguages() async {
    /// populate lang code (i.e. en-US)
    languageCodes = await tts.getLanguages();

    /// populate displayed language (i.e. English)
    final List<String>? displayLanguages = await tts.getDisplayLanguages();
    if (displayLanguages == null) {
      return;
    }

    languages.clear();
    for (final dynamic lang in displayLanguages) {
      languages.add(lang as String);
    }

    final String? defaultLangCode = await tts.getDefaultLanguage();
    if (defaultLangCode != null && languageCodes.contains(defaultLangCode)) {
      languageCode = defaultLangCode;
    } else {
      languageCode = defaultLanguage;
    }
    language = await tts.getDisplayLanguageByCode(languageCode!);

    /// get voice
    voice = await getVoiceByLang(languageCode!);

    if (mounted) {
      setState(() {});
    }
  }

  Future<String?> getVoiceByLang(String lang) async {
    final List<String>? voices = await tts.getVoiceByLang(languageCode!);
    if (voices != null && voices.isNotEmpty) {
      return voices.first;
    }
    return null;
  }


}
