import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// DAYMARK Structured Localization System
/// Provides strongly-typed translations for Indonesian (id) and English (en).
/// Defaults to Indonesian (id).
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('id'),
    Locale('en'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('id'));
  }

  bool get isIndonesian => locale.languageCode == 'id';

  // Navigation
  String get dashboard => isIndonesian ? 'Dasbor' : 'Dashboard';
  String get journal => isIndonesian ? 'Jurnal' : 'Journal';
  String get summary => isIndonesian ? 'Ringkasan' : 'Summary';
  String get settings => isIndonesian ? 'Pengaturan' : 'Settings';

  // Header & Greetings
  String get appTitle => 'Day Mark';
  String get tagline => isIndonesian ? 'Setiap hari meninggalkan jejak.' : 'Every day leaves a mark.';
  String get taglineSubtitle => isIndonesian
      ? 'Abadikan refleksi, wawasan, atau pencapaian hari ini.'
      : 'Capture a reflection, insight, or achievement for today.';
  String get markToday => isIndonesian ? 'Catat Hari Ini' : 'Mark Today';

  String greeting(DateTime time) {
    final hour = time.toLocal().hour;
    if (isIndonesian) {
      if (hour >= 5 && hour < 11) return 'Selamat pagi';
      if (hour >= 11 && hour < 15) return 'Selamat siang';
      if (hour >= 15 && hour < 18) return 'Selamat sore';
      return 'Selamat malam';
    } else {
      if (hour >= 5 && hour < 12) return 'Good morning';
      if (hour >= 12 && hour < 17) return 'Good afternoon';
      if (hour >= 17 && hour < 21) return 'Good evening';
      return 'Good night';
    }
  }

  // Streaks & Stats
  String get currentStreak => isIndonesian ? 'Streak Saat Ini' : 'Current Streak';
  String get longestStreak => isIndonesian ? 'Streak Terpanjang' : 'Longest Streak';
  String get totalActiveDays => isIndonesian ? 'Total Hari Aktif' : 'Total Active Days';
  String get totalMarks => isIndonesian ? 'Total Catatan' : 'Total Marks';
  String get days => isIndonesian ? 'Hari' : 'Days';
  String get dayStreak => isIndonesian ? 'hari streak' : 'day streak';

  // Breakdown & Heatmap
  String get activityBreakdown => isIndonesian ? 'Rincian Aktivitas' : 'Activity Breakdown';
  String get thisWeek => isIndonesian ? 'Minggu Ini' : 'This Week';
  String get thisMonth => isIndonesian ? 'Bulan Ini' : 'This Month';
  String get thisYear => isIndonesian ? 'Tahun Ini' : 'This Year';
  String get recentMarks => isIndonesian ? 'CATATAN TERAKHIR' : 'RECENT MARKS';
  String get last5Entries => isIndonesian ? '5 Entri Terakhir' : 'Last 5 Entries';
  String get noMarksYet => isIndonesian ? 'Belum ada catatan yang tersimpan' : 'No marks recorded yet';
  String get startStreakPrompt => isIndonesian
      ? 'Ketuk "Catat Hari Ini" di atas untuk memulai streak Anda!'
      : 'Tap "Mark Today" above to start your streak!';
  String get activityCalendar => isIndonesian ? 'Kalender Aktivitas' : 'Activity Calendar';
  String activeDaysRecorded(int count) => isIndonesian ? '$count hari aktif tercatat' : '$count active days recorded';
  String get less => isIndonesian ? 'Sedikit' : 'Less';
  String get more => isIndonesian ? 'Banyak' : 'More';
  String markCount(int count) => isIndonesian ? '$count catatan' : '$count mark${count == 1 ? '' : 's'}';

  // Journal Timeline
  String get timeline => isIndonesian ? 'Linimasa' : 'Timeline';
  String get newEntry => isIndonesian ? 'Catatan Baru' : 'New Entry';
  String get searchPlaceholder => isIndonesian ? 'Cari jurnal, tag, pembelajaran...' : 'Search journals, tags, lessons...';
  String get allCategories => isIndonesian ? 'Semua' : 'All';
  String get dateFilter => isIndonesian ? 'Filter Tanggal' : 'Date Filter';
  String get noJournalsYet => isIndonesian ? 'Belum Ada Catatan Jurnal' : 'No Journal Entries Yet';
  String get noJournalsMatch => isIndonesian ? 'Tidak ada jurnal yang sesuai dengan pencarian' : 'No journals match your search';
  String get startWritingPrompt => isIndonesian
      ? 'Mulai tulis pengalaman atau pembelajaran Anda hari ini!'
      : 'Start writing your reflections and marks for today!';

  // Journal Actions & Editor
  String get edit => isIndonesian ? 'Edit' : 'Edit';
  String get delete => isIndonesian ? 'Hapus' : 'Delete';
  String get deleteJournalTitle => isIndonesian ? 'Hapus Jurnal?' : 'Delete Journal?';
  String deleteConfirmation(String title) => isIndonesian
      ? 'Apakah Anda yakin ingin menghapus "$title"? Tindakan ini tidak dapat dibatalkan dan akan memperbarui jumlah aktivitas Anda.'
      : 'Are you sure you want to delete "$title"? This action cannot be undone and will update your activity count.';
  String get cancel => isIndonesian ? 'Batal' : 'Cancel';
  String get pinned => isIndonesian ? 'Disematkan' : 'Pinned';
  String get favorite => isIndonesian ? 'Favorit' : 'Favorite';
  String get journalEntry => isIndonesian ? 'Entri Jurnal' : 'Journal Entry';
  String get titlePlaceholder => isIndonesian ? 'Judul jurnal...' : 'Journal title...';
  String get contentPlaceholder => isIndonesian
      ? 'Tuliskan pengalaman, pembelajaran, atau pemikiran Anda hari ini...'
      : 'Write down your experiences, lessons, or thoughts for today...';
  String get category => isIndonesian ? 'Kategori' : 'Category';
  String get mood => 'Mood';
  String get tags => 'Tag';
  String get addTagPlaceholder => isIndonesian ? 'Tambah tag (tekan enter)...' : 'Add tag (press enter)...';
  String get save => isIndonesian ? 'Simpan' : 'Save';
  String get saving => isIndonesian ? 'Menyimpan...' : 'Saving...';
  String get titleRequired => isIndonesian ? 'Harap masukkan judul jurnal Anda.' : 'Please enter a title for your journal.';
  String get contentRequired => isIndonesian ? 'Konten jurnal tidak boleh kosong.' : 'Journal content cannot be empty.';
  String get journalSaved => isIndonesian ? 'Jurnal berhasil disimpan!' : 'Journal saved successfully!';
  String get journalUpdated => isIndonesian ? 'Jurnal berhasil diperbarui!' : 'Journal updated successfully!';

  // Categories
  String categoryName(String id) {
    switch (id.toLowerCase()) {
      case 'daily':
        return isIndonesian ? 'Refleksi Harian' : 'Daily Reflection';
      case 'learning':
        return isIndonesian ? 'Pembelajaran' : 'Learning';
      case 'work':
        return isIndonesian ? 'Kerja & Proyek' : 'Work & Projects';
      case 'milestone':
        return isIndonesian ? 'Pencapaian' : 'Milestone';
      case 'health':
        return isIndonesian ? 'Kesehatan & Kebugaran' : 'Health & Wellness';
      case 'ideas':
        return isIndonesian ? 'Ide & Pemikiran' : 'Ideas & Thoughts';
      default:
        return id;
    }
  }

  // Moods
  List<String> get moodOptions {
    if (isIndonesian) {
      return [
        '⚡ Produktif',
        '✨ Terinspirasi',
        '🎯 Fokus',
        '🌱 Berkembang',
        '🌿 Tenang',
        '🧗 Menantang',
        '🙏 Bersyukur',
      ];
    } else {
      return [
        '⚡ Productive',
        '✨ Inspired',
        '🎯 Focused',
        '🌱 Growing',
        '🌿 Calm',
        '🧗 Challenging',
        '🙏 Grateful',
      ];
    }
  }

  // Summary
  String get journalSummary => isIndonesian ? 'Ringkasan Jurnal' : 'Journal Summary';
  String get summarySubtitle => isIndonesian ? 'Sintesis wawasan & ekspor laporan' : 'Synthesize insights & export report';
  String get summaryPeriod => isIndonesian ? 'PERIODE RINGKASAN' : 'SUMMARY PERIOD';
  String get last7Days => isIndonesian ? '7 Hari Terakhir' : 'Last 7 Days';
  String get last30Days => isIndonesian ? '30 Hari Terakhir' : 'Last 30 Days';
  String get past3Months => isIndonesian ? '3 Bulan Terakhir' : 'Past 3 Months';
  String get past6Months => isIndonesian ? '6 Bulan Terakhir' : 'Past 6 Months';
  String get generateSummary => isIndonesian ? 'Buat Ringkasan' : 'Generate Summary';
  String get generatingSummary => isIndonesian ? 'Membuat Ringkasan...' : 'Generating Summary...';
  String get summaryReport => isIndonesian ? 'LAPORAN RINGKASAN' : 'SUMMARY REPORT';
  String get exportPdf => isIndonesian ? 'Ekspor PDF' : 'Export PDF';
  String get executiveOverview => isIndonesian ? 'Ringkasan Eksekutif' : 'Executive Overview';
  String entriesAnalyzed(int count) => isIndonesian ? '$count entri dianalisis' : '$count entries analyzed';
  String get keyActivities => isIndonesian ? 'Aktivitas Utama & Lini Masa' : 'Key Activities & Timeline';
  String get keyLearnings => isIndonesian ? 'Pembelajaran & Wawasan Utama' : 'Key Learnings & Insights';
  String get achievements => isIndonesian ? 'Pencapaian & Prestasi' : 'Achievements & Milestones';
  String get challenges => isIndonesian ? 'Kendala & Hambatan' : 'Challenges & Obstacles';
  String get periodSummaryTitle => isIndonesian ? 'Ringkasan Periode' : 'Period Summary';
  String get periodSummaryDesc => isIndonesian
      ? 'Pilih rentang tanggal dan buat tinjauan terstruktur tentang pembelajaran, pencapaian, dan kendala Anda.'
      : 'Select your date range and generate a structured overview of your learnings, achievements, and challenges.';
  String get noEntriesForPeriod => isIndonesian
      ? 'Tidak ada entri jurnal pada periode yang dipilih.'
      : 'No journal entries were found in the selected period.';

  // Settings
  String get preferencesAndConfig => isIndonesian ? 'Preferensi & Konfigurasi Sistem' : 'Preferences & System Config';
  String get language => isIndonesian ? 'BAHASA' : 'LANGUAGE';
  String get appLanguage => isIndonesian ? 'Bahasa Aplikasi' : 'App Language';
  String get indonesian => 'Bahasa Indonesia';
  String get english => 'English';
  String get selectLanguage => isIndonesian ? 'Pilih Bahasa' : 'Select Language';
  String get appearance => isIndonesian ? 'TAMPILAN' : 'APPEARANCE';
  String get themePreference => isIndonesian ? 'Preferensi Tema' : 'Theme Preference';
  String themeModeText(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return isIndonesian ? 'Mode Terang' : 'Light Mode';
      case 'system':
        return isIndonesian ? 'Ikuti Sistem' : 'System Default';
      case 'dark':
      default:
        return isIndonesian ? 'Mode Gelap' : 'Dark Mode';
    }
  }
  String get dateFormat => isIndonesian ? 'Format Tanggal' : 'Date Format';
  String get privacyAndSecurity => isIndonesian ? 'PRIVASI & KEAMANAN' : 'PRIVACY & SECURITY';
  String get hidePreviews => isIndonesian ? 'Sembunyikan Pratinjau Jurnal' : 'Hide Journal Previews';
  String get hidePreviewsSubtitle => isIndonesian
      ? 'Samarkan pratinjau konten jurnal di linimasa'
      : 'Mask journal content previews in timeline';
  String get pinSecurity => isIndonesian ? 'Kunci Keamanan PIN Aplikasi' : 'App PIN Security Lock';
  String get pinEnabled => isIndonesian ? 'Kunci PIN Aktif' : 'PIN Lock Enabled';
  String get pinDisabled => isIndonesian ? 'Dinonaktifkan (Akses Terbuka)' : 'Disabled (Open Access)';
  String get aiProvider => isIndonesian ? 'LAYANAN AI & RINGKASAN' : 'AI & SUMMARY PROVIDER';
  String get summaryEngine => isIndonesian ? 'Mesin Ringkasan' : 'Summary Engine';
  String engineCloud(String model) => 'Cloud: Google Gemini ($model)';
  String get engineOffline => isIndonesian ? 'Offline: Mesin Heuristik Cerdas Lokal' : 'Offline: Local Smart Heuristic Engine';
  String get dataAndStorage => isIndonesian ? 'DATA & PENYIMPANAN' : 'DATA & STORAGE';
  String get backupData => isIndonesian ? 'Cadangkan Data (Ekspor JSON)' : 'Backup Data (Export JSON)';
  String get backupSubtitle => isIndonesian
      ? 'Ekspor jurnal dan riwayat aktivitas ke berkas'
      : 'Export journals and activity history to file';
  String get restoreData => isIndonesian ? 'Pulihkan Data (Impor JSON)' : 'Restore Data (Import JSON)';
  String get restoreSubtitle => isIndonesian
      ? 'Pulihkan entri dari cadangan Day Mark sebelumnya'
      : 'Restore entries from previous Day Mark backup';
  String get about => isIndonesian ? 'Tentang Day Mark' : 'About Day Mark';
  String get version => isIndonesian ? 'Versi' : 'Version';
  String get offlinePromise => isIndonesian ? '100% Offline & Mengutamakan Privasi' : '100% Offline & Privacy First';
  String get offlinePromiseDesc => isIndonesian
      ? 'Data Anda disimpan secara lokal di perangkat Anda. Tidak ada pelacakan, tidak perlu akun.'
      : 'Your data is stored locally on your device. No tracking, no account required.';
  String get enterPinPrompt => isIndonesian
      ? 'Masukkan PIN keamanan Anda untuk mengakses jurnal'
      : 'Enter your security PIN to access your journal';
  String get unlock => isIndonesian ? 'Buka Kunci' : 'Unlock';
  String get incorrectPin => isIndonesian ? 'PIN salah. Silakan coba lagi.' : 'Incorrect PIN. Please try again.';
  String get editProfile => isIndonesian ? 'Edit Profil Pengguna' : 'Edit User Profile';
  String get name => isIndonesian ? 'Nama' : 'Name';
  String get bio => isIndonesian ? 'Bio / Kutipan Pribadi' : 'Bio / Personal Quote';
  String get saveProfile => isIndonesian ? 'Simpan Profil' : 'Save Profile';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['id', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension BuildContextL10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
