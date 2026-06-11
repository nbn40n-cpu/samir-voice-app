import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'prices_screen.dart';
import 'reports.dart';
import 'smart_assistant.dart';

class AppTheme {
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color secondary = Color(0xFFFF8F00);
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color teal = Color(0xFF00897B);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surfaceColor = Colors.white;
  static const Color textDark = Color(0xFF263238);
  static const Color textMedium = Color(0xFF546E7A);
  static const Color textLight = Color(0xFF90A4AE);

  static const TextStyle heading1 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textDark);
  static const TextStyle heading2 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark);
  static const TextStyle heading3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textDark);
  static const TextStyle heading4 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, color: textMedium);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, color: textLight);
  
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(8));  // ✅ تمت الإضافة
  static const BoxShadow shadowMd = BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4));
  static const BoxShadow shadowSm = BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2)); // ✅ تمت الإضافة

  static InputDecoration inputDecoration({required String label, Widget? prefix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefix,
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(borderRadius: radiusMd, borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  static ThemeData get theme => ThemeData(
    useMaterial3: false,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(backgroundColor: primary, foregroundColor: Colors.white, centerTitle: true, titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: radiusMd)),
    ),
  );
}

class DailyWork {
  final String date;
  int shhnDars, shhnTest;
  String shhnTestResult;
  double shhnAmount;
  int khsosyDars, khsosyTest;
  String khsosyTestResult;
  double khsosyAmount;
  int basDars, basTest;
  String basTestResult;
  double basAmount;
  int trktrDars, trktrTest;
  String trktrTestResult;
  double trktrAmount;

  DailyWork({
    required this.date,
    this.shhnDars = 0,
    this.shhnTest = 0,
    this.shhnTestResult = 'غير محدد',
    this.shhnAmount = 0.0,
    this.khsosyDars = 0,
    this.khsosyTest = 0,
    this.khsosyTestResult = 'غير محدد',
    this.khsosyAmount = 0.0,
    this.basDars = 0,
    this.basTest = 0,
    this.basTestResult = 'غير محدد',
    this.basAmount = 0.0,
    this.trktrDars = 0,
    this.trktrTest = 0,
    this.trktrTestResult = 'غير محدد',
    this.trktrAmount = 0.0
  });

  double get totalAmount => shhnAmount + khsosyAmount + basAmount + trktrAmount;
  int get totalDars => shhnDars + khsosyDars + basDars + trktrDars;
  int get totalTest => shhnTest + khsosyTest + basTest + trktrTest;

  Map<String, dynamic> toJson() => {
    'date': date,
    'shhnDars': shhnDars,
    'shhnTest': shhnTest,
    'shhnTestResult': shhnTestResult,
    'shhnAmount': shhnAmount,
    'khsosyDars': khsosyDars,
    'khsosyTest': khsosyTest,
    'khsosyTestResult': khsosyTestResult,
    'khsosyAmount': khsosyAmount,
    'basDars': basDars,
    'basTest': basTest,
    'basTestResult': basTestResult,
    'basAmount': basAmount,
    'trktrDars': trktrDars,
    'trktrTest': trktrTest,
    'trktrTestResult': trktrTestResult,
    'trktrAmount': trktrAmount
  };

  factory DailyWork.fromJson(Map<String, dynamic> json) => DailyWork(
    date: json['date'],
    shhnDars: json['shhnDars'] ?? 0,
    shhnTest: json['shhnTest'] ?? 0,
    shhnTestResult: json['shhnTestResult'] ?? 'غير محدد',
    shhnAmount: (json['shhnAmount'] ?? 0).toDouble(),
    khsosyDars: json['khsosyDars'] ?? 0,
    khsosyTest: json['khsosyTest'] ?? 0,
    khsosyTestResult: json['khsosyTestResult'] ?? 'غير محدد',
    khsosyAmount: (json['khsosyAmount'] ?? 0).toDouble(),
    basDars: json['basDars'] ?? 0,
    basTest: json['basTest'] ?? 0,
    basTestResult: json['basTestResult'] ?? 'غير محدد',
    basAmount: (json['basAmount'] ?? 0).toDouble(),
    trktrDars: json['trktrDars'] ?? 0,
    trktrTest: json['trktrTest'] ?? 0,
    trktrTestResult: json['trktrTestResult'] ?? 'غير محدد',
    trktrAmount: (json['trktrAmount'] ?? 0).toDouble()
  );
}

