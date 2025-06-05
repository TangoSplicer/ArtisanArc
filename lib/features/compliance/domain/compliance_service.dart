import '../data/compliance_model.dart';
import '../data/compliance_repository.dart';

abstract class ComplianceService {
  Future<void> recordCertification(ComplianceEntry entry);
  Future<List<ComplianceEntry>> fetchCertifications();
}

class ComplianceServiceImpl implements ComplianceService {
  final ComplianceRepository _repo;

  ComplianceServiceImpl(this._repo);

  @override
  Future<void> recordCertification(ComplianceEntry entry) => _repo.addEntry(entry);

  @override
  Future<List<ComplianceEntry>> fetchCertifications() => _repo.getEntries();
}