import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasks/dto/create_task_dto.dart';
import 'package:tasks/dto/list_update_dto.dart';

import 'package:tasks/providers/auth.dart';
import 'package:tasks/services/lists_service.dart';

import 'package:tasks/models/task.dart';
import 'package:tasks/models/list.dart';
import 'package:tasks/services/lists_service_interface.dart';
import 'package:tasks/services/tasks_service.dart';
import 'package:tasks/services/tasks_service_interface.dart';

class Tasks with ChangeNotifier {
  Auth authProvider;

  IListsService listsService;
  ITasksService tasksService;

  bool _isLoading = false;
  bool _showCompleted = true;
  TaskList _selectedList;
  List<TaskList> _taskLists = [];

  Tasks({@required this.authProvider}) {
    if (authProvider != null) {
      listsService = new ListsService(authProvider: authProvider);
      tasksService = new TasksService(authProvider: authProvider);

      if (authProvider.token != null) {
        _fetchTaskLists();
        _setShowCompleted();
      }
    }
  }

  bool get showCompleted {
    return _showCompleted;
  }

  List<TaskList> get taskLists {
    return [..._taskLists];
  }

  bool get isLoading {
    return _isLoading;
  }

  TaskList get selectedList {
    return _selectedList;
  }

  List<Task> get tasks {
    List<Task> tasks = selectedList.tasks;

    // Remove completed tasks
    if (!showCompleted) {
      tasks = tasks.where((task) => task.status == 'OPEN').toList();
    }

    tasks.sort((a, b) => a.createdAt.isAfter(b.createdAt) ? 1 : 0);
    tasks.sort((a, b) => a.important ? 0 : 1);
    tasks.sort((a, b) => a.status == 'DONE' ? 1 : 0);
    return tasks;
  }

  /// Updates wether the completed tasks should be displayed.
  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }

  /// Updates de selected list in the store.
  void selectList(TaskList list) {
    _selectedList = list;
    notifyListeners();
  }

  /// Loads all task lists for the authenticated user.
  Future<void> _fetchTaskLists() async {
    try {
      _initChanges();

      final lists = await listsService.find();
      _taskLists = lists;
    } catch (e) {
      if (e is SocketException) {
        throw SocketException('Server seems to be down.');
      }
    } finally {
      _endChanges();
    }
  }

  /// Add a new list.
  ///
  /// The new list will be added in the store and then selected.
  Future<void> addList(String title) async {
    // Create the new list and update the store
    final createdList = await listsService.create(new TaskList(title: title));
    _taskLists.add(createdList);

    // Select the newly created list
    selectList(createdList);

    _endChanges();
    return true;
  }

  /// Deletes a list through the API and update the store.
  Future<void> deleteList() async {
    await listsService.delete(selectedList.id);
    _taskLists.removeWhere((it) => it.id == selectedList.id);

    _endChanges();
    return true;
  }

  /// Updates the list title.
  ///
  /// The updated list will be selected and updated in the store.
  Future<TaskList> updateListTitle(String title) async {
    final updatedList = await listsService.update(
      new TaskListUpdateDto(id: selectedList.id, title: title),
    );

    _taskLists[_taskLists.indexWhere((list) => list.id == updatedList.id)] =
        updatedList;

    selectList(updatedList);

    _endChanges();
    return updatedList;
  }

  /// Loads user preference on showing completed tasks on lists.
  _setShowCompleted() async {
    final _prefs = await SharedPreferences.getInstance();

    if (_prefs.containsKey('listPrefs')) {
      final prefs =
          json.decode(_prefs.get('listPrefs')) as Map<String, dynamic>;

      _showCompleted = prefs['showCompleted'];
    } else {
      _showCompleted = false;
    }
  }

  /// Sets [isLoading] to true and notify listeners.
  _initChanges() {
    _isLoading = true;
    notifyListeners();
  }

  /// Sets [isLoading] to false and notify listeners.
  _endChanges() {
    _isLoading = false;
    notifyListeners();
  }

  ///
  ///
  ///

  /// Adds the [task] through the API and updates the store.
  void addTask(Task task) async {
    final createdTask = await tasksService.create(
      new CreateTaskDto(title: task.title, listId: selectedList.id),
    );
    selectedList.tasks.add(createdTask);

    _endChanges();
  }

  /// Updates the [task] status through the API and updates the store.
  Future<Task> updateTaskStatus(Task task) async {
    final updatedTask = await tasksService.updateStatus(
      task.id,
      task.status == 'OPEN' ? 'DONE' : 'OPEN',
    );

    final tasks = selectedList.tasks;
    final index = tasks.indexWhere((it) => it.id == task.id);
    tasks[index] = updatedTask;

    _endChanges();
    return updatedTask;
  }

  /// Updates [task] important through the API and updates the store.
  Future<Task> updateTaskImportant(Task task) async {
    final updatedTask = await tasksService.updateImportant(
      task.id,
      task.important ? false : true,
    );

    final tasks = selectedList.tasks;
    final index = tasks.indexWhere((it) => it.id == task.id);
    tasks[index] = updatedTask;

    _endChanges();
    return updatedTask;
  }

  void deleteTask(Task task) async {
    await tasksService.delete(task.id);
    selectedList.tasks.removeAt(selectedList.tasks.indexOf(task));

    _endChanges();
    notifyListeners();
  }
}
