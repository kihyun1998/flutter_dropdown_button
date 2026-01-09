import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dropdown_button/flutter_dropdown_button.dart';

// Bug Test Page - Tests if dropdown overlay is removed during navigation
class DropdownBugTestPage extends StatefulWidget {
  const DropdownBugTestPage({super.key});

  @override
  State<DropdownBugTestPage> createState() => _DropdownBugTestPageState();
}

class _DropdownBugTestPageState extends State<DropdownBugTestPage> {
  int? _countdown;
  Timer? _timer;
  String? _selectedValue;

  final List<String> _items = [
    'Option 1',
    'Option 2',
    'Option 3',
    'Option 4',
    'Option 5',
  ];

  void _startCountdown() {
    setState(() => _countdown = 3);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 1) {
        timer.cancel();
        // Use pushNamedAndRemoveUntil as requested to test overlay removal
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/result-page',
          (route) => false, // Remove all previous routes
        );
      } else {
        setState(() => _countdown = _countdown! - 1);
      }
    });
  }

  void _startCountdownWithCloseAll() {
    setState(() => _countdown = 3);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 1) {
        timer.cancel();
        // Use closeAll() before navigation to manually close dropdown
        DropdownMixin.closeAll();
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/result-page',
          (route) => false, // Remove all previous routes
        );
      } else {
        setState(() => _countdown = _countdown! - 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Dropdown Overlay Bug Test'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Instructions Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bug_report,
                              color: Colors.orange.shade700,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Bug Reproduction Test',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Steps to test the bug fix:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStep(
                          '1',
                          'Open the dropdown below (click to expand)',
                        ),
                        _buildStep('2', 'Keep the dropdown OPEN'),
                        _buildStep(
                          '3',
                          'Click either button to test different fixes',
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 40.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• Auto Fix: Uses dispose() cleanup (automatic)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '• Manual Fix: Uses closeAll() API (manual)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStep(
                          '4',
                          'Wait for countdown to finish (3... 2... 1...)',
                        ),
                        _buildStep(
                          '5',
                          'Verify dropdown overlay disappears after navigation',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Dropdown for testing
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: TextOnlyDropdownButton(
                    items: _items,
                    value: _selectedValue,
                    hint: 'Select an option',
                    theme: const DropdownStyleTheme(
                      dropdown: DropdownTheme(
                        borderRadius: 12.0,
                        elevation: 8.0,
                        itemPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    onChanged: (value) =>
                        setState(() => _selectedValue = value),
                  ),
                ),
                const SizedBox(height: 32),

                // Countdown Display
                if (_countdown != null)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade300, width: 4),
                    ),
                    child: Center(
                      child: Text(
                        '$_countdown',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                if (_countdown != null) const SizedBox(height: 32),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _countdown == null ? _startCountdown : null,
                      icon: const Icon(Icons.play_arrow, size: 24),
                      label: const Text(
                        'Auto Fix\n(dispose)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _countdown == null
                          ? _startCountdownWithCloseAll
                          : null,
                      icon: const Icon(Icons.cleaning_services, size: 24),
                      label: const Text(
                        'Manual Fix\n(closeAll)',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(text, style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
