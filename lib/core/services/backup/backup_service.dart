import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/journal/domain/repositories/journal_repository.dart';

class BackupService {
  final JournalRepository repository;

  BackupService(this.repository);

  /// Exports data to a JSON backup file and opens share sheet or saves to storage
  Future<String> exportBackup() async {
    final data = await repository.exportAllData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'daymark_backup_$timestamp.json';

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(jsonString);

    // Share backup file
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json', name: fileName)],
      subject: 'DAYMARK Backup ($timestamp)',
      text: 'DAYMARK Journal Backup - $timestamp',
    );

    return file.path;
  }

  /// Imports data from a user-selected JSON file
  Future<int> importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty || result.files.single.path == null) {
      throw Exception('No file selected');
    }

    final filePath = result.files.single.path!;
    final file = File(filePath);
    final content = await file.readAsString();

    final dynamic parsed = jsonDecode(content);
    if (parsed is! Map<String, dynamic>) {
      throw Exception('Invalid backup format');
    }

    if (parsed['app'] != 'DAYMARK') {
      throw Exception('File is not a valid DAYMARK backup');
    }

    await repository.importAllData(parsed);

    final journalsCount = (parsed['journals'] as List<dynamic>? ?? []).length;
    return journalsCount;
  }
}
