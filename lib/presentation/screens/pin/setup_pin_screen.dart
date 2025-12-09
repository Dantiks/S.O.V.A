import 'package:flutter/material.dart';
import 'package:finer/core/services/security_service.dart';

class SetupPinScreen extends StatefulWidget {
  final VoidCallback onPinSet;

  const SetupPinScreen({
    super.key,
    required this.onPinSet,
  });

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final SecurityService _securityService = SecurityService();
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isLoading = false;
  String _errorMessage = '';

  void _onNumberPressed(String number) {
    setState(() {
      _errorMessage = '';
      if (_pin.length < 4) {
        _pin += number;
        if (_pin.length == 4) {
          // Сразу сохраняем без подтверждения
          _savePin();
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      _errorMessage = '';
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _savePin() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      print('Сохранение PIN: $_pin');
      await _securityService.savePinCode(_pin);
      print('PIN успешно сохранен');
      
      if (mounted) {
        // Показываем успешное сообщение
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN-код успешно установлен!'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 500),
          ),
        );
        
        // Небольшая задержка перед переходом
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (mounted) {
          widget.onPinSet();
        }
      }
    } catch (e, stackTrace) {
      print('Ошибка сохранения PIN: $e');
      print('StackTrace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Ошибка: ${e.toString()}';
          _pin = '';
        });
      }
    }
  }

  void _onBackPressed() {
    setState(() {
      _pin = '';
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Spacer(),
                  // Иконка и заголовок
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF7A3DF2),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 40,
                      color: Color(0xFF7A3DF2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Создайте PIN-код',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Придумайте 4-значный PIN-код',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Индикаторы PIN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getPinDotColor(index),
                          border: Border.all(
                            color: _getPinDotColor(index) == Colors.transparent
                                ? Colors.white30
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Клавиатура
                  _buildKeypad(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF7A3DF2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getPinDotColor(int index) {
    return index < _pin.length ? const Color(0xFF7A3DF2) : Colors.transparent;
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        _buildKeypadRow(['1', '2', '3']),
        const SizedBox(height: 16),
        _buildKeypadRow(['4', '5', '6']),
        const SizedBox(height: 16),
        _buildKeypadRow(['7', '8', '9']),
        const SizedBox(height: 16),
        _buildKeypadRow(['', '0', 'delete']),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        if (number.isEmpty) {
          return const SizedBox(width: 80, height: 80);
        }
        
        if (number == 'delete') {
          return _buildKeypadButton(
            icon: Icons.backspace_outlined,
            onPressed: _onDeletePressed,
          );
        }
        
        return _buildKeypadButton(
          text: number,
          onPressed: () => _onNumberPressed(number),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton({
    String? text,
    IconData? icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                )
              : Text(
                  text!,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
