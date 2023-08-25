import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_formx/flutter_formx.dart';
import 'package:flutter_formx_example/vanilla_implementation/vanilla_implementation_page_view_model.dart';

class VanillaImplementationPage extends StatefulWidget {
  const VanillaImplementationPage({super.key});

  @override
  State<VanillaImplementationPage> createState() => _VanillaImplementationPageState();
}

class _VanillaImplementationPageState extends State<VanillaImplementationPage> {
  late VanillaImplementationPageViewModel _viewModel;

  @override
  void initState() {
    _viewModel = VanillaImplementationPageViewModel()..onViewReady();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FDFE),
      body: ValueListenableBuilder<FormXState<String>>(
          valueListenable: _viewModel.state,
          builder: (context, state, widget) => CustomScrollView(
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
                        )),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Job application form',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Your email*',
                          errorText: state.getFieldErrorMessage('email'),
                          errorStyle: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        onChanged: (value) {
                          _viewModel.onTextChanged(
                            fieldName: 'email',
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
                          labelText: 'Career',
                        ),
                        onChanged: (value) {
                          _viewModel.onTextChanged(
                            fieldName: 'career',
                            newValue: value,
                          );
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Salary expectation'),
                          Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  'US\$ ${state.getFieldValue('salaryExpectation').toString()}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: const SliderThemeData(
                                    showValueIndicator: ShowValueIndicator.onlyForContinuous,
                                  ),
                                  child: Slider(
                                    value: state.getFieldValue('salaryExpectation').toDouble(),
                                    min: 500,
                                    max: 20000,
                                    divisions: 15,
                                    label: state.getFieldValue('salaryExpectation').toString(),
                                    onChanged: (newValue) => _viewModel.onIncomeChanged(
                                      newValue.toInt(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (state.getFieldErrorMessage('salaryExpectation') != null)
                            Text(
                              state.getFieldErrorMessage('salaryExpectation')!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: state.getFieldValue('acceptTerms'),
                                onChanged: (value) {
                                  _viewModel.onAcceptTermsChanged(value ?? false);
                                },
                              ),
                              const Expanded(
                                child: Text(
                                  'I accept the Terms and Conditions.',
                                ),
                              )
                            ],
                          ),
                          if (state.getFieldErrorMessage('acceptTerms') != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Text(
                                state.getFieldErrorMessage('acceptTerms')!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ValueListenableBuilder(
                      valueListenable: _viewModel.showSuccessInfo,
                      builder: (context, showSuccessInfo, widget) => showSuccessInfo
                          ? Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFBDE7EF),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              margin: const EdgeInsets.all(24.0),
                              padding: const EdgeInsets.all(12.0),
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
                                  Text('Email: ${state.getFieldValue('email')}'),
                                  const SizedBox(height: 14),
                                  Text('Career: ${state.getFieldValue('career')}'),
                                  const SizedBox(height: 14),
                                  Text(
                                    'Salary expectation: ${state.getFieldValue('salaryExpectation')}',
                                  ),
                                  const SizedBox(height: 14),
                                  Text('Accepted terms: ${state.getFieldValue('acceptTerms')}'),
                                  const SizedBox(height: 14),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: state.isFormValid ? _viewModel.submitForm : () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor:
                              state.isFormValid ? const Color(0xFF0C152C) : Colors.grey,
                        ),
                        child: const Text('Submit'),
                      ),
                    ),
                  ),
                ],
              )),
    );
  }
}