class PriceSetting {
  final String id, name, description;
  double lessonPrice, testPrice;
  PriceSetting({
    required this.id,
    required this.name,
    required this.description,
    required this.lessonPrice,
    required this.testPrice
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'lessonPrice': lessonPrice,
    'testPrice': testPrice
  };

  factory PriceSetting.fromJson(Map<String, dynamic> json) => PriceSetting(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    lessonPrice: (json['lessonPrice'] ?? 0).toDouble(),
    testPrice: (json['testPrice'] ?? 0).toDouble()
  );
}

class Payment {
  final String id, date, type, note;
  final double amount;
  Payment({
    required this.id,
    required this.date,
    required this.type,
    required this.note,
    required this.amount
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'type': type,
    'note': note,
    'amount': amount
  };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'],
    date: json['date'],
    type: json['type'],
    note: json['note'],
    amount: (json['amount'] ?? 0).toDouble()
  );
}

List<DailyWork> dailyWorks = [];
List<PriceSetting> pricesList = [];
List<Payment> paymentsList = [];
double oldBalance = 0.0;

Future<void> loadSavedData() async {
  final prefs = await SharedPreferences.getInstance();
  final worksJson = prefs.getString('daily_works');
  if (worksJson != null) dailyWorks = (jsonDecode(worksJson) as List).map((e) => DailyWork.fromJson(e)).toList();
  final pricesJson = prefs.getString('prices');
  if (pricesJson != null) pricesList = (jsonDecode(pricesJson) as List).map((e) => PriceSetting.fromJson(e)).toList();
  final paymentsJson = prefs.getString('payments');
  if (paymentsJson != null) paymentsList = (jsonDecode(paymentsJson) as List).map((e) => Payment.fromJson(e)).toList();
  oldBalance = (prefs.getDouble('old_balance') ?? 0.0);
}

Future<void> saveData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('daily_works', jsonEncode(dailyWorks.map((e) => e.toJson()).toList()));
  await prefs.setString('prices', jsonEncode(pricesList.map((e) => e.toJson()).toList()));
  await prefs.setString('payments', jsonEncode(paymentsList.map((e) => e.toJson()).toList()));
  await prefs.setDouble('old_balance', oldBalance);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSavedData();
  runApp(const SamirTrainerApp());
}

class SamirTrainerApp extends StatelessWidget {
  const SamirTrainerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام سمير',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
      locale: const Locale('ar', ''),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: [const Locale('ar', '')],
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainEntryScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryLight])
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.account_balance_wallet, size: 60, color: Colors.white),
              SizedBox(height: 20),
              Text('نظام سمير', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))
            ]
          )
        )
      )
    );
  }
}

