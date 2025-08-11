import 'package:flutter/material.dart';

// 아직 구현되지 않은 화면들의 임시 위젯
// TODO: 각 화면을 실제로 구현할 때 이 파일에서 제거하고 별도 파일로 이동

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('Profile Screen - To be implemented'),
      ),
    );
  }
}

class ModuleDetailScreen extends StatelessWidget {
  final String title;
  const ModuleDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Module Detail: $title'),
      ),
    );
  }
}

class ModuleReviewScreen extends StatelessWidget {
  final String title;
  const ModuleReviewScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Module Review: $title'),
      ),
    );
  }
}

class CompletedModulesScreen extends StatelessWidget {
  const CompletedModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Modules'),
      ),
      body: const Center(
        child: Text('완료된 모듈 목록 화면'),
      ),
    );
  }
}

class TopicModulesScreen extends StatelessWidget {
  final String topic;
  const TopicModulesScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic),
      ),
      body: Center(
        child: Text('$topic 관련 모듈 목록'),
      ),
    );
  }
}