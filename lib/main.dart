import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testingbloc_course/homepage.dart';

void main() {
  runApp(const MyApp());
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonAction extends LoadAction {
  const LoadPersonAction({required this.personUrl});
  final PersonUrl personUrl;
}

enum PersonUrl { person1, person2 }

extension UrlString on PersonUrl {
  String get urlString {
    switch (this) {
      case PersonUrl.person1:
        return 'http://10.0.2.2:5500/api/person1.json';
      case PersonUrl.person2:
        return 'http://10.0.2.2:5500/api/person2.json';
    }
  }
}

@immutable
class Person {
  const Person({required this.name, required this.age});
  final String name;
  final int age;
  Person.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      age = json['age'] as int;
}

Future<Iterable<Person>> getPerson(String url) => HttpClient()
    .getUrl(Uri.parse(url))
    .then((req) => req.close())
    .then((resp) => resp.transform(utf8.decoder).join())
    .then((str) => json.decode(str) as List<dynamic>)
    .then((list) => list.map((e) => Person.fromJson(e)));

@immutable
class FetchResult {
  const FetchResult({required this.person, required this.isRetrievedFromCache});
  final Iterable<Person> person;
  final bool isRetrievedFromCache;
  @override
  String toString() =>
      'fetch result:(isRetrievedFromCache:$isRetrievedFromCache, person:$person))';
}

extension Subscript<T> on Iterable<T> {
  T? operator [](int index) => length > index ? elementAt(index) : null;
}

class PersonBloc extends Bloc<LoadAction, FetchResult?> {
  final Map<PersonUrl, Iterable<Person>> _cache = {};
  PersonBloc() : super(null) {
    on<LoadPersonAction>((event, emit) async {
      final url = event.personUrl;
      if (_cache.containsKey(url)) {
        final cachedPerson = _cache[url]!;
        final result = FetchResult(
          person: cachedPerson,
          isRetrievedFromCache: true,
        );
        emit(result);
      } else {
        final person = await getPerson(url.urlString);
        _cache[url] = person;
        final result = FetchResult(person: person, isRetrievedFromCache: false);
        emit(result);
      }
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) => PersonBloc(),
        child: const MyHomePage(),
      ),
    );
  }
}
