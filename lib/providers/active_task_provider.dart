import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';

final activeTaskProvider = StateProvider<Task?>((ref) => null);