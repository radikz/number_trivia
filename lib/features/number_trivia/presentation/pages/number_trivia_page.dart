import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia/number_trivia_bloc.dart';
import 'package:number_trivia/injection.dart';

import '../widgets/widgets.dart';


class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            // Top half
            BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
              builder: (context, state) {
                if (state is NumberTriviaEmpty) {
                  return const MessageDisplay(
                    message: 'Start searching!',
                  );
                } else if (state is NumberTriviaLoaded) {
                  return TriviaDisplay(numberTrivia: state.trivia);
                } else if (state is NumberTriviaError) {
                  return MessageDisplay(
                    message: state.message,
                  );
                }

                return const LoadingWidget();
              },
            ),
            const SizedBox(height: 20),
            // Bottom half
            const TriviaControls()
          ],
        ),
      ),
    );
  }
}
