import 'package:freezed_annotation/freezed_annotation.dart';

part 'business_transaction_entity.freezed.dart';
part 'business_transaction_entity.g.json';

enum TransactionType {
  income, // Доход
  expense, // Расход
  transfer, // Перевод
}

enum BusinessCategory {
  // Доходы
  sales, // Продажи
  services, // Услуги
  investment, // Инвестиции
  loan, // Займ
  
  // Расходы
  salary, // Зарплата
  rent, // Аренда
  utilities, // Коммунальные
  supplies, // Материалы
  marketing, // Маркетинг
  equipment, // Оборудование
  taxes, // Налоги
  insurance, // Страхование
  travel, // Командировки
  office, // Офис
  other, // Прочее
}

@freezed
class BusinessTransactionEntity with _$BusinessTransactionEntity {
  const factory BusinessTransactionEntity({
    required String id,
    required String businessId,
    required TransactionType type,
    required double amount,
    required String currency,
    required BusinessCategory category,
    required String description,
    required DateTime date,
    required String accountId,
    String? departmentId,
    String? employeeId,
    String? contractorName, // Контрагент
    String? contractorInn,
    String? invoiceNumber, // Номер счета
    String? documentUrl, // Ссылка на документ
    @Default(false) bool isReconciled, // Сверено
    @Default(false) bool isTaxDeductible, // Налоговый вычет
    String? notes,
    List<String>? tags,
    String? createdBy,
    DateTime? createdAt,
    String? approvedBy,
    DateTime? approvedAt,
  }) = _BusinessTransactionEntity;

  factory BusinessTransactionEntity.fromJson(Map<String, dynamic> json) =>
      _$BusinessTransactionEntityFromJson(json);
}

extension BusinessTransactionX on BusinessTransactionEntity {
  bool get needsApproval => amount > 50000 && approvedBy == null;
  
  bool get isOverdue => !isReconciled && 
      DateTime.now().difference(date).inDays > 30;
}
