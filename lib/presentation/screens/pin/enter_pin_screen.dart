import 'package:flutter/material.dart';
import 'package:finer/core/services/security_service.dart';

class EnterPinScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  final bool canUseBiometric;

  const EnterPinScreen({
    super.key,
    required this.onSuccess,
    this.canUseBiometric = false,
  });

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> with SingleTickerProviderStateMixin {
  final SecurityService _securityService = SecurityService();
  String _pin = '';
  String _errorMessage = '';
  int _attemptCount = 0;
  bool _isLocked = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );
    
    if (widget.canUseBiometric) {
      _tryBiometric();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    final isAvailable = await _securityService.isBiometricAvailable();
    if (isAvailable) {
      final authenticated = await _securityService.authenticateWithBiometrics(
        reason: 'Войдите для доступа к приложению',
      );
      if (authenticated && mounted) {
        widget.onSuccess();
      }
    }
  }

  void _onNumberPressed(String number) {
    if (_isLocked) return;
    
    setState(() {
      _errorMessage = '';
      if (_pin.length < 4) {
        _pin += number;
        if (_pin.length == 4) {
          _verifyPin();
        }
      }
    });
  }

  void _onDeletePressed() {
    if (_isLocked) return;
    
    setState(() {
      _errorMessage = '';
      if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _verifyPin() async {
    final isCorrect = await _securityService.verifyPinCode(_pin);
    
    if (isCorrect) {
      // Успешный вход
      if (mounted) {
        widget.onSuccess();
      }
    } else {
      // Неверный PIN
      _attemptCount++;
      
      // Тряска при ошибке
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });
      
      setState(() {
        _pin = '';
        
        if (_attemptCount >= 5) {
          _isLocked = true;
          _errorMessage = 'Слишком много попыток. Подождите 30 секунд';
          
          // Блокировка на 30 секунд
          Future.delayed(const Duration(seconds: 30), () {
            if (mounted) {
              setState(() {
                _isLocked = false;
                _attemptCount = 0;
                _errorMessage = '';
              });
            }
          });
        } else {
          _errorMessage = 'Неверный PIN-код. Осталось попыток: ${5 - _attemptCount}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              // Иконка и заголовок
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: Column(
                  children: [
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
                        Icons.lock,
                        size: 40,
                        color: Color(0xFF7A3DF2),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Введите PIN-код',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Для доступа к приложению',
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
                            color: index < _pin.length
                                ? const Color(0xFF7A3DF2)
                                : Colors.transparent,
                            border: Border.all(
                              color: index < _pin.length
                                  ? Colors.transparent
                                  : Colors.white30,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
              const Spacer(),
              // Клавиатура
              _buildKeypad(),
              const SizedBox(height: 24),
              // Кнопка биометрии (если доступна)
              if (widget.canUseBiometric)
                TextButton.icon(
                  onPressed: _isLocked ? null : _tryBiometric,
                  icon: const Icon(
                    Icons.fingerprint,
                    color: Color(0xFF7A3DF2),
                    size: 32,
                  ),
                  label: const Text(
                    'Использовать биометрию',
                    style: TextStyle(
                      color: Color(0xFF7A3DF2),
                      fontSize: 16,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
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
      onTap: _isLocked ? null : onPressed,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isLocked 
              ? Colors.white.withOpacity(0.02)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: Colors.white.withOpacity(_isLocked ? 0.05 : 0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  color: _isLocked ? Colors.white30 : Colors.white,
                  size: 28,
                )
              : Text(
                  text!,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: _isLocked ? Colors.white30 : Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
