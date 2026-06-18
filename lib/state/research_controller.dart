import 'package:flutter/foundation.dart';

import '../models/research_analysis.dart';
import '../services/openalex_service.dart';

enum ResearchLoadStatus { idle, loading, loaded, error }

class ResearchController extends ChangeNotifier {
  ResearchController({required this.openAlexService});

  final OpenAlexService openAlexService;

  ResearchAnalysis? _analysis;
  ResearchLoadStatus _status = ResearchLoadStatus.idle;
  String? _errorMessage;

  ResearchAnalysis? get analysis => _analysis;
  ResearchLoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ResearchLoadStatus.loading;

  Future<void> search(String topic) async {
    final normalizedTopic = topic.trim();
    if (normalizedTopic.isEmpty) {
      _status = ResearchLoadStatus.error;
      _errorMessage = 'Enter a research topic to search.';
      notifyListeners();
      return;
    }

    _status = ResearchLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _analysis = await openAlexService.fetchResearchData(normalizedTopic);
      _status = ResearchLoadStatus.loaded;
    } on OpenAlexException catch (error) {
      _status = ResearchLoadStatus.error;
      _errorMessage = error.message;
    } on ArgumentError catch (error) {
      _status = ResearchLoadStatus.error;
      _errorMessage = error.message?.toString() ?? error.toString();
    } catch (error) {
      _status = ResearchLoadStatus.error;
      _errorMessage = 'Unable to retrieve publication data. Please try again.';
    }

    notifyListeners();
  }
}
