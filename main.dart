import 'package:flutter/material.dart';

void main() {
  runApp(const LCCHoldingTaxApp());
}

class LCCHoldingTaxApp extends StatelessWidget {
  const LCCHoldingTaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LCC Holding Tax Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HoldingTaxCalculatorScreen(),
    );
  }
}

class HoldingTaxCalculatorScreen extends StatefulWidget {
  const HoldingTaxCalculatorScreen({super.key});

  @override
  State<HoldingTaxCalculatorScreen> createState() => _HoldingTaxCalculatorScreenState();
}

class _HoldingTaxCalculatorScreenState extends State<HoldingTaxCalculatorScreen> {
  final TextEditingController _sizeController = TextEditingController(text: '1310');

  bool _isBengali = false;
  double _fontScale = 1.0; // Font sizing factor

  bool _hasMutation = true;
  bool _hasAppeal = true;
  bool _hasEarlyPayment = true;

  int _startYear = 2023; // Updated default
  int _endYear = 2026;   // Updated default

  final List<int> _years = List.generate(30, (index) => 2010 + index);

  // Calculation variables
  double monthlyRent = 0;
  double annualRent = 0;
  double mutationRebate = 0;
  double taxableValue = 0;
  double holdingTax = 0;
  double appealRebate = 0;
  double taxAfterAppeal = 0;
  double earlyPaymentRebate = 0;
  double finalYearlyTax = 0;

  @override
  void initState() {
    super.initState();
    _calculateTax();
  }

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  void _calculateTax() {
    double size = double.tryParse(_sizeController.text) ?? 0;

    monthlyRent = size * 6.0;
    annualRent = monthlyRent * 10;

    if (_hasMutation) {
      mutationRebate = annualRent * 0.40;
      taxableValue = annualRent - mutationRebate;
    } else {
      mutationRebate = 0;
      taxableValue = annualRent;
    }

    holdingTax = taxableValue * 0.12;

    if (_hasAppeal) {
      appealRebate = (holdingTax * 0.15).roundToDouble();
    } else {
      appealRebate = 0;
    }

    taxAfterAppeal = holdingTax - appealRebate;

    if (_hasEarlyPayment) {
      earlyPaymentRebate = (taxAfterAppeal * 0.10).roundToDouble();
    } else {
      earlyPaymentRebate = 0;
    }

    finalYearlyTax = taxAfterAppeal - earlyPaymentRebate;

    setState(() {});
  }

  int get _selectedYearsCount {
    if (_endYear >= _startYear) {
      return (_endYear - _startYear) + 1;
    }
    return 0;
  }

  double get _totalPayment {
    return finalYearlyTax * _selectedYearsCount;
  }

