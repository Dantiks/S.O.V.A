import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_account_entity.freezed.dart';
part 'business_account_entity.g.dart';

enum BusinessType {
  individual, // ИП
  llc, // ООО
  jsc, // ОАО
  cooperative, // Кооператив
  ngo, // НКО
}

enum EmployeeRole {
  owner, // Владелец
  admin, // Администратор
  accountant, // Бухгалтер
  manager, // Менеджер
  employee, // Сотрудник
  viewer, // Наблюдатель
}

@freezed
class BusinessAccountEntity with _$BusinessAccountEntity {
  const factory BusinessAccountEntity({
    required String id,
    required String companyName,
    required String legalName,
    required BusinessType businessType,
    required String inn, // ИНН
    String? okpo, // ОКПО
    String? address,
    String? phone,
    String? email,
    String? website,
    required String ownerId,
    required List<BusinessEmployee> employees,
    required List<String> bankAccountIds,
    required List<String> departmentIds,
    @Default(true) bool isActive,
    @Default(false) bool hasAccountant,
    DateTime? registrationDate,
    DateTime? createdAt,
    Map<String, dynamic>? settings,
  }) = _BusinessAccountEntity;

  factory BusinessAccountEntity.fromJson(Map<String, dynamic> json) =>
      _$BusinessAccountEntityFromJson(json);
}

@freezed
class BusinessEmployee with _$BusinessEmployee {
  const factory BusinessEmployee({
    required String userId,
    required String displayName,
    required EmployeeRole role,
    String? position,
    String? department,
    String? email,
    String? phone,
    @Default(true) bool isActive,
    List<String>? permissions,
    DateTime? hiredDate,
    double? salary,
  }) = _BusinessEmployee;

  factory BusinessEmployee.fromJson(Map<String, dynamic> json) =>
      _$BusinessEmployeeFromJson(json);
}

@freezed
class DepartmentEntity with _$DepartmentEntity {
  const factory DepartmentEntity({
    required String id,
    required String businessId,
    required String name,
    String? description,
    required String managerId,
    required List<String> employeeIds,
    double? budget,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _DepartmentEntity;

  factory DepartmentEntity.fromJson(Map<String, dynamic> json) =>
      _$DepartmentEntityFromJson(json);
}
