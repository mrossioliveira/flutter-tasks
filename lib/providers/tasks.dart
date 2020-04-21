import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasks/dto/create_task_dto.dart';
import 'package:tasks/dto/list_update_dto.dart';
import 'package:tasks/models/list_type.dart';

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

  List<TaskList> _allLists = [];
  TaskList _selectedList;

  List<Task> _allTasks = [];
  List<Task> _selectedTasks = [];

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
    List<TaskList> lists = [];
    lists.add(
      new TaskList(
        id: ListType.IMPORTANT,
        title: 'Important',
        taskCounter: _allTasks
            .where((task) => task.important && task.status == 'OPEN')
            .length,
      ),
    );
    lists.add(
      new TaskList(
        id: ListType.TASKS,
        title: 'Tasks',
        taskCounter: _allTasks
            .where((task) => task.list == null && task.status == 'OPEN')
            .length,
      ),
    );
    lists.addAll(_allLists);
    return lists.toList();
  }

  bool get isLoading {
    return _isLoading;
  }

  TaskList get selectedList {
    return _selectedList;
  }

  Future<void> fetchAndRefresh() async {
    _fetchTaskLists();
  }

  List<Task> get tasks {
    List<Task> tasks = [..._selectedTasks];

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

  /// Updates de selected list and tasks.
  void selectList(TaskList list) {
    _selectedList = list;

    switch (list.id) {
      case ListType.IMPORTANT:
        _selectedTasks = _getImportantTasks();
        break;
      case ListType.TASKS:
        _selectedTasks = _getListlessTasks();
        break;
      default:
        _selectedTasks =
            _allTasks.where((task) => task.list?.id == list.id).toList();
    }

    notifyListeners();
  }

  /// Loads all task lists for the authenticated user.
  Future<void> _fetchTaskLists() async {
    try {
      _initChanges();

      final tasks = await tasksService.find();
      _allTasks = tasks;

      final lists = await listsService.find();
      for (var list in lists) {
        list.taskCounter = _getTaskListCounter(list);
      }
      _allLists = lists;
    } catch (e) {
      if (e is SocketException) {
        throw SocketException('Server seems to be down.');
      }
    } finally {
      _endChanges();
    }
  }

  List<Task> _getTasksByList(TaskList list) {
    return _allTasks.where((task) => task.list?.id == list.id).toList();
  }

  int _getTaskListCounter(TaskList list) {
    return _getTasksByList(list)
        .where((task) => task.status == 'OPEN')
        .toList()
        .length;
  }

  /// Add a new list.
  ///
  /// The new list will be added in the store and then selected.
  Future<void> addList(String title) async {
    // Create the new list and update the store
    final createdList = await listsService.create(new TaskList(title: title));
    _allLists.add(createdList);

    // Select the newly created list
    selectList(createdList);

    _endChanges();
    return true;
  }

  /// Deletes a list through the API and update the store.
  Future<void> deleteList() async {
    await listsService.delete(selectedList.id);
    _allLists.removeWhere((it) => it.id == selectedList.id);

    _endChanges();
    return true;
  }

  /// Updates the list title.
  ///
  /// The updated list will be selected and updated in the store.
  Future<TaskList> updateListTitle(String title) async {
    // Keep current counter
    final currentTasksCounter = selectedList.taskCounter;

    final updatedList = await listsService.update(
      new TaskListUpdateDto(id: selectedList.id, title: title),
    );

    // Set the counter
    updatedList.taskCounter = currentTasksCounter;

    // Update the list in the store and select it
    _allLists[_allLists.indexWhere((list) => list.id == updatedList.id)] =
        updatedList;
    selectList(updatedList);

    // Update tasks from this list
    for (var task
        in _allTasks.where((task) => task.list?.id == updatedList.id)) {
      task.list = updatedList;
    }

    _endChanges();
    return updatedList;
  }

  List<Task> _getImportantTasks() {
    final List<Task> tasks = _allTasks.where((task) => task.important).toList();

    tasks.sort((a, b) => a.createdAt.isAfter(b.createdAt) ? 1 : 0);
    tasks.sort((a, b) => a.important ? 0 : 1);
    tasks.sort((a, b) => a.status == 'DONE' ? 1 : 0);
    return tasks;
  }

  List<Task> _getListlessTasks() {
    final List<Task> tasks =
        _allTasks.where((task) => task.list == null).toList();

    tasks.sort((a, b) => a.createdAt.isAfter(b.createdAt) ? 1 : 0);
    tasks.sort((a, b) => a.important ? 0 : 1);
    tasks.sort((a, b) => a.status == 'DONE' ? 1 : 0);
    return tasks;
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
      new CreateTaskDto(
        title: task.title,
        listId: selectedList.id,
        important: selectedList.id == ListType.IMPORTANT,
      ),
    );
    _allTasks.add(createdTask);
    // _selectedTasks.add(createdTask);

    _updateSelectedTasks();
    _incrementListCounter(task);

    _endChanges();
  }

  /// Updates the [task] status through the API and updates the store.
  Future<Task> updateTaskStatus(Task task) async {
    final updatedTask = await tasksService.updateStatus(
      task.id,
      task.status == 'OPEN' ? 'DONE' : 'OPEN',
    );

    final tasks = _allTasks;
    final index = tasks.indexWhere((it) => it.id == task.id);
    tasks[index] = updatedTask;

    _updateSelectedTasks();

    // update list counter
    if (task.status == 'OPEN') {
      _decrementListCounter(task);
    } else {
      _incrementListCounter(task);
    }

    _endChanges();
    return updatedTask;
  }

  _decrementListCounter(Task task) {
    switch (selectedList.id) {
      case ListType.IMPORTANT:
        if (task.list != null) {
          taskLists.firstWhere((list) => list.id == task.list.id).taskCounter--;
        } else {
          taskLists
              .firstWhere((list) => list.id == ListType.TASKS)
              .taskCounter--;
        }
        break;
      case ListType.TASKS:
        selectedList.taskCounter--;
        break;
      default:
        selectedList.taskCounter--;
    }
  }

  _incrementListCounter(Task task) {
    switch (selectedList.id) {
      case ListType.IMPORTANT:
        if (task.list != null) {
          taskLists.firstWhere((list) => list.id == task.list.id).taskCounter++;
        } else {
          taskLists
              .firstWhere((list) => list.id == ListType.TASKS)
              .taskCounter++;
        }
        break;
      case ListType.TASKS:
        selectedList.taskCounter++;
        break;
      default:
        selectedList.taskCounter++;
    }
  }

  _updateSelectedTasks() {
    switch (selectedList.id) {
      case ListType.IMPORTANT:
        _selectedTasks = _getImportantTasks();
        break;
      case ListType.TASKS:
        _selectedTasks = _getListlessTasks();
        break;
      default:
        _selectedTasks = _getTasksByList(selectedList);
    }
  }

  /// Updates [task] important through the API and updates the store.
  Future<Task> updateTaskImportant(Task task) async {
    final updatedTask = await tasksService.updateImportant(
      task.id,
      task.important ? false : true,
    );

    final tasks = _allTasks;
    final index = tasks.indexWhere((it) => it.id == task.id);
    tasks[index] = updatedTask;

    _updateSelectedTasks();

    _endChanges();
    return updatedTask;
  }

  void deleteTask(Task task) async {
    await tasksService.delete(task.id);
    _allTasks.removeAt(_allTasks.indexOf(task));

    // If the task is done there is no need to update
    if (task.status == 'OPEN') {
      _decrementListCounter(task);
    }

    _updateSelectedTasks();

    _endChanges();
  }

  /// Reloads the current list and all its tasks.
  Future<void> refreshSelectedList() async {
    if (selectedList.id > 0) {
      final listId = selectedList.id;
      final updatedList = await listsService.findById(listId);

      final index = _allLists.indexWhere((list) => list.id == listId);
      _allLists[index] = updatedList;

      // Update tasks
      final updatedTasks = await tasksService.find();
      _allTasks = updatedTasks;
      _selectedTasks =
          _allTasks.where((task) => task.list?.id == selectedList.id).toList();

      updatedList.taskCounter = updatedTasks
          .where((task) =>
              task.list?.id == updatedList.id && task.status == 'OPEN')
          .length;
      selectList(updatedList);
    } else {
      // update all tasks
      final tasks = await tasksService.find();
      _allTasks = tasks;

      // update selected tasks
      _updateSelectedTasks();
    }
    _endChanges();
  }
}
