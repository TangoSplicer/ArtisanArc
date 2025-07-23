import '../data/compliance_model.dart';
import '../data/compliance_repository.dart';

abstract class ComplianceService {
  Future<void> recordCertification(ComplianceEntry entry);
  Future<List<ComplianceEntry>> fetchCertifications();
  Future<void> updateCertification(ComplianceEntry entry);
  Future<void> deleteCertification(String id);
}

class ComplianceServiceImpl implements ComplianceService {
  final ComplianceRepository _repo;

  ComplianceServiceImpl(this._repo);

  @override
  Future<void> recordCertification(ComplianceEntry entry) => _repo.addEntry(entry); // Hive's put handles create

  @override
  Future<List<ComplianceEntry>> fetchCertifications() => _repo.getAllEntries();

  @override
  Future<void> updateCertification(ComplianceEntry entry) => _repo.addEntry(entry); // Hive's put handles update

  @override
  Future<void> deleteCertification(String id) => _repo.deleteEntry(id);
}