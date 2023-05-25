import 'package:camera/camera.dart';
import 'package:ediya/camera_page.dart';
import 'package:ediya/set_data.dart';
import 'package:ediya/sp_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ediya/list_page.dart';
import 'package:flutter/cupertino.dart';

int pageIndex = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras[1]));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  const MyApp(this.camera, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      theme: ThemeData(
          fontFamily: 'GangWon'
      ),
      supportedLocales: const [
        Locale('ko', ''),
        Locale('en', ''),
      ],
      home: MainPage(camera),
    );
  }
}


class MainPage extends StatefulWidget {
  final CameraDescription camera;
  const MainPage(this.camera, {super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  final SPHelper helper = SPHelper();
  final CupertinoTabController _controller = CupertinoTabController();

  final List<BottomNavigationBarItem> items = [
    const BottomNavigationBarItem(icon: Icon(CupertinoIcons.search), label: "찾기"),
    const BottomNavigationBarItem(icon: Icon(CupertinoIcons.person_add_solid), label: "추가"),
    const BottomNavigationBarItem(icon: Icon(CupertinoIcons.list_bullet), label: "목록"),
  ];

  @override
  void initState() {
    helper.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(items: items),
      controller: _controller,
      tabBuilder: (context, index) {
        pageIndex = _controller.index;
        switch(index) {
          case 1:
              return SetData(helper);
          case 2:
              return ListPage(helper);
          default:
              return CameraPage(widget.camera, helper);
        }
      },
    );
  }
}