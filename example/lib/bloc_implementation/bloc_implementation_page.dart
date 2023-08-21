import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_formx/flutter_formx.dart';
import 'package:flutter_formx_example/custom_validators/checked_validator.dart';
import 'package:flutter_formx_example/custom_validators/salary_validator.dart';

class BlocImplementationPage extends StatefulWidget {
  const BlocImplementationPage({super.key});

  @override
  State<BlocImplementationPage> createState() => _BlocImplementationPageState();
}

class _BlocImplementationPageState extends State<BlocImplementationPage> {
  bool showSuccessInfo = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormXCubit<String>()
        ..setupForm(
          {
            'email': FormXField.from(
              value: '',
              validators: [
                RequiredFieldValidator('Your email is required'),
              ],
            ),
            'career': FormXField.from(
              value: '',
              validators: const [],
            ),
            'salaryExpectation': FormXField<int>.from(
              value: 3100,
              validators: [
                SalaryValidator('You deserve a little more 😉'),
              ],
              onValidationError: _logValidationError,
            ),
            'acceptTerms': FormXField<bool>.from(
              value: false,
              validators: [
                CheckedValidator('You must accept our Terms and Conditions'),
              ],
              onValidationError: _logValidationError,
            ),
          },
        ),
      child: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FDFE),
          body: BlocBuilder<FormXCubit<String>, FormXCubitState>(
            builder: (context, state) {
              return CustomScrollView(
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
                        onChanged: (value) => context
                            .read<FormXCubit<String>>()
                            .updateAndValidateField(
                              value,
                              'email',
                            ),
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
                        onChanged: (value) => context
                            .read<FormXCubit<String>>()
                            .updateAndValidateField(
                              value,
                              'career',
                            ),
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
                                    showValueIndicator:
                                        ShowValueIndicator.onlyForContinuous,
                                  ),
                                  child: Slider(
                                    value: state
                                        .getFieldValue('salaryExpectation')
                                        .toDouble(),
                                    min: 500,
                                    max: 20000,
                                    divisions: 15,
                                    label: 'Salary Expectation',
                                    onChanged: (value) => context
                                        .read<FormXCubit<String>>()
                                        .updateAndValidateField(
                                          value,
                                          'salaryExpectation',
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (state.getFieldErrorMessage('salaryExpectation') !=
                              null)
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
                                onChanged: (value) => context
                                    .read<FormXCubit<String>>()
                                    .updateAndValidateField(
                                      value,
                                      'acceptTerms',
                                    ),
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
                  if (showSuccessInfo)
                    SliverToBoxAdapter(
                      child: Container(
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
                            Text(
                                'Accepted terms: ${state.getFieldValue('acceptTerms')}'),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 40),
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                        onPressed: state.isFormValid
                            ? () => setState(() {
                                  showSuccessInfo = true;
                                })
                            : () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: state.isFormValid
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
        );
      }),
    );
  }

  void _logValidationError() {
    if (kDebugMode) {
      print('Validation error!');
    }
  }
}
