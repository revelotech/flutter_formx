import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_formx_example/bloc_implementation/bloc_implementation_page.dart';
import 'package:flutter_formx_example/mobx_implementation/mobx_implementation_page.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

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
        body: Observer(
          builder: (context) {
            return CustomScrollView(
              //TODO: improve this UI
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed('mobx'),
                      child: const Text('MobX implementation'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed('bloc'),
                      child: const Text('Bloc implementation'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
