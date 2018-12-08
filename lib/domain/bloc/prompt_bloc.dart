import 'package:rxdart/rxdart.dart';
import 'package:writing_prompt/domain/managers/prompt_manager.dart';
import 'dart:async';

import 'package:writing_prompt/domain/models/prompt.dart';

class PromptBloc {
  PromptManager _promptManager;

  final _promptSubject = BehaviorSubject<Prompt>();
  final _promptHistorySubject = BehaviorSubject<List<Prompt>>();
  final _promptCheckSubject = BehaviorSubject<Prompt>();

  Stream<Prompt> get prompt => _promptSubject.stream;
  Stream<List<Prompt>> get promptHistory => _promptHistorySubject.stream;

  PromptBloc(this._promptManager) {
    fetchPrompt();
    _getPromptHistory();
    _promptCheckUpdate();
  }

  Observable<int> insertPrompt(Prompt prompt) {
    return _promptManager.insertPrompt(prompt)
        .flatMap((_) => _getPromptHistory())
        // hammering time since we don't have a completable
        .map((_) => 1);
  }

  Observable<List<Prompt>> _getPromptHistory() {
    return _promptManager.getListOfPrompts()
        .map((prompts) => prompts.reversed.toList())
        .map(_addHistoryToSubject);
  }

  List<Prompt> _addHistoryToSubject(List<Prompt> prompts) {
    _promptHistorySubject.add(prompts);
    return prompts;
  }

  void updatePrompt(Prompt prompt) {
    _promptCheckSubject.add(prompt);
  }

  void fetchPrompt() {
    _promptManager.getPrompt()
        .map((prompt) {
          _promptSubject.add(prompt);
          return prompt;
        })
        .flatMap(insertPrompt)
        .listen((_) => _);
  }

  void _promptCheckUpdate() {
    _promptCheckSubject
      .listen(_promptManager.updatePrompt);
  }
}