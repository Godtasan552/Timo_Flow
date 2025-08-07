import 'package:get/get.dart';
import '../model/user_model.dart';
import '../utils/navigation_helper.dart';
import '../services/universal_storage_service.dart';
class AuthController extends GetxController {
  Rxn<User> currentUser = Rxn<User>();

  // ฟังก์ชันล็อกอิน
  Future<bool> login(String emailOrUsername, String password) async {
    final users = await StorageService.loadUsers();

    final user = users.firstWhereOrNull(
      (u) =>
          (u.email == emailOrUsername || u.username == emailOrUsername) &&
          u.password == password,
    );
    if (user != null) {
      currentUser.value = user;

      // แสดงผลลัพธ์และนำทาง
      NavigationHelper.showSuccessSnackBar('เข้าสู่ระบบสำเร็จ');
      NavigationHelper.toHome(clearStack: true);

      return true;
    }

    NavigationHelper.showErrorSnackBar('อีเมล / ชื่อผู้ใช้ หรือรหัสผ่านไม่ถูกต้อง');
    return false;
  }

  // ฟังก์ชันสมัครสมาชิก
  // ...existing code...
  Future<bool> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final users = await StorageService.loadUsers();
  
    if (users.any((u) => u.email == email || u.username == username)) {
      NavigationHelper.showErrorSnackBar('อีเมลหรือชื่อผู้ใช้นี้มีอยู่แล้ว');
      return false;
    }
  
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      username: username,
      password: password,
    );
  
    users.add(user);
    await StorageService.saveUsers(users);
  
    NavigationHelper.showSuccessSnackBar('สมัครสมาชิกสำเร็จ');
    await Future.delayed(const Duration(milliseconds: 1500));
    NavigationHelper.offNamed('/login');
    return true;
  }
  // ...existing code...

  // ฟังก์ชันรีเซ็ตรหัสผ่าน (จำลอง)
  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    NavigationHelper.showSuccessSnackBar(
        'ลิงก์รีเซ็ตรหัสผ่านถูกส่งไปยังอีเมลของคุณแล้ว');
    return true;
  }

  // ฟังก์ชันออกจากระบบ
  void logout() {
    currentUser.value = null;
    NavigationHelper.showSuccessSnackBar('ออกจากระบบแล้ว');
    NavigationHelper.toLogin(clearStack: true);
  }
}
