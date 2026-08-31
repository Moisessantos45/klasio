import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mi_app.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE folders ADD COLUMN parent_id INTEGER REFERENCES folders (id) ON DELETE CASCADE',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parent_id INTEGER,
        name TEXT NOT NULL,
        index_icon INTEGER,
        index_color INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (parent_id) REFERENCES folders (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE tags(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE captures(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_id INTEGER,
        name TEXT NOT NULL,
        path TEXT NOT NULL,
        index_bg_color INTEGER,
        index_text_color INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE capture_tags(
        capture_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        PRIMARY KEY (capture_id, tag_id),
        FOREIGN KEY (capture_id) REFERENCES captures (id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
      )
    ''');

    await _insertTags(db);
  }

  Future<void> _insertTags(Database db) async {
    final count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM tags')) ??
        0;

    if (count > 0) {
      return;
    }

    await db.transaction((txn) async {
      final batch = txn.batch();

      final now = DateTime.now().toIso8601String();

      final tags = [
        {'name': 'Trabajo', 'created_at': now},
        {'name': 'Personal', 'created_at': now},
        {'name': 'Importante', 'created_at': now},
        {'name': 'Urgente', 'created_at': now},
        {'name': 'Estudio', 'created_at': now},
        {'name': 'Proyecto', 'created_at': now},
        {'name': 'Finanzas', 'created_at': now},
        {'name': 'Salud', 'created_at': now},
        {'name': 'Viajes', 'created_at': now},
        {'name': 'Hogar', 'created_at': now},
        {'name': 'Pizarras', 'created_at': now},
        {'name': 'Diapositivas', 'created_at': now},
        {'name': 'Examenes', 'created_at': now},
        {'name': 'Proyectos', 'created_at': now},
        {'name': 'Investigación', 'created_at': now},
        {'name': 'Notas de clase', 'created_at': now},
        {'name': 'Tareas', 'created_at': now},
        {'name': 'Laboratorio', 'created_at': now},
        {'name': 'Presentaciones', 'created_at': now},
        {'name': 'Lecturas', 'created_at': now},
        {'name': 'Investigación académica', 'created_at': now},
        {'name': 'Ensayos', 'created_at': now},
        {'name': 'Resúmenes', 'created_at': now},
        {'name': 'Referencias bibliográficas', 'created_at': now},
        {'name': 'Proyectos de investigación', 'created_at': now},
        {'name': 'Estudios de caso', 'created_at': now},
        {'name': 'Notas de laboratorio', 'created_at': now},
        {'name': 'Tareas y ejercicios', 'created_at': now},
        {'name': 'Exámenes y pruebas', 'created_at': now},
        {'name': 'Material de estudio adicional', 'created_at': now},
        {'name': 'Recursos en línea', 'created_at': now},
        {'name': 'Notas', 'created_at': now},
        {'name': 'Ideas', 'created_at': now},
        {'name': 'Recuerdos', 'created_at': now},
        {'name': 'Proyectos', 'created_at': now},
        {'name': 'Tareas', 'created_at': now},
        {'name': 'Eventos', 'created_at': now},
        {'name': 'Inspiración', 'created_at': now},
        {'name': 'Arte', 'created_at': now},
        {'name': 'Fotografía', 'created_at': now},
      ];

      final uniqueTags = <String, Map<String, dynamic>>{};
      for (var tag in tags) {
        final name = tag['name'].toString().toLowerCase().trim();
        uniqueTags[name] = {...tag, 'name': name};
      }

      for (var tag in uniqueTags.values) {
        batch.insert('tags', tag);
      }

      await batch.commit(noResult: true);
    });
  }
}
