import 'dart:io';
import 'dart:math';

import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFScreen extends StatefulWidget {
  final String? path;
  final String? pdfName;
  final PdfDocument document;
  bool downloadReceipt;
  bool isShare;

  PDFScreen(
      {Key? key,
      this.path,
      this.pdfName,
      required this.document,
      this.downloadReceipt = true,
      this.isShare = false})
      : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Receipt"),
      ),
      body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: OutlinedButton(
                              onPressed: () {
                                saveFile(context,
                                    isDownload: widget.downloadReceipt);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Download",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Icon(
                                    Icons.download,
                                    color: APIService.appPrimaryColor,
                                  )
                                ],
                              ))),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                          child: OutlinedButton(
                              onPressed: () {
                                saveFile(context, isDownload: false);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Share",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Icon(
                                    Icons.share,
                                    color: APIService.appSecondaryColor,
                                  )
                                ],
                              ))),
                    ],
                  )),
              const SizedBox(
                height: 12,
              ),
              Expanded(
                  child: pdfrx.PdfViewer.file(
                widget.path ?? "",
              ))
            ],
          )),
    );
  }

  // saveFile(BuildContext context, {isDownload = true}) async {
  //   if (Platform.isAndroid) {
  //     try {
  //       String receiptPath = "";
  //       String receipt = "${widget.pdfName}.pdf";

  //       Directory directory = Directory("");
  //       directory = Directory("/storage/emulated/0/Download");
  //       AppLogger.appLogD(
  //           tag: "pdf file",
  //           message: "Copying file to ==========>${directory.path}");
  //       receiptPath = "${directory.path}/$receipt";
  //       await requestStoragePermission();
  //       File(widget.path ?? "").copy(receiptPath).then((value) {
  //         if (isDownload) {
  //           CommonUtils.showActionSnackBar(
  //             context: context,
  //             message: "$receipt saved to download",
  //           );
  //         } else {
  //           openFile(receiptPath, widget.pdfName ?? "", isDownload: isDownload);
  //         }
  //       });
  //     } catch (e) {}
  //   }
  // }

  // requestStoragePermission() async {
  //   var status = await Permission.storage.status;
  //   if (!status.isGranted) {
  //     await Permission.manageExternalStorage.request();
  //   }
  // }

  saveFile(BuildContext context, {isDownload = true}) async {
    try {
      String receiptID = generateRandomFourDigitNumber();
      String receiptPath = "";
      String receipt = "${widget.pdfName}$receiptID.pdf";

      Directory directory = Platform.isAndroid
          ? Directory("")
          : await getApplicationSupportDirectory();

      if (Platform.isAndroid) {
        directory = Directory("/storage/emulated/0/Documents");
        AppLogger.appLogD(
            tag: "pdf file",
            message: "Copying file to ==========>${directory.path}");
      }

      receiptPath = "${directory.path}/$receipt";
      await requestStoragePermission();
      File(widget.path ?? "").copy(receiptPath).then((value) {
        if (isDownload) {
          CommonUtils.showActionSnackBar(
            context: context,
            message: "$receipt saved successfully",
          );
        } else {
          openFile(receiptPath, widget.pdfName ?? "", isDownload: isDownload);
        }
      });
    } catch (e) {}
  }

  requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      print("Not Granted");
      await Permission.manageExternalStorage.request();
    } else {
      print("Granted");
    }
  }

  String generateRandomFourDigitNumber() {
    Random random = Random();
    int randomNumber =
        1000 + random.nextInt(9000); // Generates a number between 1000 and 9999
    return randomNumber.toString();
  }

  openFile(String filePath, String pdfName, {isDownload = true}) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempFilePath = '${tempDir.path}/$pdfName.pdf';
    File tempFile = File(tempFilePath);
    await tempFile.writeAsBytes(await File(filePath).readAsBytes());

    if (isDownload) {
      try {
        OpenFile.open(tempFilePath);
      } catch (e) {
        AppLogger.appLogD(tag: "file log....", message: e.toString());
      }
    } else {
      Share.shareXFiles([XFile(tempFilePath)], subject: 'Sharing PDF');
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.document.dispose();
  }
}
