import '../data/business_repository.dart';
import '../data/sale_model.dart';

abstract class BusinessService {
  Future<void> createSale(SaleRecord record);
  Future<List<SaleRecord>> fetchSales();
  double calculateTotalRevenue(List<SaleRecord> records);
}

class BusinessServiceImpl implements BusinessService {
  final BusinessRepository _repository;

  BusinessServiceImpl(this._repository);

  @override
  Future<void> createSale(SaleRecord record) => _repository.createSale(record);

  @override
  Future<List<SaleRecord>> fetchSales() => _repository.getSales();

  @override
  double calculateTotalRevenue(List<SaleRecord> records) =>
      records.fold(0.0, (total, r) => total + r.total);
}