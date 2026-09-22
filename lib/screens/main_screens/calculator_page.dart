import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constant/app_info.dart' as app_info;

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController makingChargeController = TextEditingController();
  final TextEditingController gstController = TextEditingController(text: '3');

  String metalType = 'Gold';
  String purity = '24K';

  double totalEstimatedPrice = 0.0;

  void _calculatePrice() {
    double weight = double.tryParse(weightController.text) ?? 0.0;
    double ratePer10g = double.tryParse(rateController.text) ?? 0.0;
    double makingCharge = double.tryParse(makingChargeController.text) ?? 0.0;
    double gstPercent = double.tryParse(gstController.text) ?? 0.0;

    double baseRatePerGram = ratePer10g / 10.0;
    double metalValue = baseRatePerGram * weight;
    double totalWithMaking = metalValue + makingCharge;
    double gstAmount = (totalWithMaking * gstPercent) / 100;
    
    setState(() {
      totalEstimatedPrice = totalWithMaking + gstAmount;
    });

    // Hide keyboard
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_info.lightBgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildMetalSelector(),
            const SizedBox(height: 20),
            _buildInputFields(),
            const SizedBox(height: 24),
            _buildCalculateButton(),
            const SizedBox(height: 24),
            _buildResultCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [app_info.primaryColor, app_info.primaryLightColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: app_info.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.calculate_rounded, color: app_info.goldColor, size: 48),
          const SizedBox(height: 12),
          Text(
            'Bullion Calculator',
            style: TextStyle(
              color: app_info.whiteColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Calculate estimated price including Making Charges & GST',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: app_info.whiteColor.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetalSelector() {
    return Row(
      children: [
        Expanded(
          child: _metalButton('Gold', 'Gold'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _metalButton('Silver', 'Silver'),
        ),
      ],
    );
  }

  Widget _metalButton(String title, String value) {
    bool isSelected = metalType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          metalType = value;
          purity = value == 'Gold' ? '24K' : '999';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? app_info.primaryColor : app_info.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? app_info.primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: app_info.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? app_info.whiteColor : app_info.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: app_info.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            label: 'Live Rate (per 10g)',
            controller: rateController,
            icon: Icons.currency_rupee,
            hint: 'e.g. 70000',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Weight (Grams)',
            controller: weightController,
            icon: Icons.scale_rounded,
            hint: 'e.g. 15.5',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Making Charges (₹)',
            controller: makingChargeController,
            icon: Icons.design_services_rounded,
            hint: 'e.g. 1500',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'GST (%)',
            controller: gstController,
            icon: Icons.percent_rounded,
            hint: '3',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: app_info.textDarkColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            color: app_info.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: app_info.primaryColor, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: app_info.primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _calculatePrice,
      style: ElevatedButton.styleFrom(
        backgroundColor: app_info.orangeColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        shadowColor: app_info.orangeColor.withOpacity(0.5),
      ),
      child: Text(
        'CALCULATE NOW',
        style: TextStyle(
          color: app_info.whiteColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    if (totalEstimatedPrice <= 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            app_info.primaryDarkColor,
            app_info.primaryColor,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: app_info.primaryDarkColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Estimated Price',
            style: TextStyle(
              color: app_info.whiteColor.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₹ ',
                style: TextStyle(
                  color: app_info.goldColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                totalEstimatedPrice.toStringAsFixed(2),
                style: TextStyle(
                  color: app_info.goldColor,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: app_info.goldColor.withOpacity(0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '(Includes Weight, Making Charges & GST)',
            style: TextStyle(
              color: app_info.whiteColor.withOpacity(0.6),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
