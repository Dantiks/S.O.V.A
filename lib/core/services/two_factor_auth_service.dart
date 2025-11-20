import 'dart:math';

class TwoFactorAuthService {
  String generateTOTP() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<bool> sendSMSCode(String phoneNumber, String code) async {
    // Integrate with SMS provider
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  bool verifyCode(String userCode, String actualCode) {
    return userCode == actualCode;
  }
}
