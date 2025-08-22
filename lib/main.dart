import 'dart:async';
import 'package:flutter/material.dart';

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
  DateTime? _startTime; // 计时开始时间
  Duration _elapsed = Duration.zero; // 已经过的时间
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // App 生命周期变化处理（切后台/前台）
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isRunning && _startTime != null) {
      // 回到前台时，重新计算开始时间，保持计时连续
      _startTime = DateTime.now().subtract(_elapsed);
    }
  }

  void _startTimer() {
    if (!_isRunning) {
      _startTime = DateTime.now().subtract(_elapsed);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _elapsed = DateTime.now().difference(_startTime!);
        });
      });
      _isRunning = true;
    }
  }

  void _stopTimer() {
    if (_isRunning) {
      _timer?.cancel();
      _elapsed = DateTime.now().difference(_startTime!);
      _isRunning = false;
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _elapsed = Duration.zero;
      _startTime = null;
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hours = _elapsed.inHours;
    final minutes = (_elapsed.inMinutes % 60);
    final seconds = (_elapsed.inSeconds % 60);

    return Scaffold(
      appBar: AppBar(title: const Text("计时器")),
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
