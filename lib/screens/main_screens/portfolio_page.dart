import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../../constant/app_info.dart' as app_info;

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final TextEditingController _goldController = TextEditingController();
  final TextEditingController _silverController = TextEditingController();
  final TextEditingController _goldBuyPriceController = TextEditingController();
  final TextEditingController _silverBuyPriceController = TextEditingController();

  double _goldHoldings = 0.0; // in grams
  double _silverHoldings = 0.0; // in kilograms
  double _goldAvgBuyRate = 0.0; // per 10g
  double _silverAvgBuyRate = 0.0; // per 1kg

  @override
  void initState() {
    super.initState();
    _loadHoldings();
  }

  @override
  void dispose() {
    _goldController.dispose();
    _silverController.dispose();
    _goldBuyPriceController.dispose();
    _silverBuyPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadHoldings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _goldHoldings = prefs.getDouble('goldHoldings') ?? 0.0;
      _silverHoldings = prefs.getDouble('silverHoldings') ?? 0.0;
      _goldAvgBuyRate = prefs.getDouble('goldAvgBuyRate') ?? 0.0;
      _silverAvgBuyRate = prefs.getDouble('silverAvgBuyRate') ?? 0.0;

      _goldController.text =
          _goldHoldings > 0 ? _goldHoldings.toStringAsFixed(2) : '';
      _silverController.text =
          _silverHoldings > 0 ? _silverHoldings.toStringAsFixed(2) : '';
      _goldBuyPriceController.text =
          _goldAvgBuyRate > 0 ? _goldAvgBuyRate.toStringAsFixed(0) : '';
      _silverBuyPriceController.text =
          _silverAvgBuyRate > 0 ? _silverAvgBuyRate.toStringAsFixed(0) : '';
    });
  }

  Future<void> _saveHoldings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double gold = double.tryParse(_goldController.text) ?? 0.0;
    double silver = double.tryParse(_silverController.text) ?? 0.0;
    double goldBuy = double.tryParse(_goldBuyPriceController.text) ?? 0.0;
    double silverBuy = double.tryParse(_silverBuyPriceController.text) ?? 0.0;

    await prefs.setDouble('goldHoldings', gold);
    await prefs.setDouble('silverHoldings', silver);
    await prefs.setDouble('goldAvgBuyRate', goldBuy);
    await prefs.setDouble('silverAvgBuyRate', silverBuy);

    setState(() {
      _goldHoldings = gold;
      _silverHoldings = silver;
      _goldAvgBuyRate = goldBuy;
      _silverAvgBuyRate = silverBuy;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Portfolio Updated Successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _sharePortfolio(double totalVal, double goldVal, double silverVal) {
    String summary = '''
💼 MY PRECIOUS METALS PORTFOLIO
---------------------------------------
✨ Gold Holdings: ${_goldHoldings.toStringAsFixed(2)} g (₹${goldVal.toStringAsFixed(2)})
⚪ Silver Holdings: ${_silverHoldings.toStringAsFixed(2)} kg (₹${silverVal.toStringAsFixed(2)})
---------------------------------------
💰 Total Live Value: ₹${totalVal.toStringAsFixed(2)}
---------------------------------------
Tracked with Shree Balaji Tunch
''';
    try {
      Share.share(summary);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text(
          'Bullion Portfolio',
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("rate").snapshots(),
        builder: (context, snapshot) {
          double liveGoldRate = 0.0; // per 10g
          double liveSilverRate = 0.0; // per 1kg

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            for (var doc in snapshot.data!.docs) {
              String name = (doc.get('name') ?? '').toString().toLowerCase();
              double rate =
                  double.tryParse((doc.get('rate') ?? '0').toString()) ?? 0.0;
              if (rate > 0) {
                if ((name.contains('gold') || name.contains('rtgs')) &&
                    liveGoldRate == 0) {
                  liveGoldRate = rate;
                } else if ((name.contains('silver') ||
                        name.contains('chandi')) &&
                    liveSilverRate == 0) {
                  liveSilverRate = rate;
                }
              }
            }
            if (liveGoldRate == 0 && snapshot.data!.docs.isNotEmpty) {
              liveGoldRate = double.tryParse(
                      (snapshot.data!.docs[0].get('rate') ?? '0').toString()) ??
                  0.0;
            }
            if (liveSilverRate == 0 && snapshot.data!.docs.length > 1) {
              liveSilverRate = double.tryParse(
                      (snapshot.data!.docs[1].get('rate') ?? '0').toString()) ??
                  0.0;
            }
          }

          double totalGoldValue = _goldHoldings * (liveGoldRate / 10.0);
          double totalSilverValue = _silverHoldings * liveSilverRate;
          double totalPortfolioValue = totalGoldValue + totalSilverValue;

          // Invested values
          double investedGold = _goldAvgBuyRate > 0
              ? (_goldHoldings * (_goldAvgBuyRate / 10.0))
              : totalGoldValue;
          double investedSilver = _silverAvgBuyRate > 0
              ? (_silverHoldings * _silverAvgBuyRate)
              : totalSilverValue;
          double totalInvested = investedGold + investedSilver;
          double profitLoss = totalPortfolioValue - totalInvested;
          double pnlPercentage =
              totalInvested > 0 ? ((profitLoss / totalInvested) * 100) : 0.0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTotalValueCard(
                  totalValue: totalPortfolioValue,
                  profitLoss: profitLoss,
                  pnlPercent: pnlPercentage,
                  onShare: () => _sharePortfolio(
                    totalPortfolioValue,
                    totalGoldValue,
                    totalSilverValue,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'HOLDINGS BREAKDOWN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                _buildHoldingCard(
                  title: 'Gold Holdings (24K)',
                  weightText: '${_goldHoldings.toStringAsFixed(2)} g',
                  liveRateText: '₹${liveGoldRate.toStringAsFixed(0)} / 10g',
                  currentValue: totalGoldValue,
                  icon: Icons.monetization_on_rounded,
                  iconColor: const Color(0xFFFFB800),
                  bgGradient: [const Color(0xFFFFFDF0), Colors.white],
                  borderColor: const Color(0xFFFFE082),
                ),
                const SizedBox(height: 12),
                _buildHoldingCard(
                  title: 'Silver Holdings (999)',
                  weightText: '${_silverHoldings.toStringAsFixed(2)} kg',
                  liveRateText: '₹${liveSilverRate.toStringAsFixed(0)} / kg',
                  currentValue: totalSilverValue,
                  icon: Icons.circle_rounded,
                  iconColor: const Color(0xFF90A4AE),
                  bgGradient: [const Color(0xFFF8F9FA), Colors.white],
                  borderColor: const Color(0xFFCFD8DC),
                ),
                const SizedBox(height: 24),
                _buildEditHoldingsCard(),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalValueCard({
    required double totalValue,
    required double profitLoss,
    required double pnlPercent,
    required VoidCallback onShare,
  }) {
    bool isProfit = profitLoss >= 0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [app_info.primaryDarkColor, app_info.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: app_info.primaryDarkColor.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'PORTFOLIO VALUE',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: onShare,
                icon: const Icon(Icons.share_rounded, color: Colors.white70),
                tooltip: 'Share Portfolio',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹ ${totalValue.toStringAsFixed(2)}',
            style: TextStyle(
              color: app_info.goldColor,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          if (_goldAvgBuyRate > 0 || _silverAvgBuyRate > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (isProfit ? Colors.green : Colors.red).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (isProfit ? Colors.green : Colors.red).withOpacity(0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isProfit
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: isProfit ? Colors.greenAccent : Colors.redAccent,
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isProfit ? '+' : ''}₹${profitLoss.abs().toStringAsFixed(2)} (${pnlPercent.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      color: isProfit ? Colors.greenAccent : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              'Live value updated based on current market rate',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHoldingCard({
    required String title,
    required String weightText,
    required String liveRateText,
    required double currentValue,
    required IconData icon,
    required Color iconColor,
    required List<Color> bgGradient,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Holding: $weightText',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  'Live Rate: $liveRateText',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Current Value',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                '₹ ${currentValue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: app_info.primaryDarkColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditHoldingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, color: app_info.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Update Your Metals Holdings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHoldingsInput(
            label: 'Gold Quantity (in Grams)',
            hint: 'e.g. 25.50',
            controller: _goldController,
            icon: Icons.monetization_on_outlined,
          ),
          const SizedBox(height: 12),
          _buildHoldingsInput(
            label: 'Average Gold Buy Rate (₹ / 10g - Optional)',
            hint: 'e.g. 71000',
            controller: _goldBuyPriceController,
            icon: Icons.trending_up_rounded,
          ),
          const SizedBox(height: 16),
          _buildHoldingsInput(
            label: 'Silver Quantity (in Kilograms)',
            hint: 'e.g. 1.25',
            controller: _silverController,
            icon: Icons.circle_outlined,
          ),
          const SizedBox(height: 12),
          _buildHoldingsInput(
            label: 'Average Silver Buy Rate (₹ / kg - Optional)',
            hint: 'e.g. 85000',
            controller: _silverBuyPriceController,
            icon: Icons.trending_up_rounded,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveHoldings,
            style: ElevatedButton.styleFrom(
              backgroundColor: app_info.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'SAVE PORTFOLIO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsInput({
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon: Icon(icon, color: app_info.primaryColor, size: 18),
            filled: true,
            fillColor: const Color(0xFFF9FAFC),
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
}
