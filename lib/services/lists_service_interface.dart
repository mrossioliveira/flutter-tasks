import 'package:tasks/dto/list_update_dto.dart';
import 'package:tasks/models/list.dart';

abstract class IListsService {
  Future<List<TaskList>> find();
  Future<TaskList> findById(int id);
  Future<TaskList> create(TaskList list);
  Future<TaskList> update(TaskListUpdateDto updateDto);
  Future<void> delete(int id);
}
