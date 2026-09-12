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
  
  bool _hasMutation = true;
  bool _hasAppeal = true;
  bool _hasEarlyPayment = true;

  int _startYear = 2024;
  int _endYear = 2026;

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

  void _calculateTax() {
    double size = double.tryParse(_sizeController.text) ?? 0;
    
    // Core Formula Rules based on document
    monthlyRent = size * 6.0;
    annualRent = monthlyRent * 10; // 10 months rule

    if (_hasMutation) {
      mutationRebate = annualRent * 0.40;
      taxableValue = annualRent - mutationRebate;
    } else {
      mutationRebate = 0;
      taxableValue = annualRent;
    }

    holdingTax = taxableValue * 0.12; // 12% Holding Tax Rate

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LCC Holding Tax Calculator'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Controls Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Property Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _sizeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Flat Size (Square Feet)',
                        border: OutlineInputBorder(),
                        suffixText: 'sq ft',
                      ),
                      onChanged: (_) => _calculateTax(),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Mutation Completed (40% Rebate)'),
                      value: _hasMutation,
                      onChanged: (val) {
                        _hasMutation = val;
                        _calculateTax();
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Appeal Submitted (15% Rebate)'),
                      value: _hasAppeal,
                      onChanged: (val) {
                        _hasAppeal = val;
                        _calculateTax();
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Paid Within Due Date (10% Rebate)'),
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
            const SizedBox(height: 16),

            // Date Range Selection Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Calculation Period', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _startYear,
                            decoration: const InputDecoration(labelText: 'Start Year', border: OutlineInputBorder()),
                            items: _years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _endYear,
                            decoration: const InputDecoration(labelText: 'End Year', border: OutlineInputBorder()),
                            items: _years.where((y) => y >= _startYear).map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
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
            const SizedBox(height: 16),

            // Breakdown Summary Card
            Card(
              color: Colors.teal.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Yearly Calculation Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _buildDataRow('Monthly Rent (6 Tk/sq ft):', '৳ ${monthlyRent.toStringAsFixed(0)}'),
                    _buildDataRow('Annual Valuation (10 Months):', '৳ ${annualRent.toStringAsFixed(0)}'),
                    if (_hasMutation) _buildDataRow('Mutation Rebate (40%):', '- ৳ ${mutationRebate.toStringAsFixed(0)}'),
                    _buildDataRow('Taxable Value:', '৳ ${taxableValue.toStringAsFixed(0)}'),
                    _buildDataRow('Holding Tax (12%):', '৳ ${holdingTax.toStringAsFixed(0)}'),
                    if (_hasAppeal) _buildDataRow('Appeal Rebate (15%):', '- ৳ ${appealRebate.toStringAsFixed(0)}'),
                    if (_hasEarlyPayment) _buildDataRow('Early Payment Rebate (10%):', '- ৳ ${earlyPaymentRebate.toStringAsFixed(0)}'),
                    const Divider(),
                    _buildDataRow('Net Tax Per Year:', '৳ ${finalYearlyTax.toStringAsFixed(0)}', isBold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Total Payable Display Banner
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Payable ($_selectedYearsCount ${_selectedYearsCount > 1 ? 'Years' : 'Year'})',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '৳ ${_totalPayment.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Copyright Footer
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Developed by AR | v2.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}