import 'package:chat_app/models/doc_ref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocRefNotifier extends StateNotifier<DocRef> {
  DocRefNotifier() : super(const DocRef(refId: ''));

  void updateDocRef(String refId){
    final docRefList = DocRef(refId: refId);

    state = docRefList;
  }
}

final docRefNotifierProvider = StateNotifierProvider<DocRefNotifier,DocRef>((ref) => DocRefNotifier());