class MainEntryScreen extends StatelessWidget {
  const MainEntryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primary, AppTheme.primaryLight, AppTheme.surfaceColor]
          )
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [AppTheme.shadowMd]
                ),
                child: const Icon(Icons.account_balance_wallet, size: 60, color: AppTheme.primary)
              ),
              const SizedBox(height: 30),
              const Text('نظام سمير المحاسبي', style: AppTheme.heading1),
              const SizedBox(height: 8),
              const Text('إدارة مدارس القيادة', style: AppTheme.bodyMedium),
              const SizedBox(height: 40),
              SizedBox(
                width: 200, height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg),
                  ),
                  child: const Text('لوحة الدخول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    try {
      final Map<String, dynamic> allData = {
        'version': 1,
        'exportDate': DateTime.now().toIso8601String(),
        'dailyWorks': dailyWorks.map((e) => e.toJson()).toList(),
        'pricesList': pricesList.map((e) => e.toJson()).toList(),
        'paymentsList': paymentsList.map((e) => e.toJson()).toList(),
        'oldBalance': oldBalance
      };
      final String jsonData = jsonEncode(allData);
      final String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ نسخة احتياطية',
        fileName: 'samir_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json',
        type: FileType.custom,
        allowedExtensions: ['json']
      );
      if (outputPath != null) {
        await File(outputPath).writeAsString(jsonData);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم التصدير بنجاح!'), backgroundColor: AppTheme.success));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في التصدير: $e'), backgroundColor: AppTheme.error));
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result != null && result.files.single.path != null) {
        final String content = await File(result.files.single.path!).readAsString();
        final Map<String, dynamic> data = jsonDecode(content);
        if (data['dailyWorks'] != null) dailyWorks = (data['dailyWorks'] as List).map((e) => DailyWork.fromJson(e)).toList();
        if (data['pricesList'] != null) pricesList = (data['pricesList'] as List).map((e) => PriceSetting.fromJson(e)).toList();
        if (data['paymentsList'] != null) paymentsList = (data['paymentsList'] as List).map((e) => Payment.fromJson(e)).toList();
        if (data['oldBalance'] != null) oldBalance = (data['oldBalance'] as num).toDouble();
        await saveData();
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الاستيراد بنجاح!'), backgroundColor: AppTheme.success));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في الاستيراد: $e'), backgroundColor: AppTheme.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: () => _importData(context), tooltip: 'استيراد'),
          IconButton(icon: const Icon(Icons.upload), onPressed: () => _exportData(context), tooltip: 'تصدير'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(children: [
              Expanded(child: _buildBtn(context, 'الادخال اليومي', Icons.edit_note, AppTheme.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen())))),
              const SizedBox(width: 12),
              Expanded(child: _buildBtn(context, 'التقارير', Icons.bar_chart, AppTheme.secondary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsMenuScreen())))),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildBtn(context, 'إدارة الأسعار', Icons.attach_money, AppTheme.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PricesScreen())))),
              const SizedBox(width: 12),
              Expanded(child: Container()),
            ]),
            const SizedBox(height: 20),
            SmartAssistant(
              actions: {
                "تقرير المبيعات": () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsMenuScreen()));
                },
                "الادخال اليومي": () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
                },
                "الأسعار": () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PricesScreen()));
                },
                "حذف الكل": () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('هذه الميزة تحتاج تهيئة خاصة')));
                },
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBtn(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(height: 90, child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 32),
        const SizedBox(height: 6),
        Text(title, style: AppTheme.heading4.copyWith(fontSize: 14)),
      ])
    ));
  }
}

