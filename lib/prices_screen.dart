import 'package:flutter/material.dart';
import 'main.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});
  @override
  State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shhnLesson   = TextEditingController();
  final _shhnTest     = TextEditingController();
  final _khsosyLesson = TextEditingController();
  final _khsosyTest   = TextEditingController();
  final _basLesson    = TextEditingController();
  final _basTest      = TextEditingController();
  final _trktrLesson  = TextEditingController();
  final _trktrTest    = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentPrices();
  }

  @override
  void dispose() {
    _shhnLesson.dispose(); _shhnTest.dispose();
    _khsosyLesson.dispose(); _khsosyTest.dispose();
    _basLesson.dispose(); _basTest.dispose();
    _trktrLesson.dispose(); _trktrTest.dispose();
    super.dispose();
  }

  void _loadCurrentPrices() {
    for (var p in pricesList) {
      if (p.name == 'شحن')    { _shhnLesson.text = p.lessonPrice.toString();   _shhnTest.text = p.testPrice.toString(); }
      if (p.name == 'خصوصي') { _khsosyLesson.text = p.lessonPrice.toString(); _khsosyTest.text = p.testPrice.toString(); }
      if (p.name == 'باص')   { _basLesson.text = p.lessonPrice.toString();    _basTest.text = p.testPrice.toString(); }
      if (p.name == 'تركتر') { _trktrLesson.text = p.lessonPrice.toString();  _trktrTest.text = p.testPrice.toString(); }
    }
    if (_shhnLesson.text.isEmpty)   _shhnLesson.text = '0';
    if (_shhnTest.text.isEmpty)     _shhnTest.text = '0';
    if (_khsosyLesson.text.isEmpty) _khsosyLesson.text = '0';
    if (_khsosyTest.text.isEmpty)   _khsosyTest.text = '0';
    if (_basLesson.text.isEmpty)    _basLesson.text = '0';
    if (_basTest.text.isEmpty)      _basTest.text = '0';
    if (_trktrLesson.text.isEmpty)  _trktrLesson.text = '0';
    if (_trktrTest.text.isEmpty)    _trktrTest.text = '0';
  }

  void _savePrices() async {
    if (!_formKey.currentState!.validate()) return;
    pricesList = [
      PriceSetting(id: 'shhn',   name: 'شحن',    description: 'شحن',    lessonPrice: double.tryParse(_shhnLesson.text)   ?? 0.0, testPrice: double.tryParse(_shhnTest.text)   ?? 0.0),
      PriceSetting(id: 'khsosy', name: 'خصوصي',  description: 'خصوصي',  lessonPrice: double.tryParse(_khsosyLesson.text) ?? 0.0, testPrice: double.tryParse(_khsosyTest.text) ?? 0.0),
      PriceSetting(id: 'bas',    name: 'باص',     description: 'باص',    lessonPrice: double.tryParse(_basLesson.text)    ?? 0.0, testPrice: double.tryParse(_basTest.text)    ?? 0.0),
      PriceSetting(id: 'trktr',  name: 'تركتر',   description: 'تركتر',  lessonPrice: double.tryParse(_trktrLesson.text)  ?? 0.0, testPrice: double.tryParse(_trktrTest.text)  ?? 0.0),
    ];
    await saveData(); // ✅ بدون _ عشان يشتغل من ملف ثاني
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم حفظ جميع الأسعار'), backgroundColor: AppTheme.success));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الأسعار')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            Container(
              padding: const EdgeInsets.all(14), margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: AppTheme.radiusMd),
              child: const Row(children: [Icon(Icons.info_outline, color: AppTheme.primary), SizedBox(width: 10), Expanded(child: Text('المبلغ = عدد الدروس × سعر الدرس + عدد الاختبارات × سعر الاختبار', style: TextStyle(color: AppTheme.primary, fontSize: 14)))]),
            ),
            _buildPriceCard('شحن',   Icons.local_shipping, AppTheme.primary, _shhnLesson,   _shhnTest),
            const SizedBox(height: 16),
            _buildPriceCard('خصوصي', Icons.directions_car, AppTheme.purple,  _khsosyLesson, _khsosyTest),
            const SizedBox(height: 16),
            _buildPriceCard('باص',   Icons.directions_bus, AppTheme.teal,    _basLesson,    _basTest),
            const SizedBox(height: 16),
            _buildPriceCard('تركتر', Icons.agriculture,    AppTheme.warning,  _trktrLesson,  _trktrTest),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton.icon(
                onPressed: _savePrices,
                icon: const Icon(Icons.save),
                label: const Text('حفظ جميع الأسعار', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildPriceCard(String title, IconData icon, Color color, TextEditingController lessonCtrl, TextEditingController testCtrl) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: AppTheme.radiusSm), child: Icon(icon, color: color, size: 28)),
            const SizedBox(width: 12),
            Text(title, style: AppTheme.heading3.copyWith(color: color)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: TextFormField(controller: lessonCtrl, decoration: AppTheme.inputDecoration(label: 'سعر الدرس (شيكل)', prefix: Icon(Icons.school, color: color)), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => (double.tryParse(v ?? '') == null) ? 'رقم غير صحيح' : null)),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(controller: testCtrl, decoration: AppTheme.inputDecoration(label: 'سعر الاختبار (شيكل)', prefix: Icon(Icons.quiz, color: color)), keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => (double.tryParse(v ?? '') == null) ? 'رقم غير صحيح' : null)),
          ]),
        ]),
      ),
    );
  }
}