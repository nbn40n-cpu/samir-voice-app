import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'main.dart';

class ReportsScreen extends StatefulWidget {
  final String reportType;
  const ReportsScreen({super.key, required this.reportType});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int? _selectedMonth;
  int? _selectedYear;
  final List<int> _months = List.generate(12, (i) => i + 1);
  final List<int> _years  = List.generate(10, (i) => DateTime.now().year - i);
  static const List<String> _monthNames = ['','يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
    _selectedYear  = DateTime.now().year;
  }

  List<DailyWork> _filterData() {
    return dailyWorks.where((work) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(work.date);
      if (widget.reportType == 'yearly_all') return date.year == _selectedYear;
      return date.year == _selectedYear && date.month == _selectedMonth;
    }).toList();
  }

  String _getReportTitle() {
    switch (widget.reportType) {
      case 'main_month':        return 'التقرير الرئيسي الشهري';
      case 'yearly_all':        return 'التقرير السنوي الكامل';
      case 'shhn_khsosy_month': return 'تقرير شحن وخصوصي';
      case 'bas_trktr_month':   return 'تقرير باص وتركتر';
      case 'shhn_month':        return 'تقرير شحن';
      case 'khsosy_month':      return 'تقرير خصوصي';
      case 'bas_month':         return 'تقرير باص';
      case 'trktr_month':       return 'تقرير تركتر';
      default:                  return 'تقرير';
    }
  }

  Future<void> _printReport() async {
    final data  = _filterData();
    final doc   = pw.Document();
    final font  = await PdfGoogleFonts.cairoRegular();
    final bold  = await PdfGoogleFonts.cairoBold();
    String period = widget.reportType == 'yearly_all'
        ? '$_selectedYear'
        : '${_monthNames[_selectedMonth ?? 1]} $_selectedYear';
    List<_VehicleInfo> vehicles = _buildVehicleList(data);

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      textDirection: pw.TextDirection.rtl,
      build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(16), color: PdfColors.blue800,
          child: pw.Column(children: [
            pw.Text('نظام سمير المحاسبي', style: pw.TextStyle(font: bold, fontSize: 22, color: PdfColors.white)),
            pw.SizedBox(height: 4),
            pw.Text(_getReportTitle(), style: pw.TextStyle(font: font, fontSize: 14, color: PdfColor(1,1,1,0.7))),
            pw.Text('الفترة: $period',  style: pw.TextStyle(font: font, fontSize: 12, color: PdfColor(1,1,1,0.7))),
          ]),
        ),
        pw.SizedBox(height: 20),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {0: const pw.FlexColumnWidth(2), 1: const pw.FlexColumnWidth(2), 2: const pw.FlexColumnWidth(2), 3: const pw.FlexColumnWidth(3)},
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue100),
              children: ['النوع','الدروس','الاختبارات','المبلغ'].map((h) =>
                pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(h, style: pw.TextStyle(font: bold, fontSize: 12), textAlign: pw.TextAlign.center))
              ).toList(),
            ),
            ...vehicles.map((v) => pw.TableRow(children: [
              _pdfCell(v.name, font), _pdfCell(v.dars.toString(), font),
              _pdfCell(v.test.toString(), font),
              _pdfCell('${v.amount.toStringAsFixed(0)} ₪', bold),
            ])),
            // سطر المجموع
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _pdfCell('المجموع', bold),
                _pdfCell(vehicles.fold(0,(s,v)=>s+v.dars).toString(), bold),
                _pdfCell(vehicles.fold(0,(s,v)=>s+v.test).toString(), bold),
                _pdfCell('${vehicles.fold(0.0,(s,v)=>s+v.amount).toStringAsFixed(0)} ₪', bold),
              ],
            ),
          ],
        ),
        if (_isSingleType()) ...[
          pw.SizedBox(height: 20),
          pw.Text('التفصيل اليومي', style: pw.TextStyle(font: bold, fontSize: 14)),
          pw.SizedBox(height: 8),
          ...data.where((w) => _getDayAmount(w) > 0).map((work) =>
            pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 4),
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(border: pw.Border(right: const pw.BorderSide(color: PdfColors.blue600, width: 3)), color: PdfColors.grey50),
              child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text(work.date, style: pw.TextStyle(font: font, fontSize: 11)),
                pw.Text('دروس: ${_getDayDars(work)}  اختبارات: ${_getDayTest(work)}', style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey700)),
                pw.Text('${_getDayAmount(work).toStringAsFixed(0)} ₪', style: pw.TextStyle(font: bold, fontSize: 12)),
              ]),
            )
          ),
        ],
        pw.Spacer(),
        pw.Text('تاريخ الطباعة: ${DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey500)),
      ]),
    ));
    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  pw.Widget _pdfCell(String text, pw.Font font) => pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 12), textAlign: pw.TextAlign.center),
  );

  List<_VehicleInfo> _buildVehicleList(List<DailyWork> data) {
    final all = [
      _VehicleInfo('شحن',    Icons.local_shipping, AppTheme.primary, data.fold(0,(s,w)=>s+w.shhnDars),   data.fold(0,(s,w)=>s+w.shhnTest),   data.fold(0.0,(s,w)=>s+w.shhnAmount)),
      _VehicleInfo('خصوصي', Icons.directions_car, AppTheme.purple,  data.fold(0,(s,w)=>s+w.khsosyDars), data.fold(0,(s,w)=>s+w.khsosyTest), data.fold(0.0,(s,w)=>s+w.khsosyAmount)),
      _VehicleInfo('باص',   Icons.directions_bus, AppTheme.teal,    data.fold(0,(s,w)=>s+w.basDars),    data.fold(0,(s,w)=>s+w.basTest),    data.fold(0.0,(s,w)=>s+w.basAmount)),
      _VehicleInfo('تركتر', Icons.agriculture,    AppTheme.warning, data.fold(0,(s,w)=>s+w.trktrDars),  data.fold(0,(s,w)=>s+w.trktrTest),  data.fold(0.0,(s,w)=>s+w.trktrAmount)),
    ];
    switch (widget.reportType) {
      case 'shhn_khsosy_month': return all.sublist(0,2);
      case 'bas_trktr_month':   return all.sublist(2,4);
      case 'shhn_month':        return [all[0]];
      case 'khsosy_month':      return [all[1]];
      case 'bas_month':         return [all[2]];
      case 'trktr_month':       return [all[3]];
      default:                  return all;
    }
  }

  bool   _isSingleType()        => ['shhn_month','khsosy_month','bas_month','trktr_month'].contains(widget.reportType);
  int    _getDayDars(DailyWork w)   { switch(widget.reportType){ case 'shhn_month': return w.shhnDars;   case 'khsosy_month': return w.khsosyDars; case 'bas_month': return w.basDars;   default: return w.trktrDars; } }
  int    _getDayTest(DailyWork w)   { switch(widget.reportType){ case 'shhn_month': return w.shhnTest;   case 'khsosy_month': return w.khsosyTest; case 'bas_month': return w.basTest;   default: return w.trktrTest; } }
  double _getDayAmount(DailyWork w) { switch(widget.reportType){ case 'shhn_month': return w.shhnAmount; case 'khsosy_month': return w.khsosyAmount; case 'bas_month': return w.basAmount; default: return w.trktrAmount; } }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getReportTitle(), style: const TextStyle(fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.print), tooltip: 'طباعة', onPressed: _filterData().isEmpty ? null : _printReport),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            if (!widget.reportType.contains('yearly'))
              Expanded(child: DropdownButtonFormField<int>(
                value: _selectedMonth, isDense: true,
                decoration: InputDecoration(labelText: 'الشهر', contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), border: OutlineInputBorder(borderRadius: AppTheme.radiusSm)),
                items: _months.map((m) => DropdownMenuItem(value: m, child: Text(_monthNames[m], style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _selectedMonth = v),
              )),
            if (!widget.reportType.contains('yearly')) const SizedBox(width: 10),
            Expanded(child: DropdownButtonFormField<int>(
              value: _selectedYear, isDense: true,
              decoration: InputDecoration(labelText: 'السنة', contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), border: OutlineInputBorder(borderRadius: AppTheme.radiusSm)),
              items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString(), style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) => setState(() => _selectedYear = v),
            )),
          ]),
          const SizedBox(height: 12),
          Expanded(child: _buildReportContent()),
        ]),
      ),
    );
  }

  Widget _buildReportContent() {
    final data = _filterData();
    if (data.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[300]),
        const SizedBox(height: 12),
        const Text('لا توجد بيانات لهذه الفترة', style: TextStyle(fontSize: 16, color: AppTheme.textLight)),
      ]));
    }
    return SingleChildScrollView(child: _buildDataTable(data));
  }

  Widget _buildDataTable(List<DailyWork> data) {
    final vehicles = _buildVehicleList(data);
    if (!_isSingleType()) return _summaryCard(vehicles);
    return _detailCard(data, vehicles.first);
  }

  // ─── بطاقة ملخص (تقارير متعددة الأنواع) ─────────────────────────────────
  Widget _summaryCard(List<_VehicleInfo> vehicles) {
    double total  = vehicles.fold(0.0, (s, v) => s + v.amount);
    int totalDars = vehicles.fold(0,   (s, v) => s + v.dars);
    int totalTest = vehicles.fold(0,   (s, v) => s + v.test);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ...vehicles.map((v) => _vehicleBox(v)),
      const SizedBox(height: 10),
      // ─── مجموع الدروس والاختبارات ───
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: AppTheme.radiusSm, border: Border.all(color: AppTheme.primary.withOpacity(0.3)), boxShadow: [AppTheme.shadowSm]),
        child: Row(children: [
          Expanded(child: Row(children: [
            const Icon(Icons.school, color: AppTheme.primary, size: 20),
            const SizedBox(width: 6),
            const Text('مجموع الدروس: ', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
            Text('$totalDars', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
          ])),
          Expanded(child: Row(children: [
            const Icon(Icons.quiz, color: AppTheme.purple, size: 20),
            const SizedBox(width: 6),
            const Text('مجموع الاختبارات: ', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
            Text('$totalTest', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.purple)),
          ])),
        ]),
      ),
      // ─── المجموع المالي ───
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.success, Color(0xFF43A047)]), borderRadius: AppTheme.radiusMd, boxShadow: [AppTheme.shadowSm]),
        child: Row(children: [
          const Icon(Icons.account_balance_wallet, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          const Expanded(child: Text('المجموع الكلي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
          Text('${total.toStringAsFixed(0)} ₪', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
      ),
    ]);
  }

  Widget _vehicleBox(_VehicleInfo v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: AppTheme.radiusSm, border: Border.all(color: v.color.withOpacity(0.3)), boxShadow: [AppTheme.shadowSm]),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: v.color, borderRadius: const BorderRadius.vertical(top: Radius.circular(11))),
          child: Row(children: [
            Icon(v.icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(v.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
            Text('${v.amount.toStringAsFixed(0)} ₪', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            _infoChip(Icons.school, 'دروس', v.dars.toString(), v.color),
            const SizedBox(width: 8),
            _infoChip(Icons.quiz, 'اختبارات', v.test.toString(), v.color),
          ]),
        ),
      ]),
    );
  }

  Widget _infoChip(IconData icon, String label, String value, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: AppTheme.radiusSm),
      child: Row(children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text('$label: ', style: TextStyle(fontSize: 12, color: color)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ]),
    ));
  }

  // ─── بطاقة تفصيلية (تقارير نوع واحد) ────────────────────────────────────
  Widget _detailCard(List<DailyWork> data, _VehicleInfo info) {
    int totalDars   = data.fold(0,   (s, w) => s + _getDayDars(w));
    int totalTest   = data.fold(0,   (s, w) => s + _getDayTest(w));
    double totalAmt = data.fold(0.0, (s, w) => s + _getDayAmount(w));
    final days = data.where((w) => _getDayDars(w) > 0 || _getDayTest(w) > 0).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // رأس ملون
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: info.color, borderRadius: AppTheme.radiusSm, boxShadow: [AppTheme.shadowSm]),
        child: Row(children: [
          Icon(info.icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(info.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const Spacer(),
          Text('${totalAmt.toStringAsFixed(0)} ₪', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
      ),
      const SizedBox(height: 10),
      // تفصيل الأيام
      if (days.isEmpty)
        const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('لا توجد بيانات', style: AppTheme.bodyMedium)))
      else
        ...days.map((work) {
          double a = _getDayAmount(work);
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: AppTheme.radiusSm, border: Border(right: BorderSide(color: info.color, width: 3)), boxShadow: [AppTheme.shadowSm]),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(work.date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Wrap(spacing: 6, children: [
                  _tag('دروس: ${_getDayDars(work)}', info.color),
                  _tag('اختبارات: ${_getDayTest(work)}', info.color),
                ]),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: info.color.withOpacity(0.1), borderRadius: AppTheme.radiusSm),
                child: Text('${a.toStringAsFixed(0)} ₪', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: info.color)),
              ),
            ]),
          );
        }),
      const SizedBox(height: 10),
      // ─── مجموع في الأسفل ───
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: AppTheme.radiusSm, border: Border.all(color: info.color.withOpacity(0.4)), boxShadow: [AppTheme.shadowSm]),
        child: Row(children: [
          Expanded(child: Row(children: [
            Icon(Icons.school, color: info.color, size: 20),
            const SizedBox(width: 6),
            const Text('مجموع الدروس: ', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
            Text('$totalDars', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: info.color)),
          ])),
          Expanded(child: Row(children: [
            Icon(Icons.quiz, color: info.color, size: 20),
            const SizedBox(width: 6),
            const Text('مجموع الاختبارات: ', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
            Text('$totalTest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: info.color)),
          ])),
        ]),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [info.color, info.color.withOpacity(0.7)]), borderRadius: AppTheme.radiusMd, boxShadow: [AppTheme.shadowSm]),
        child: Row(children: [
          const Icon(Icons.account_balance_wallet, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          const Expanded(child: Text('المجموع الكلي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
          Text('${totalAmt.toStringAsFixed(0)} ₪', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
      ),
    ]);
  }

  Widget _whiteChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: AppTheme.radiusSm),
      child: Column(children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label,  style: const TextStyle(fontSize: 10, color: Colors.white)),
      ]),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _VehicleInfo {
  final String name;
  final IconData icon;
  final Color color;
  final int dars, test;
  final double amount;
  _VehicleInfo(this.name, this.icon, this.color, this.dars, this.test, this.amount);
}