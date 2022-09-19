import 'package:clean_architecture_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: buildBody(context),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => sl<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              // Top half
              SizedBox(height: 10),
              Container(
                height: MediaQuery.of(context).size.height / 3,
                child: Placeholder(),
              ),
              SizedBox(height: 20),
              // Bottom half
              Column(
                children: <Widget>[
                  Placeholder(fallbackHeight: 40),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Placeholder(
                          fallbackHeight: 30,
                          fallbackWidth: 200,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Placeholder(
                          fallbackHeight: 30,
                          fallbackWidth: 200,
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
