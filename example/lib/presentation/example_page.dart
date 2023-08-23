import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_formx_example/bloc_implementation/bloc_implementation_page.dart';
import 'package:flutter_formx_example/mobx_implementation/mobx_implementation_page.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        'mobx': (context) => const MobXImplementationPage(),
        'bloc': (context) => const BlocImplementationPage(),
      },
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF9FDFE),
        body: Builder(
          builder: (context) => CustomScrollView(
            slivers: [
              const SliverAppBar(
                backgroundColor: Color(0xFF0C152C),
                title: Text('Flutter FormX Example'),
                systemOverlayStyle: SystemUiOverlayStyle.light,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(30),
                  child: SizedBox(
                    height: 30,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Powered by Revelo',
                        style: TextStyle(
                          color: Color(0xFF5AC2D7),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Flutter FormX supports these architectures:',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12,
                      ),
                      child: Material(
                        borderRadius: BorderRadius.circular(8),
                        clipBehavior: Clip.hardEdge,
                        elevation: 1,
                        type: MaterialType.card,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pushNamed('mobx'),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C152C),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            height: 100,
                            child: const Center(
                              child: Text(
                                'MobX implementation',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12,
                      ),
                      child: Material(
                        borderRadius: BorderRadius.circular(8),
                        clipBehavior: Clip.hardEdge,
                        elevation: 1,
                        type: MaterialType.card,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pushNamed('bloc'),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C152C),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            height: 100,
                            child: const Center(
                              child: Text(
                                'Bloc implementation',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
