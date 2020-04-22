import 'package:tasks/dto/create_task_dto.dart';
import 'package:tasks/dto/update_task_dto.dart';
import 'package:tasks/models/task.dart';

abstract class ITasksService {
  Future<List<Task>> find();
  Future<List<Task>> findImportant();
  Future<List<Task>> findListless();
  Future<Task> create(CreateTaskDto createTaskDto);
  Future<void> delete(int id);
  Future<Task> update(int id, UpdateTaskDto updateTaskDto);
  Future<Task> updateStatus(int id, String status);
  Future<Task> updateImportant(int id, bool important);
}
