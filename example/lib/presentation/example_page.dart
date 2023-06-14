import 'package:flutter/material.dart';
import 'package:mobx_form_builder_example/presentation/example_page_view_model.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

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
      home: Scaffold(
        body: SafeArea(
          child: Observer(
            builder: (context) {
              return CustomScrollView(
                slivers: [
                  const SliverAppBar(
                    title: Text('Form Builder Example Page'),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'First Name',
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
                      padding: const EdgeInsets.all(20.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Last Name',
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
                      padding: const EdgeInsets.all(20.0),
                      child: TextField(
                        decoration: const InputDecoration(
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
                  if (_viewModel.showSuccessDialog)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Your form results'),
                            const SizedBox(height: 20),
                            Text('First Name: ${_viewModel.firstName}'),
                            const SizedBox(height: 20),
                            Text('Last Name: ${_viewModel.lastName}'),
                            const SizedBox(height: 20),
                            Text('Email: ${_viewModel.email}'),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  SliverFillRemaining(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: _viewModel.isSubmitButtonEnabled
                            ? _viewModel.submitForm
                            : () {},
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            _viewModel.isSubmitButtonEnabled
                                ? Colors.blue
                                : Colors.grey,
                          ),
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
      ),
    );
  }
}
