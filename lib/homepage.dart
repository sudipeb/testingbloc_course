import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testingbloc_course/main.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Demo Home Page')),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                child: Text('Person1'),
                onPressed: () {
                  context.read<PersonBloc>().add(
                    const LoadPersonAction(personUrl: PersonUrl.person1),
                  );
                },
              ),
              TextButton(
                child: Text('Person2'),
                onPressed: () {
                  context.read<PersonBloc>().add(
                    const LoadPersonAction(personUrl: PersonUrl.person2),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<PersonBloc, FetchResult?>(
              buildWhen: (previousResult, currentResult) {
                return previousResult?.person != currentResult?.person;
              },
              builder: ((context, fetchResult) {
                final person = fetchResult?.person;
                if (person == null) {
                  return SizedBox(child: Center(child: Text('No Data Loaded')));
                }
                return ListView.builder(
                  itemCount: person.length,
                  itemBuilder: (context, index) {
                    final persons = person[index];
                    return ListTile(
                      title: Text("${persons!.name}, ${persons.age}"),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
