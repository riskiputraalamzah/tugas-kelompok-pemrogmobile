import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._init();

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ats_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;
    
    if (kIsWeb) {
      // For web, use the filename directly
      path = filePath;
    } else {
      // For mobile/desktop, use full path
      final dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Jobs table
    await db.execute('''
      CREATE TABLE jobs (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        requirements TEXT NOT NULL,
        location TEXT NOT NULL,
        salary_range TEXT NOT NULL,
        employment_type TEXT NOT NULL,
        is_open INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Applications table
    await db.execute('''
      CREATE TABLE applications (
        id TEXT PRIMARY KEY,
        job_id TEXT NOT NULL,
        email TEXT NOT NULL,
        full_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        education TEXT NOT NULL,
        experience TEXT NOT NULL,
        skills TEXT NOT NULL,
        cover_letter TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        ai_score REAL,
        ai_label TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (job_id) REFERENCES jobs (id),
        UNIQUE(job_id, email)
      )
    ''');

    // Admins table
    await db.execute('''
      CREATE TABLE admins (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Interviews table
    await db.execute('''
      CREATE TABLE interviews (
        id TEXT PRIMARY KEY,
        application_id TEXT NOT NULL UNIQUE,
        scheduled_at TEXT NOT NULL,
        location TEXT NOT NULL,
        notes TEXT,
        is_confirmed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (application_id) REFERENCES applications (id)
      )
    ''');

    // Broadcasts table
    await db.execute('''
      CREATE TABLE broadcasts (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Insert default admin account
    final uuid = const Uuid();
    final passwordHash = sha256.convert(utf8.encode('admin123')).toString();
    await db.insert('admins', {
      'id': uuid.v4(),
      'username': 'admin',
      'password_hash': passwordHash,
      'full_name': 'Administrator',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Insert sample jobs
    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final uuid = const Uuid();
    final now = DateTime.now().toIso8601String();

    // Sample jobs
    final jobs = [
      {
        'id': uuid.v4(),
        'title': 'Software Engineer',
        'description': 'Kami mencari Software Engineer yang berpengalaman untuk bergabung dengan tim teknologi kami. Anda akan bekerja pada pengembangan aplikasi web dan mobile.',
        'requirements': '• Pengalaman minimal 2 tahun dalam pengembangan software\n• Menguasai bahasa pemrograman (Java, Python, atau Dart)\n• Familiar dengan framework modern\n• Kemampuan problem solving yang baik\n• Bisa bekerja dalam tim',
        'location': 'Jakarta, Indonesia',
        'salary_range': 'Rp 8.000.000 - Rp 15.000.000',
        'employment_type': 'Full-time',
        'is_open': 1,
        'created_at': now,
      },
      {
        'id': uuid.v4(),
        'title': 'UI/UX Designer',
        'description': 'Dibutuhkan UI/UX Designer kreatif untuk merancang antarmuka pengguna yang menarik dan intuitif untuk produk digital kami.',
        'requirements': '• Portfolio yang menunjukkan kemampuan desain UI/UX\n• Menguasai Figma, Adobe XD, atau tools desain lainnya\n• Pemahaman tentang user research dan usability testing\n• Kreativitas tinggi dan attention to detail\n• Pengalaman minimal 1 tahun',
        'location': 'Bandung, Indonesia',
        'salary_range': 'Rp 6.000.000 - Rp 12.000.000',
        'employment_type': 'Full-time',
        'is_open': 1,
        'created_at': now,
      },
      {
        'id': uuid.v4(),
        'title': 'Data Analyst',
        'description': 'Kami membutuhkan Data Analyst untuk menganalisis data bisnis dan memberikan insight yang berguna untuk pengambilan keputusan.',
        'requirements': '• Pengalaman dengan SQL dan Python\n• Kemampuan visualisasi data (Tableau, Power BI)\n• Pemahaman statistik dan analisis data\n• Kemampuan komunikasi yang baik\n• Gelar S1 di bidang terkait',
        'location': 'Surabaya, Indonesia',
        'salary_range': 'Rp 7.000.000 - Rp 13.000.000',
        'employment_type': 'Full-time',
        'is_open': 1,
        'created_at': now,
      },
    ];

    for (final job in jobs) {
      await db.insert('jobs', job);
    }

    // Sample broadcast
    await db.insert('broadcasts', {
      'id': uuid.v4(),
      'title': 'Selamat Datang di Portal Karir Kami!',
      'content': 'Terima kasih telah mengunjungi portal karir kami. Kami terus membuka kesempatan bagi talenta-talenta terbaik untuk bergabung. Pantau terus lowongan terbaru dan jangan lewatkan kesempatan emas Anda!',
      'is_active': 1,
      'created_at': now,
    });
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
