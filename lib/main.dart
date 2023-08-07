import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' hide Image;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:modulab_tflite/constants.dart';
import 'package:modulab_tflite/prediction.dart';
import 'package:tflite/tflite.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DrawScreen(),
    );
  }
}

class DrawScreen extends StatefulWidget {
  const DrawScreen({Key? key}) : super(key: key);

  @override
  State<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends State<DrawScreen> {
  final _points = <Offset?>[];
  final _recognizer = Recognizer();
  var _prediction = <Prediction>[];
  bool initialize = false;
  int predictNum = 0;

  Future<Uint8List> _previewImage() async {
    return await _recognizer.previewImage(_points);
  }

  void _initModel() async {
    var res = await _recognizer.loadModel();
  }

  void _recognize() async {
    int foo = await _recognizer.classifyDrawing(_points);
    List<dynamic> pred = await _recognizer.recognize(_points);

    setState(() {
      predictNum = foo;
      _prediction = pred.map((json) => Prediction.fromJson(json)).toList();
      // print("_prediction: ${_prediction}");
      for (var element in _prediction) {
        print("${element.index} ${element.label} ${element.confidence}");
      }
    });
  }

  Widget _mnistPreviewImage() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.black,
      child: FutureBuilder(
        future: _previewImage(),
        builder: (BuildContext _, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.fill,
            );
          } else {
            return const Center(
              child: Text('Error'),
            );
          }
        },
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initModel();
  }

  @override
  dispose() {
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digit Recognizer'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: Constants.canvasSize + Constants.borderSize * 2,
            height: Constants.canvasSize + Constants.borderSize * 2,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: Constants.borderSize,
              ),
            ),
            child: GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                Offset _localPosition = details.localPosition;
                if (_localPosition.dx >= 0 &&
                    _localPosition.dx <= Constants.canvasSize &&
                    _localPosition.dy >= 0 &&
                    _localPosition.dy <= Constants.canvasSize) {
                  setState(() {
                    _points.add(_localPosition);
                  });
                }
              },
              onPanEnd: (DragEndDetails details) {
                _points.add(null);
                _recognize();
              },
              child: CustomPaint(
                painter: DrawingPainter(_points),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // const Expanded(
              //   child: Padding(
              //     padding: EdgeInsets.all(8.0),
              //     child: Column(
              //       children: <Widget>[
              //         // Text(
              //         //   'MNIST database of handwritten digits',
              //         //   style: TextStyle(
              //         //     fontWeight: FontWeight.bold,
              //         //   ),
              //         // ),
              //         // Text(
              //         //   'The digits have been size-normalized and centered in a fixed-size images (28 x 28)',
              //         // )
              //       ],
              //     ),
              //   ),
              // ),
              _mnistPreviewImage(),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Text("예측"),
          Text(
            "$predictNum",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 42,
            ),
          )
          // PredictionWidget(
          //   predictions: _prediction ?? [],
          // )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.clear),
        onPressed: () {
          _points.clear();
          _prediction.clear();
          setState(() {});
        },
      ),
    );
  }
}
//
// class Classifier {
//   classifyDrawing(List<Offset> points) async {
//     final picture = toPicture(points);
//     final image = await picture.toImage(28, 28);
//     ByteData imgBytes = await image.toByteData();
//   }
//
//   Future<int> getPred(Uint8List imaAsList) async {}
// }
//
// ui.Picture toPicture(List<Offset> points) {
//   final whitePoint = Paint
// }

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  DrawingPainter(this.points);

  final Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.black
    ..strokeWidth = Constants.strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, _paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Recognizer {
  Future loadModel() {
    Tflite.close();
    return Tflite.loadModel(
      model: "assets/flutter_mnist_model.tflite",
      labels: "assets/labels.txt",
    );
  }

  Picture _pointsToPicture(List<Offset?> points) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, canvasCullRect)
      ..scale(Constants.mnistImageSize / Constants.canvasSize);

    canvas.drawRect(
        Rect.fromLTWH(0, 0, Constants.imageSize, Constants.imageSize), bgPaint);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, whitePaint);
      }
    }
    return recorder.endRecording();
  }

  classifyDrawing(List<Offset?> point) async {
    print("classifyDrawing");
    final picture = _pointsToPicture(point);
    final image = await picture.toImage(28, 28);
    ByteData? imgBytes = await image.toByteData();
    var imgAsList = imgBytes?.buffer.asUint8List();
    int predict = await getPred(imgAsList!);
    return predict;
  }

  Future<int> getPred(Uint8List imgAsList) async {
    print("getPred");
    List resultBytes = List.filled(28 * 28, 0);
    // final buffer = Float32List.view(resultBytes.buffer);

    int index = 0;

    for (int i = 0; i < imgAsList.lengthInBytes; i += 4) {
      final r = imgAsList[i];
      final g = imgAsList[i + 1];
      final b = imgAsList[i + 2];
      resultBytes[index++] = (r + g + b) / 3.0 / 255.0;
    }
    // print("resultBytes.buffer.asUint8List(): ${resultBytes.buffer.asUint8List()}");

    var input = resultBytes.reshape([1, 28, 28, 1]);
    var output = List.filled(10, 0).reshape([1, 10]);
    InterpreterOptions interpreterOptions = InterpreterOptions();
    // print(input);
    if (Platform.isAndroid) {
      interpreterOptions.addDelegate(XNNPackDelegate());
    }
    try {
      Interpreter interpreter = await Interpreter.fromAsset(
        "assets/mnist.tflite",
        options: interpreterOptions,
      );
      interpreter.run(input, output);
      print(output);
    } catch (e) {
      print(e);
    }
    double highestProb = 0;
    int digitPred = 0;

    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > highestProb) {
        highestProb = output[0][i];
        digitPred = i;
      }
    }
    return digitPred;
  }

  Future<Uint8List> _imageToByteListUint8(Picture pic, int size) async {
    final img = await pic.toImage(size, size);
    final imgBytes = await img.toByteData();
    final resultBytes = Float32List(size * size);
    final buffer = Float32List.view(resultBytes.buffer);

    int index = 0;

    for (int i = 0; i < imgBytes!.lengthInBytes; i += 4) {
      final r = imgBytes.getUint8(i);
      final g = imgBytes.getUint8(i + 1);
      final b = imgBytes.getUint8(i + 2);
      buffer[index++] = (r + g + b) / 3.0 / 255.0;
    }
    // print("resultBytes.buffer.asUint8List(): ${resultBytes.buffer.asUint8List()}");

    return resultBytes.buffer.asUint8List();
  }

  Future recognize(List<Offset?> points) async {
    final picture = _pointsToPicture(points);
    Uint8List bytes =
        await _imageToByteListUint8(picture, Constants.mnistImageSize);
    return _predict(bytes);
  }

  Future _predict(Uint8List bytes) {
    return Tflite.runModelOnBinary(binary: bytes);
  }

  Future<Uint8List> previewImage(List<Offset?> points) async {
    final picture = _pointsToPicture(points);
    final image = await picture.toImage(
        Constants.mnistImageSize, Constants.mnistImageSize);
    var pngBytes = await image.toByteData(format: ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }
}

class PredictionWidget extends StatelessWidget {
  final List<Prediction> predictions;

  PredictionWidget({Key? key, required this.predictions}) : super(key: key);

  Widget _numberWidget(int num, Prediction prediction) {
    return Column(
      children: <Widget>[
        Text(
          '$num',
          style: TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Colors.red.withOpacity(
              (prediction.confidence! * 2).clamp(0, 1).toDouble(),
            ),
          ),
        ),
        Text(
          '${prediction.confidence?.toStringAsFixed(3)}',
          style: const TextStyle(
            fontSize: 12,
          ),
        )
      ],
    );
  }

  List<dynamic> getPredictionStyles(List<Prediction> predictions) {
    List<dynamic> data = [
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      null
    ];
    for (var prediction in predictions) {
      data[prediction.index!] = prediction;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    var styles = getPredictionStyles(predictions ?? []);

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            for (var i = 0; i < 5; i++) _numberWidget(i, styles[i])
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            for (var i = 5; i < 10; i++) _numberWidget(i, styles[i])
          ],
        )
      ],
    );
  }
}
