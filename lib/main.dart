import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '无限计时器',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TimerPage(),
    );
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with WidgetsBindingObserver {
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadState(); // 读取存储的状态
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 生命周期监听
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadState();
    }
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final startMillis = prefs.getInt('startTime');
    final elapsedMillis = prefs.getInt('elapsed') ?? 0;
    final running = prefs.getBool('isRunning') ?? false;

    setState(() {
      _elapsed = Duration(milliseconds: elapsedMillis);
      _isRunning = running;
      if (startMillis != null) {
        _startTime = DateTime.fromMillisecondsSinceEpoch(startMillis);
      }
    });

    if (_isRunning && _startTime != null) {
      _startTimer();
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('elapsed', _elapsed.inMilliseconds);
    await prefs.setBool('isRunning', _isRunning);
    if (_startTime != null) {
      await prefs.setInt('startTime', _startTime!.millisecondsSinceEpoch);
    }
  }

  void _startTimer() {
    if (!_isRunning) {
      _startTime = DateTime.now().subtract(_elapsed);
      _isRunning = true;
      _saveState();
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    });
  }

  void _stopTimer() {
    if (_isRunning) {
      _timer?.cancel();
      _elapsed = DateTime.now().difference(_startTime!);
      _isRunning = false;
      _saveState();
      setState(() {});
    }
  }

  void _resetTimer() async {
    _timer?.cancel();
    setState(() {
      _elapsed = Duration.zero;
      _startTime = null;
      _isRunning = false;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 清空存储
  }

  @override
  Widget build(BuildContext context) {
    // final days = _elapsed.inDays;
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes % 60;
    final seconds = _elapsed.inSeconds % 60;

    return Scaffold(
      // appBar: AppBar(title: const Text("计时器")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${hours.toString().padLeft(2, '0')}:"
              "${minutes.toString().padLeft(2, '0')}:"
              "${seconds.toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: _startTimer, child: const Text("开始")),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _stopTimer, child: const Text("暂停")),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _resetTimer, child: const Text("重置")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
