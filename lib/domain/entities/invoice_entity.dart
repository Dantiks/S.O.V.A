import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_entity.freezed.dart';
part 'invoice_entity.g.dart';

enum InvoiceStatus {
  draft, // Черновик
  sent, // Отправлен
  viewed, // Просмотрен
  paid, // Оплачен
  overdue, // Просрочен
  cancelled, // Отменен
}

enum PaymentMethod {
  bankTransfer, // Банковский перевод
  cash, // Наличные
  card, // Карта
  other, // Другое
}

@freezed
class InvoiceEntity with _$InvoiceEntity {
  const factory InvoiceEntity({
    required String id,
    required String businessId,
    required String invoiceNumber,
    required String clientName,
    String? clientInn,
    String? clientAddress,
    String? clientEmail,
    required List<InvoiceItem> items,
    required double subtotal,
    required double taxRate,
    required double taxAmount,
    required double total,
    required String currency,
    required DateTime issueDate,
    required DateTime dueDate,
    required InvoiceStatus status,
    PaymentMethod? paymentMethod,
    DateTime? paidDate,
    String? notes,
    String? termsAndConditions,
    String? createdBy,
    DateTime? createdAt,
  }) = _InvoiceEntity;

  factory InvoiceEntity.fromJson(Map<String, dynamic> json) =>
      _$InvoiceEntityFromJson(json);
}

@freezed
class InvoiceItem with _$InvoiceItem {
  const factory InvoiceItem({
    required String description,
    required int quantity,
    required double unitPrice,
    required double total,
    String? unit, // шт, кг, м, и т.д.
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) =>
      _$InvoiceItemFromJson(json);
}

extension InvoiceX on InvoiceEntity {
  bool get isOverdue => 
      status != InvoiceStatus.paid && 
      DateTime.now().isAfter(dueDate);
  
  int get daysOverdue => 
      isOverdue ? DateTime.now().difference(dueDate).inDays : 0;
  
  double get amountDue => 
      status == InvoiceStatus.paid ? 0 : total;
}
