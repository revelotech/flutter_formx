import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx_form_builder_example/presentation/example_page_view_model.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  late ExamplePageViewModel _viewModel;

  @override
  void initState() {
    _viewModel = ExamplePageViewModel()..onViewReady();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Observer(
          builder: (context) {
            return CustomScrollView(
              slivers: [
                const SliverAppBar(
                  backgroundColor: Color(0xFF5AC2D7),
                  title: Text('MobX Form Builder Example'),
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
                              color: Color(0xFF3A7C92),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 30,
                      bottom: 16,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'First Name*',
                        errorText: _viewModel.firstNameError,
                        errorStyle: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      onChanged: (value) {
                        _viewModel.onValueChanged(
                          fieldName: 'firstName',
                          newValue: value,
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Last Name*',
                        errorText: _viewModel.lastNameError,
                        errorStyle: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      onChanged: (value) {
                        _viewModel.onValueChanged(
                          fieldName: 'lastName',
                          newValue: value,
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                      ),
                      onChanged: (value) {
                        _viewModel.onValueChanged(
                          fieldName: 'email',
                          newValue: value,
                        );
                      },
                    ),
                  ),
                ),
                if (_viewModel.showSuccessInfo)
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 216, 244, 249),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Form results',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('First Name: ${_viewModel.firstName}'),
                          const SizedBox(height: 14),
                          Text('Last Name: ${_viewModel.lastName}'),
                          const SizedBox(height: 14),
                          Text('Email: ${_viewModel.email}'),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: _viewModel.isSubmitButtonEnabled ? _viewModel.submitForm : () {},
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: _viewModel.isSubmitButtonEnabled
                            ? const Color(0xFF0C152C)
                            : Colors.grey,
                      ),
                      child: const Text('Submit'),
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
