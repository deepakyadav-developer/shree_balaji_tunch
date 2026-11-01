import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../constant/app_info.dart' as app_info;

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Tunch Calculator Controllers ---
  final TextEditingController _tunchGrossWeightController =
      TextEditingController();
  final TextEditingController _tunchPercentController =
      TextEditingController(text: '91.60');
  final TextEditingController _tunchMeltingLossController =
      TextEditingController(text: '0.00');
  final TextEditingController _tunchRateController = TextEditingController();

  double _fineGoldWeight = 0.0;
  double _alloyWeight = 0.0;
  double _lossWeight = 0.0;
  double _fineGoldValue = 0.0;

  // --- Jewellery Price Calculator Controllers ---
  final TextEditingController _jewelWeightController = TextEditingController();
  final TextEditingController _jewelBaseRateController =
      TextEditingController();
  final TextEditingController _jewelMakingController =
      TextEditingController(text: '450');
  final TextEditingController _jewelGstController =
      TextEditingController(text: '3.0');

  String _selectedKarat = '22K (91.6%)';
  double _karatMultiplier = 0.916;
  bool _makingPerGram = true; // true = per gram, false = flat

  double _metalValue = 0.0;
  double _totalMaking = 0.0;
  double _gstAmount = 0.0;
  double _grandTotal = 0.0;

  // --- Old Gold Scrap / Exchange Controllers ---
  final TextEditingController _oldWeightController = TextEditingController();
  final TextEditingController _oldTunchController =
      TextEditingController(text: '85.0');
  final TextEditingController _oldDeductionController =
      TextEditingController(text: '2.0');
  final TextEditingController _oldRateController = TextEditingController();

  double _oldNetFineGold = 0.0;
  double _oldTotalPayout = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchLiveRates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tunchGrossWeightController.dispose();
    _tunchPercentController.dispose();
    _tunchMeltingLossController.dispose();
    _tunchRateController.dispose();

    _jewelWeightController.dispose();
    _jewelBaseRateController.dispose();
    _jewelMakingController.dispose();
    _jewelGstController.dispose();

    _oldWeightController.dispose();
    _oldTunchController.dispose();
    _oldDeductionController.dispose();
    _oldRateController.dispose();
    super.dispose();
  }

  void _fetchLiveRates() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection("rate").get();
      for (var doc in snapshot.docs) {
        String name = (doc.get('name') ?? '').toString().toLowerCase();
        double rate =
            double.tryParse((doc.get('rate') ?? '0').toString()) ?? 0.0;
        if (rate > 0 && (name.contains('gold') || name.contains('rtgs'))) {
          if (mounted) {
            setState(() {
              if (_tunchRateController.text.isEmpty) {
                _tunchRateController.text = rate.toStringAsFixed(0);
              }
              if (_jewelBaseRateController.text.isEmpty) {
                _jewelBaseRateController.text = rate.toStringAsFixed(0);
              }
              if (_oldRateController.text.isEmpty) {
                _oldRateController.text = rate.toStringAsFixed(0);
              }
            });
          }
          break;
        }
      }
    } catch (_) {}
  }

  // Calculation Logic 1: Tunch & Melting
  void _calculateTunch() {
    double gross = double.tryParse(_tunchGrossWeightController.text) ?? 0.0;
    double tunch = double.tryParse(_tunchPercentController.text) ?? 0.0;
    double lossPercent =
        double.tryParse(_tunchMeltingLossController.text) ?? 0.0;
    double ratePer10g = double.tryParse(_tunchRateController.text) ?? 0.0;

    double pureGold = gross * (tunch / 100.0);
    double loss = pureGold * (lossPercent / 100.0);
    double finalFineGold = (pureGold - loss).clamp(0.0, double.infinity);
    double alloy = (gross - finalFineGold).clamp(0.0, double.infinity);
    double value = finalFineGold * (ratePer10g / 10.0);

    setState(() {
      _fineGoldWeight = finalFineGold;
      _alloyWeight = alloy;
      _lossWeight = loss;
      _fineGoldValue = value;
    });

    FocusScope.of(context).unfocus();
  }

  // Calculation Logic 2: Jewellery Price & Karat
  void _calculateJewellery() {
    double weight = double.tryParse(_jewelWeightController.text) ?? 0.0;
    double base24kRate =
        double.tryParse(_jewelBaseRateController.text) ?? 0.0;
    double making = double.tryParse(_jewelMakingController.text) ?? 0.0;
    double gstPercent = double.tryParse(_jewelGstController.text) ?? 3.0;

    double perGram24k = base24kRate / 10.0;
    double perGramSelectedKarat = perGram24k * _karatMultiplier;

    double metalCost = perGramSelectedKarat * weight;
    double totalMakingCost = _makingPerGram ? (making * weight) : making;
    double subTotal = metalCost + totalMakingCost;
    double gstCost = (subTotal * gstPercent) / 100.0;

    setState(() {
      _metalValue = metalCost;
      _totalMaking = totalMakingCost;
      _gstAmount = gstCost;
      _grandTotal = subTotal + gstCost;
    });

    FocusScope.of(context).unfocus();
  }

  // Calculation Logic 3: Old Gold Scrap
  void _calculateOldGold() {
    double weight = double.tryParse(_oldWeightController.text) ?? 0.0;
    double tunch = double.tryParse(_oldTunchController.text) ?? 0.0;
    double deduction = double.tryParse(_oldDeductionController.text) ?? 0.0;
    double ratePer10g = double.tryParse(_oldRateController.text) ?? 0.0;

    double effectiveTunch = (tunch - deduction).clamp(0.0, 100.0);
    double netFine = weight * (effectiveTunch / 100.0);
    double totalPayout = netFine * (ratePer10g / 10.0);

    setState(() {
      _oldNetFineGold = netFine;
      _oldTotalPayout = totalPayout;
    });

    FocusScope.of(context).unfocus();
  }

  void _shareSlip(String text) {
    try {
      Share.share(text);
    } catch (_) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Slip copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text(
          'Bullion & Purity Suite',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: app_info.primaryColor,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Container(
            color: app_info.primaryDarkColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: app_info.goldColor,
              indicatorWeight: 3.5,
              labelColor: app_info.goldColor,
              unselectedLabelColor: Colors.white70,
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
              tabs: const [
                Tab(
                  icon: Icon(Icons.science_rounded, size: 20),
                  text: 'Tunch Test',
                ),
                Tab(
                  icon: Icon(Icons.diamond_rounded, size: 20),
                  text: 'Karat & GST',
                ),
                Tab(
                  icon: Icon(Icons.autorenew_rounded, size: 20),
                  text: 'Old Gold',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTunchTab(),
          _buildJewelleryTab(),
          _buildOldGoldTab(),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: TUNCH & MELTING LOSS
  // ==========================================
  Widget _buildTunchTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroBanner(
            title: 'Tunch & Melting Calculator',
            subtitle:
                'Instant Net Fine Gold, Alloy & Melting Loss breakdown for Gold testing.',
            icon: Icons.biotech_rounded,
            gradient: [app_info.primaryColor, app_info.primaryLightColor],
          ),
          const SizedBox(height: 18),
          _buildCardContainer([
            _buildInputField(
              label: 'Gross Weight (ग्राम)',
              hint: 'e.g. 10.500',
              controller: _tunchGrossWeightController,
              icon: Icons.scale_rounded,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'Tunch / Purity %',
                    hint: 'e.g. 91.60',
                    controller: _tunchPercentController,
                    icon: Icons.percent_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    label: 'Melting Loss %',
                    hint: 'e.g. 0.50',
                    controller: _tunchMeltingLossController,
                    icon: Icons.trending_down_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildInputField(
              label: '24K Live Rate (per 10g)',
              hint: 'e.g. 74500',
              controller: _tunchRateController,
              icon: Icons.currency_rupee_rounded,
            ),
          ]),
          const SizedBox(height: 20),
          _buildActionButton(
            label: 'CALCULATE TUNCH RESULT',
            onTap: _calculateTunch,
            color: app_info.amberColor,
          ),
          if (_fineGoldWeight > 0) ...[
            const SizedBox(height: 20),
            _buildTunchResultCard(),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTunchResultCard() {
    String slipText = '''
📜 SHREE BALAJI TUNCH - TESTING SLIP
---------------------------------------
Gross Weight: ${_tunchGrossWeightController.text} g
Tunch Purity: ${_tunchPercentController.text} %
Melting Loss: ${_tunchMeltingLossController.text} %
---------------------------------------
✨ Pure Fine Gold: ${_fineGoldWeight.toStringAsFixed(3)} g
⚠️ Alloy / Khot: ${_alloyWeight.toStringAsFixed(3)} g
🔥 Loss Weight: ${_lossWeight.toStringAsFixed(3)} g
💰 Fine Value (₹): ₹${_fineGoldValue.toStringAsFixed(2)}
---------------------------------------
Generated via Shree Balaji Tunch App
''';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: app_info.goldColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: app_info.primaryDarkColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TUNCH TEST REPORT',
                style: TextStyle(
                  color: app_info.primaryDarkColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
              IconButton(
                onPressed: () => _shareSlip(slipText),
                icon: Icon(Icons.share_rounded, color: app_info.primaryColor),
                tooltip: 'Share Slip',
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          _buildResultRow(
            'Fine Gold (शुद्ध सोना)',
            '${_fineGoldWeight.toStringAsFixed(3)} g',
            isHighlight: true,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 8),
          _buildResultRow(
            'Impurity / Alloy (खोट)',
            '${_alloyWeight.toStringAsFixed(3)} g',
          ),
          if (_lossWeight > 0) ...[
            const SizedBox(height: 8),
            _buildResultRow(
              'Melting Loss (गलाई)',
              '${_lossWeight.toStringAsFixed(3)} g',
            ),
          ],
          const SizedBox(height: 8),
          _buildResultRow(
            'Estimated Pure Value',
            '₹ ${_fineGoldValue.toStringAsFixed(2)}',
            isHighlight: true,
            color: app_info.primaryColor,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _shareSlip(slipText),
              icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 16),
              label: const Text('SHARE TESTING SLIP'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF25D366),
                side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: JEWELLERY PRICE & KARAT
  // ==========================================
  Widget _buildJewelleryTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroBanner(
            title: 'Karat Value & Billing',
            subtitle:
                'Accurate jewellery estimation with 14K to 24K conversion, making charges, and GST.',
            icon: Icons.diamond_rounded,
            gradient: [const Color(0xFF0F2027), const Color(0xFF2C5364)],
          ),
          const SizedBox(height: 18),
          Text(
            'SELECT KARAT / PURITY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildKaratChip('24K (99.9%)', 0.999),
                _buildKaratChip('22K (91.6%)', 0.916),
                _buildKaratChip('20K (83.3%)', 0.833),
                _buildKaratChip('18K (75.0%)', 0.750),
                _buildKaratChip('14K (58.5%)', 0.585),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCardContainer([
            _buildInputField(
              label: 'Jewellery Weight (Grams)',
              hint: 'e.g. 15.200',
              controller: _jewelWeightController,
              icon: Icons.scale_rounded,
            ),
            const SizedBox(height: 14),
            _buildInputField(
              label: '24K Base Rate (per 10g)',
              hint: 'e.g. 74500',
              controller: _jewelBaseRateController,
              icon: Icons.currency_rupee_rounded,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: _makingPerGram
                        ? 'Making (₹ / gram)'
                        : 'Flat Making (₹)',
                    hint: _makingPerGram ? 'e.g. 450' : 'e.g. 2500',
                    controller: _jewelMakingController,
                    icon: Icons.architecture_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInputField(
                    label: 'GST (%)',
                    hint: '3.0',
                    controller: _jewelGstController,
                    icon: Icons.percent_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Making Type: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                ChoiceChip(
                  label: const Text('Per Gram'),
                  selected: _makingPerGram,
                  onSelected: (val) {
                    setState(() => _makingPerGram = true);
                  },
                  selectedColor: app_info.primaryColor.withOpacity(0.15),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Flat ₹'),
                  selected: !_makingPerGram,
                  onSelected: (val) {
                    setState(() => _makingPerGram = false);
                  },
                  selectedColor: app_info.primaryColor.withOpacity(0.15),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 20),
          _buildActionButton(
            label: 'CALCULATE ESTIMATED PRICE',
            onTap: _calculateJewellery,
            color: app_info.orangeColor,
          ),
          if (_grandTotal > 0) ...[
            const SizedBox(height: 20),
            _buildJewelleryResultCard(),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildKaratChip(String label, double multiplier) {
    bool isSelected = _selectedKarat == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: app_info.primaryColor,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedKarat = label;
              _karatMultiplier = multiplier;
            });
          }
        },
      ),
    );
  }

  Widget _buildJewelleryResultCard() {
    String quoteText = '''
💎 JEWELLERY ESTIMATION QUOTE
---------------------------------------
Purity / Karat: $_selectedKarat
Weight: ${_jewelWeightController.text} g
Base 24K Rate: ₹${_jewelBaseRateController.text} / 10g
---------------------------------------
• Metal Cost: ₹${_metalValue.toStringAsFixed(2)}
• Making Charges: ₹${_totalMaking.toStringAsFixed(2)}
• GST (${_jewelGstController.text}%): ₹${_gstAmount.toStringAsFixed(2)}
---------------------------------------
⭐ TOTAL ESTIMATED PRICE: ₹${_grandTotal.toStringAsFixed(2)}
---------------------------------------
Calculated on Shree Balaji Tunch
''';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [app_info.primaryDarkColor, app_info.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: app_info.primaryDarkColor.withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FINAL BILL BREAKDOWN',
                style: TextStyle(
                  color: app_info.goldColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              IconButton(
                onPressed: () => _shareSlip(quoteText),
                icon: const Icon(Icons.share_rounded, color: Colors.white),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          _buildLightResultRow(
              'Metal Value ($_selectedKarat)', '₹ ${_metalValue.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _buildLightResultRow('Making Charges', '₹ ${_totalMaking.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _buildLightResultRow('GST (${_jewelGstController.text}%)', '₹ ${_gstAmount.toStringAsFixed(2)}'),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Payable',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '₹ ${_grandTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  color: app_info.goldColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: OLD GOLD SCRAP & EXCHANGE
  // ==========================================
  Widget _buildOldGoldTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroBanner(
            title: 'Old Gold Scrap & Exchange',
            subtitle:
                'Calculate exact cash value or exchange value when selling old jewelry.',
            icon: Icons.autorenew_rounded,
            gradient: [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
          ),
          const SizedBox(height: 18),
          _buildCardContainer([
            _buildInputField(
              label: 'Old Gold Weight (Grams)',
              hint: 'e.g. 22.500',
              controller: _oldWeightController,
              icon: Icons.scale_rounded,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'Tunch / Purity %',
                    hint: 'e.g. 85.0',
                    controller: _oldTunchController,
                    icon: Icons.percent_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    label: 'Deduction / कट %',
                    hint: 'e.g. 2.0',
                    controller: _oldDeductionController,
                    icon: Icons.cut_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildInputField(
              label: 'Buying Rate 24K (per 10g)',
              hint: 'e.g. 74500',
              controller: _oldRateController,
              icon: Icons.currency_rupee_rounded,
            ),
          ]),
          const SizedBox(height: 20),
          _buildActionButton(
            label: 'CALCULATE OLD GOLD VALUE',
            onTap: _calculateOldGold,
            color: const Color(0xFF6A11CB),
          ),
          if (_oldNetFineGold > 0) ...[
            const SizedBox(height: 20),
            _buildOldGoldResultCard(),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildOldGoldResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EXCHANGE / PAYOUT SUMMARY',
            style: TextStyle(
              color: Color(0xFF6A11CB),
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          _buildResultRow(
            'Net Fine Gold',
            '${_oldNetFineGold.toStringAsFixed(3)} g',
            isHighlight: true,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 8),
          _buildResultRow(
            'Total Payout Value',
            '₹ ${_oldTotalPayout.toStringAsFixed(2)}',
            isHighlight: true,
            color: const Color(0xFF6A11CB),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SHARED REUSABLE WIDGETS
  // ==========================================
  Widget _buildHeroBanner({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: app_info.goldColor, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(icon, color: app_info.primaryColor, size: 18),
            filled: true,
            fillColor: const Color(0xFFF9FAFD),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: app_info.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        shadowColor: color.withOpacity(0.4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value,
      {bool isHighlight = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlight ? 15 : 13,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 17 : 14,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildLightResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
