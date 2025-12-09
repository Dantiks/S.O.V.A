import 'package:flutter/material.dart';
import 'package:finer/core/services/security_service.dart';
import 'package:finer/core/theme/glass_theme.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _securityService = SecurityService();
  String _currentPin = '';
  String _newPin = '';
  String _confirmPin = '';
  int _step = 0; // 0 = current, 1 = new, 2 = confirm
  String _error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF0f0f1e)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Изменить PIN-код',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: GlassTheme.accentGradient,
                            shape: BoxShape.circle,
                            boxShadow: GlassTheme.glowShadow,
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Title
                        Text(
                          _getTitle(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getSubtitle(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // PIN Display
                        _buildPinDisplay(),
                        
                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            _error,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        
                        const SizedBox(height: 40),

                        // Numpad
                        _buildNumpad(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_step) {
      case 0:
        return 'Текущий PIN-код';
      case 1:
        return 'Новый PIN-код';
      case 2:
        return 'Подтвердите PIN';
      default:
        return '';
    }
  }

  String _getSubtitle() {
    switch (_step) {
      case 0:
        return 'Введите ваш текущий PIN-код';
      case 1:
        return 'Введите новый 4-значный PIN-код';
      case 2:
        return 'Введите новый PIN-код еще раз';
      default:
        return '';
    }
  }

  Widget _buildPinDisplay() {
    String currentPinInput;
    switch (_step) {
      case 0:
        currentPinInput = _currentPin;
        break;
      case 1:
        currentPinInput = _newPin;
        break;
      case 2:
        currentPinInput = _confirmPin;
        break;
      default:
        currentPinInput = '';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < currentPinInput.length
                ? const Color(0xFF7A3DF2)
                : Colors.white.withOpacity(0.2),
            boxShadow: index < currentPinInput.length
                ? [
                    BoxShadow(
                      color: const Color(0xFF7A3DF2).withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        children: [
          _buildNumpadRow(['1', '2', '3']),
          const SizedBox(height: 16),
          _buildNumpadRow(['4', '5', '6']),
          const SizedBox(height: 16),
          _buildNumpadRow(['7', '8', '9']),
          const SizedBox(height: 16),
          _buildNumpadRow(['', '0', 'del']),
        ],
      ),
    );
  }

  Widget _buildNumpadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((num) {
        if (num.isEmpty) {
          return const SizedBox(width: 70, height: 70);
        }
        
        return WaterRippleButton(
          onPressed: () => _onNumberPress(num),
          padding: const EdgeInsets.all(20),
          child: num == 'del'
              ? const Icon(Icons.backspace_outlined, color: Colors.white, size: 24)
              : Text(
                  num,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        );
      }).toList(),
    );
  }

  void _onNumberPress(String num) async {
    setState(() => _error = '');

    if (num == 'del') {
      setState(() {
        switch (_step) {
          case 0:
            if (_currentPin.isNotEmpty) _currentPin = _currentPin.substring(0, _currentPin.length - 1);
            break;
          case 1:
            if (_newPin.isNotEmpty) _newPin = _newPin.substring(0, _newPin.length - 1);
            break;
          case 2:
            if (_confirmPin.isNotEmpty) _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
            break;
        }
      });
      return;
    }

    switch (_step) {
      case 0:
        if (_currentPin.length < 4) {
          setState(() => _currentPin += num);
          if (_currentPin.length == 4) {
            await _verifyCurrentPin();
          }
        }
        break;
      case 1:
        if (_newPin.length < 4) {
          setState(() => _newPin += num);
          if (_newPin.length == 4) {
            setState(() => _step = 2);
          }
        }
        break;
      case 2:
        if (_confirmPin.length < 4) {
          setState(() => _confirmPin += num);
          if (_confirmPin.length == 4) {
            await _confirmNewPin();
          }
        }
        break;
    }
  }

  Future<void> _verifyCurrentPin() async {
    final isValid = await _securityService.verifyPinCode(_currentPin);
    if (isValid) {
      setState(() {
        _step = 1;
        _error = '';
      });
    } else {
      setState(() {
        _currentPin = '';
        _error = 'Неверный PIN-код';
      });
    }
  }

  Future<void> _confirmNewPin() async {
    if (_newPin == _confirmPin) {
      await _securityService.savePinCode(_newPin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN-код успешно изменен'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _confirmPin = '';
        _error = 'PIN-коды не совпадают';
      });
    }
  }
}