  String _formatNumber(num number) {
    String numStr = number.toStringAsFixed(0);
    if (!_isBengali) return numStr;
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    for (int i = 0; i < en.length; i++) {
      numStr = numStr.replaceAll(en[i], bn[i]);
    }
    return numStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isBengali ? 'এলসিসি হোল্ডিং ট্যাক্স ক্যালকুলেটর' : 'LCC Holding Tax Calculator',
          style: TextStyle(fontSize: 18 * _fontScale),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800), // Expanded width
            child: LayoutBuilder(
              builder: (context, constraints) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: constraints.maxWidth > 0 ? constraints.maxWidth : 600,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Bar: Language & Font Size Adjustment Controls
                          Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Language Segmented Control
                                Row(
                                  children: [
                                    const Icon(Icons.language, color: Colors.teal, size: 20),
                                    const SizedBox(width: 6),
                                    SegmentedButton<bool>(
                                      segments: [
                                        ButtonSegment<bool>(
                                          value: false,
                                          label: Text('English', style: TextStyle(fontSize: 12 * _fontScale, fontWeight: FontWeight.bold)),
                                        ),
                                        ButtonSegment<bool>(
                                          value: true,
                                          label: Text('বাংলা', style: TextStyle(fontSize: 12 * _fontScale, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                      selected: {_isBengali},
                                      onSelectionChanged: (Set<bool> newSelection) {
                                        setState(() {
                                          _isBengali = newSelection.first;
                                        });
                                      },
                                      style: const ButtonStyle(
                                        visualDensity: VisualDensity.compact,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),

                                // Font Size Controls (A- / A+)
                                Row(
                                  children: [
                                    Text(
                                      _isBengali ? 'ফন্ট:' : 'Font:',
                                      style: TextStyle(fontSize: 12 * _fontScale, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.teal),
                                      tooltip: 'Decrease Font Size',
                                      onPressed: () {
                                        if (_fontScale > 0.85) {
                                          setState(() => _fontScale -= 0.05);
                                        }
                                      },
                                    ),
                                    Text(
                                      '${(_fontScale * 100).round()}%',
                                      style: TextStyle(fontSize: 11 * _fontScale, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
                                      tooltip: 'Increase Font Size',
                                      onPressed: () {
                                        if (_fontScale < 1.35) {
                                          setState(() => _fontScale += 0.05);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Card 1: Property Details
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isBengali ? 'সম্পত্তির বিবরণ' : 'Property Details',
                                    style: TextStyle(fontSize: 16 * _fontScale, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // Enlarged & Yellow Text Field
                                  TextField(
                                    controller: _sizeController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 20 * _fontScale,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade900,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFFFFDE7), // Light yellow background
                                      labelText: _isBengali ? 'ফ্ল্যাটের আকার (বর্গফুট)' : 'Flat Size (Square Feet)',
                                      labelStyle: TextStyle(fontSize: 14 * _fontScale),
                                      border: const OutlineInputBorder(),
                                      suffixText: _isBengali ? 'বর্গফুট' : 'sq ft',
                                      suffixStyle: TextStyle(fontSize: 16 * _fontScale, fontWeight: FontWeight.bold),
                                      isDense: true,
                                    ),
                                    onChanged: (_) => _calculateTax(),
                                  ),
                                  
                                  SwitchListTile(
                                    dense: true,
                                    title: Text(
                                      _isBengali ? 'নামজারি সম্পন্ন (৪০% রিবেট)' : 'Mutation Completed (40% Rebate)',
                                      style: TextStyle(fontSize: 13 * _fontScale),
                                    ),
                                    value: _hasMutation,
                                    onChanged: (val) {
                                      _hasMutation = val;
                                      _calculateTax();
                                    },
                                  ),
                                  SwitchListTile(
                                    dense: true,
                                    title: Text(
                                      _isBengali ? 'আপিল জমাদানকৃত (১৫% রিবেট)' : 'Appeal Submitted (15% Rebate)',
                                      style: TextStyle(fontSize: 13 * _fontScale),
                                    ),
                                    value: _hasAppeal,
                                    onChanged: (val) {
                                      _hasAppeal = val;
                                      _calculateTax();
                                    },
                                  ),
                                  SwitchListTile(
                                    dense: true,
                                    title: Text(
                                      _isBengali ? 'নির্ধারিত সময়ের মধ্যে পরিশোধ (১০% রিবেট)' : 'Paid Within Due Date (10% Rebate)',
                                      style: TextStyle(fontSize: 13 * _fontScale),
                                    ),
                                    value: _hasEarlyPayment,
                                    onChanged: (val) {
                                      _hasEarlyPayment = val;
                                      _calculateTax();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Card 2: Calculation Period
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isBengali ? 'গণনার সময়কাল' : 'Calculation Period',
                                    style: TextStyle(fontSize: 16 * _fontScale, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<int>(
                                          value: _startYear,
                                          style: TextStyle(fontSize: 14 * _fontScale, color: Colors.black),
                                          decoration: InputDecoration(
                                            labelText: _isBengali ? 'শুরুর বছর' : 'Start Year',
                                            labelStyle: TextStyle(fontSize: 13 * _fontScale),
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          items: _years.map((y) => DropdownMenuItem(value: y, child: Text(_formatNumber(y)))).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                _startYear = val;
                                                if (_endYear < _startYear) _endYear = _startYear;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: DropdownButtonFormField<int>(
                                          value: _endYear,
                                          style: TextStyle(fontSize: 14 * _fontScale, color: Colors.black),
                                          decoration: InputDecoration(
                                            labelText: _isBengali ? 'শেষের বছর' : 'End Year',
                                            labelStyle: TextStyle(fontSize: 13 * _fontScale),
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          items: _years.where((y) => y >= _startYear).map((y) => DropdownMenuItem(value: y, child: Text(_formatNumber(y)))).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() => _endYear = val);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Card 3: Yearly Calculation Breakdown
                          Card(
                            color: Colors.teal.shade50,
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isBengali ? 'বার্ষিক কর হিসাবের বিবরণ' : 'Yearly Calculation Breakdown',
                                    style: TextStyle(fontSize: 16 * _fontScale, fontWeight: FontWeight.bold),
                                  ),
                                  const Divider(),
                                  _buildDataRow(
                                    _isBengali ? 'মাসিক ভাড়া (৬ টাকা/বর্গফুট):' : 'Monthly Rent (6 Tk/sq ft):',
                                    '৳ ${_formatNumber(monthlyRent)}',
                                  ),
                                  _buildDataRow(
                                    _isBengali ? 'বার্ষিক মূল্যায়ন (১০ মাস):' : 'Annual Valuation (10 Months):',
                                    '৳ ${_formatNumber(annualRent)}',
                                  ),
                                  if (_hasMutation)
                                    _buildDataRow(
                                      _isBengali ? 'নামজারি রিবেট (৪০%):' : 'Mutation Rebate (40%):',
                                      '- ৳ ${_formatNumber(mutationRebate)}',
                                    ),
                                  _buildDataRow(
                                    _isBengali ? 'করযোগ্য মূল্য:' : 'Taxable Value:',
                                    '৳ ${_formatNumber(taxableValue)}',
                                  ),
                                  _buildDataRow(
                                    _isBengali ? 'হোল্ডিং ট্যাক্স (১২%):' : 'Holding Tax (12%):',
                                    '৳ ${_formatNumber(holdingTax)}',
                                  ),
                                  if (_hasAppeal)
                                    _buildDataRow(
                                      _isBengali ? 'আপিল রিবেট (১৫%):' : 'Appeal Rebate (15%):',
                                      '- ৳ ${_formatNumber(appealRebate)}',
                                    ),
                                  if (_hasEarlyPayment)
                                    _buildDataRow(
                                      _isBengali ? 'সময়মত প্রদানের রিবেট (১০%):' : 'Early Payment Rebate (10%):',
                                      '- ৳ ${_formatNumber(earlyPaymentRebate)}',
                                    ),
                                  const Divider(),
                                  _buildDataRow(
                                    _isBengali ? 'প্রতি বছরের নিট কর:' : 'Net Tax Per Year:',
                                    '৳ ${_formatNumber(finalYearlyTax)}',
                                    isBold: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Total Payable Display Banner
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _isBengali
                                      ? 'মোট প্রদেয় (${_formatNumber(_selectedYearsCount)} ${_selectedYearsCount > 1 ? 'বছর' : 'বছর'})'
                                      : 'Total Payable ($_selectedYearsCount ${_selectedYearsCount > 1 ? 'Years' : 'Year'})',
                                  style: TextStyle(color: Colors.white, fontSize: 14 * _fontScale),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '৳ ${_formatNumber(_totalPayment)}',
                                  style: TextStyle(color: Colors.white, fontSize: 26 * _fontScale, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Footer
                          Text(
                            _isBengali ? 'প্রস্তুতকরণে AR | ভার্সন ২.০' : 'Developed by AR | v2.0',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11 * _fontScale,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12 * _fontScale, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 12 * _fontScale, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