class ReportsMenuScreen extends StatelessWidget {
  const ReportsMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.primary, borderRadius: AppTheme.radiusLg),
            child: Column(children: [
              const Text('تقرير سنوي للكل', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen(reportType: 'yearly_all'))),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary, foregroundColor: Colors.white),
                child: const Text('عرض التقرير السنوي', style: TextStyle(fontSize: 16))
              ),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('التقارير الشهرية', style: AppTheme.heading2),
          const SizedBox(height: 12),
          Expanded(child: ListView(children: [
            Row(children: [Expanded(child: _btn(context, 'تقرير رئيسي', AppTheme.teal, 'main_month')), const SizedBox(width: 8), Expanded(child: _btn(context, 'شحن وخصوصي', AppTheme.primary, 'shhn_khsosy_month'))]),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: _btn(context, 'باص وتركتر', AppTheme.secondary, 'bas_trktr_month')), const SizedBox(width: 8), Expanded(child: _btn(context, 'تقرير شحن', AppTheme.success, 'shhn_month'))]),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: _btn(context, 'تقرير خصوصي', AppTheme.purple, 'khsosy_month')), const SizedBox(width: 8), Expanded(child: _btn(context, 'تقرير باص', AppTheme.teal, 'bas_month'))]),
            const SizedBox(height: 8),
            _btn(context, 'تقرير تركتر', AppTheme.warning, 'trktr_month'),
          ])),
        ]),
      ),
    );
  }
  Widget _btn(BuildContext context, String title, Color color, String type) {
    return ElevatedButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen(reportType: type))),
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
      child: Text(title)
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingDayData();
    });
  }

  @override
  void dispose() {
    for (var c in _controllers.values) c.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _controllers['shhn_dars']     = TextEditingController(text: '0');
    _controllers['shhn_test']     = TextEditingController(text: '0');
    _controllers['shhn_result']   = TextEditingController(text: 'غير محدد');
    _controllers['khsosy_dars']   = TextEditingController(text: '0');
    _controllers['khsosy_test']   = TextEditingController(text: '0');
    _controllers['khsosy_result'] = TextEditingController(text: 'غير محدد');
    _controllers['bas_dars']      = TextEditingController(text: '0');
    _controllers['bas_test']      = TextEditingController(text: '0');
    _controllers['bas_result']    = TextEditingController(text: 'غير محدد');
    _controllers['trktr_dars']    = TextEditingController(text: '0');
    _controllers['trktr_test']    = TextEditingController(text: '0');
    _controllers['trktr_result']  = TextEditingController(text: 'غير محدد');
  }

  void _loadExistingDayData() {
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    DailyWork? work;
    try { work = dailyWorks.firstWhere((w) => w.date == dateStr); } catch (e) { work = null; }
    if (work != null) {
      _controllers['shhn_dars']!.text     = work.shhnDars.toString();
      _controllers['shhn_test']!.text     = work.shhnTest.toString();
      _controllers['shhn_result']!.text   = work.shhnTestResult;
      _controllers['khsosy_dars']!.text   = work.khsosyDars.toString();
      _controllers['khsosy_test']!.text   = work.khsosyTest.toString();
      _controllers['khsosy_result']!.text = work.khsosyTestResult;
      _controllers['bas_dars']!.text      = work.basDars.toString();
      _controllers['bas_test']!.text      = work.basTest.toString();
      _controllers['bas_result']!.text    = work.basTestResult;
      _controllers['trktr_dars']!.text    = work.trktrDars.toString();
      _controllers['trktr_test']!.text    = work.trktrTest.toString();
      _controllers['trktr_result']!.text  = work.trktrTestResult;
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تحميل بيانات ${DateFormat('yyyy/MM/dd').format(_selectedDate)}'), backgroundColor: AppTheme.secondary));
    } else {
      _initializeControllers();
    }
  }

  PriceSetting? _findPrice(String name) {
    try { return pricesList.firstWhere((p) => p.name == name); } catch (e) { return null; }
  }

  void _calculateAmounts(DailyWork work) {
    final shhnP   = _findPrice('شحن');
    final khsosyP = _findPrice('خصوصي');
    final basP    = _findPrice('باص');
    final trktrP  = _findPrice('تركتر');
    if (shhnP   != null) work.shhnAmount   = work.shhnDars   * shhnP.lessonPrice   + work.shhnTest   * shhnP.testPrice;
    if (khsosyP != null) work.khsosyAmount = work.khsosyDars * khsosyP.lessonPrice + work.khsosyTest * khsosyP.testPrice;
    if (basP    != null) work.basAmount    = work.basDars    * basP.lessonPrice    + work.basTest    * basP.testPrice;
    if (trktrP  != null) work.trktrAmount  = work.trktrDars  * trktrP.lessonPrice  + work.trktrTest  * trktrP.testPrice;
  }

  void _saveField(String prefix, dynamic value, String type) {
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    DailyWork work = dailyWorks.firstWhere((w) => w.date == dateStr, orElse: () => DailyWork(date: dateStr));
    if (!dailyWorks.any((w) => w.date == dateStr)) dailyWorks.add(work);
    switch (prefix) {
      case 'shhn':   if (type=='dars') work.shhnDars=value;   if (type=='test') work.shhnTest=value;   if (type=='result') work.shhnTestResult=value;   break;
      case 'khsosy': if (type=='dars') work.khsosyDars=value; if (type=='test') work.khsosyTest=value; if (type=='result') work.khsosyTestResult=value; break;
      case 'bas':    if (type=='dars') work.basDars=value;    if (type=='test') work.basTest=value;    if (type=='result') work.basTestResult=value;    break;
      case 'trktr':  if (type=='dars') work.trktrDars=value;  if (type=='test') work.trktrTest=value;  if (type=='result') work.trktrTestResult=value;  break;
    }
  }

  void _saveDashboardData() async {
    _formKey.currentState?.save();
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    DailyWork? work;
    try { work = dailyWorks.firstWhere((w) => w.date == dateStr); } catch (e) { work = null; }
    if (work != null) _calculateAmounts(work);
    await saveData();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم الحفظ وحساب المبالغ'), backgroundColor: AppTheme.success));
  }

  void _addNewDay() {
    setState(() { _selectedDate = DateTime.now(); _initializeControllers(); });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديد يوم جديد'), backgroundColor: AppTheme.primary));
  }

  void _deleteCurrentDay() async {
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (!dailyWorks.any((w) => w.date == dateStr)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا توجد بيانات لهذا اليوم'), backgroundColor: AppTheme.warning));
      return;
    }
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف اليوم'),
        content: Text('هل تريد حذف بيانات يوم ${DateFormat('yyyy/MM/dd').format(_selectedDate)}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      setState(() { dailyWorks.removeWhere((w) => w.date == dateStr); _initializeControllers(); });
      await saveData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم حذف اليوم'), backgroundColor: AppTheme.success));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الادخال اليومي'),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle), onPressed: _addNewDay, tooltip: 'يوم جديد'),
          IconButton(icon: const Icon(Icons.delete_forever), onPressed: _deleteCurrentDay, tooltip: 'حذف اليوم'),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveDashboardData, tooltip: 'حفظ'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(children: [
              InkWell(
                onTap: () async {
                  DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030), locale: const Locale('ar'));
                  if (picked != null && mounted) { setState(() { _selectedDate = picked; _loadExistingDayData(); }); }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: AppTheme.radiusMd, border: Border.all(color: const Color(0xFFE0E0E0)), boxShadow: const [AppTheme.shadowSm]),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(DateFormat('yyyy/MM/dd').format(_selectedDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    const Icon(Icons.calendar_today, color: AppTheme.primary),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _buildSection('شحن', AppTheme.primary, 'shhn')),
                const SizedBox(width: 12),
                Expanded(child: _buildSection('خصوصي', AppTheme.purple, 'khsosy')),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _buildSection('باص', AppTheme.teal, 'bas')),
                const SizedBox(width: 12),
                Expanded(child: _buildSection('تركتر', AppTheme.warning, 'trktr')),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saveDashboardData,
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ وحساب المبالغ', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd)),
                ),
              ),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Color color, String prefix) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.directions_car, color: color), const SizedBox(width: 6), Text(title, style: AppTheme.heading3.copyWith(color: color, fontSize: 18))]),
          const SizedBox(height: 12),
          TextFormField(decoration: AppTheme.inputDecoration(label: 'عدد الدروس', prefix: Icon(Icons.school, color: color)), keyboardType: TextInputType.number, controller: _controllers['${prefix}_dars'], onSaved: (v) => _saveField(prefix, int.tryParse(v ?? '0') ?? 0, 'dars')),
          const SizedBox(height: 8),
          TextFormField(decoration: AppTheme.inputDecoration(label: 'عدد الاختبارات', prefix: Icon(Icons.quiz, color: color)), keyboardType: TextInputType.number, controller: _controllers['${prefix}_test'], onSaved: (v) => _saveField(prefix, int.tryParse(v ?? '0') ?? 0, 'test')),
          const SizedBox(height: 8),
          TextFormField(decoration: AppTheme.inputDecoration(label: 'النتيجة', prefix: Icon(Icons.rate_review, color: color)), controller: _controllers['${prefix}_result'], onSaved: (v) => _saveField(prefix, v ?? 'غير محدد', 'result')),
        ]),
      ),
    );
  }
}