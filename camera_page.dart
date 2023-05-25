import 'package:ediya/main.dart';

import 'constant.dart';
import 'sp_helper.dart';
import 'util.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'dart:io';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'api_util.dart';

bool canStartImageStream = true;

class CameraPage extends StatefulWidget {
  final SPHelper helper;
  final CameraDescription camera;

  const CameraPage(this.camera, this.helper, {super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  final _barcodeScanner = BarcodeScanner();

  void barcodeImageStream() async {
    while (true) {
      if (pageIndex == 1 || pageIndex == 2) {
        await Future.delayed(const Duration(milliseconds: 10));
        continue;
      }
      await Future.delayed(const Duration(milliseconds: 100));
      if (canStartImageStream && mounted) {
        barcodeProcess();
      }
    }
  }

  void barcodeProcess() async {
    int barcodeCounts = BARCODE_COUNTS; //너무 빨리 찍히는 거 방지
    await _controller.startImageStream((CameraImage image) async {
      canStartImageStream = false;
      InputImageData iid = getIID(image);
      Uint8List bytes = getBytes(image);
      if (pageIndex == 1 || pageIndex == 2) {
        _controller.stopImageStream();
        canStartImageStream = true;
      }

      final InputImage inputImage =
          InputImage.fromBytes(bytes: bytes, inputImageData: iid);
      _barcodeScanner
          .processImage(inputImage)
          .then((List<Barcode> barcodes) async {
        if (barcodeCounts > 0) {
          barcodeCounts--;
        } else {
          for (Barcode barcode in barcodes) {
            barcodeCounts = BARCODE_COUNTS;
            final bar = barcode.rawValue.toString();
            if (await isContains(bar) && !canStartImageStream) {
              await Future.delayed(const Duration(milliseconds: 10));
              String name = await getPatientsName(bar);
              _controller.stopImageStream();
              if (!mounted) return;
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => TakePictureScreen(
                            controller: _controller,
                            barcode: bar,
                            helper: widget.helper,
                            name: name
                          )));
            } else {
              // getToast("등록되지 않은 바코드입니다.");
              setState(() {});
            }}}});
    });
  }
  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _controller.initialize().then((_) => barcodeImageStream());
  }

  @override
  void dispose() {
    // 카메라 컨트롤러 해제
    _controller.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text("환자 찾기", style: TITLE_TEXTSTYLE),
        ),
        child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                  height: h, width: w,
                  child: CameraPreview(_controller)
              ),
              Container(
                  height: h / 4, width: w / 1.1,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 3.0, color: BARCODE_COLOR
                      ))),
              Container(
                  height: 1, width: w / 1.5,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 2.0, color: BARCODE_COLOR
                      )))]));
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraController controller;
  final SPHelper helper;
  final String barcode;
  final String name;

  const TakePictureScreen({
    Key? key,
    required this.controller,
    required this.barcode,
    required this.helper,
    required this.name,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late int time;
  bool isDisposed = false;

  String imagePath(String barcode, String name) {
    var newFileName = "$name-${barcode}_${nowString()}.png";
    return newFileName;
  }

  Future<void> saveImagePath(XFile? tempImage) async {
    if (tempImage == null) return;
    String dir = (await getApplicationDocumentsDirectory()).path;
    String newPath = join(dir, imagePath(widget.barcode, widget.name));

    File temp = await File(tempImage.path).copy(newPath);
    GallerySaver.saveImage(temp.path, albumName: widget.name);
    // await uploadImage(temp);
  }

  @override
  void initState() {
    super.initState();
    // 카메라 컨트롤러 초기화
    time = TIMER_MAX;
    _controller = widget.controller;
    timer();
  }

  void timer() {
    const oneSec = Duration(seconds: 1);
    if (!isDisposed) {
      Timer.periodic(
          oneSec,
              (_) {
            if (time == 0 && !canStartImageStream) {
              // takePicture();
              print("찰칵");
              time = TIMER_MAX;
              canStartImageStream = true;
              if (!mounted) return;
              Navigator.of(context).pop();
              return;
            }
            if (time > 0) {
              if (mounted){
                setState(() {
                  time--;
                });
              }}});
    }
  }

  void takePicture() async {
    try {
      // 사진 찍기
      final image = await _controller.takePicture();
      // 찍은 사진을 저장하기 위한 경로 생성
      saveImagePath(image);
    } catch (e) {
      // 에러 발생 시 처리
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    canStartImageStream = true;
    isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            middle: Text('${widget.name} 님')),
        child: Stack(
            children: [
              SizedBox(
                  width: w, height: h,
                  child: CameraPreview(_controller)
              ),
              Column(
                  children: [
                    const SizedBox(
                      width: 200, height: 100,
                    ),
                    SizedBox(
                        width: 200, height: 200,
                        child: Text(time.toString(), style: DEFAULT_TEXTSTYLE)
                    )])]));
  }
}

InputImageData getIID(CameraImage image) {
  return InputImageData(
      inputImageFormat: InputImageFormatValue.fromRawValue(image.format.raw)!,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      imageRotation: InputImageRotation.rotation90deg,
      planeData: image.planes.map((Plane plane) => InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      )).toList());
}

Uint8List getBytes(CameraImage image) {
  return Uint8List.fromList(
      image.planes.fold(<int>[], (List<int> previousValue, element) => previousValue
        ..addAll(element.bytes)));
}

