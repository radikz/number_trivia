import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/number_trivia/presentation/bloc/number_trivia/number_trivia_bloc.dart';
import 'features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'injection.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<NumberTriviaBloc>(),
      child: MaterialApp(
        title: 'Number Trivia',
        theme: ThemeData(
          primaryColor: Colors.green.shade800,
        ),
        home: NumberTriviaPage(),
      ),
    );
  }
}
