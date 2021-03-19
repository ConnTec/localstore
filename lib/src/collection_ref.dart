part of localstore;

/// A [CollectionRef] object can be used for adding documents, getting
/// [DocumentRef]s, and querying for documents.
class CollectionRef implements CollectionRefImpl {
  String _id;

  /// A string representing the path of the referenced document (relative to the
  /// root of the database).
  String get path => '${_parent?.path ?? ''}${_delegate?.id ?? ''}/$_id/';

  DocumentRef? _delegate;

  CollectionRef? _parent;

  List<List>? _conditions;

  /// The parent [CollectionRef] of this document.
  CollectionRef? get parent => _parent;

  CollectionRef._(this._id, [this._parent, this._delegate, this._conditions]);
  static final _cache = <String, CollectionRef>{};

  /// Returns an instance using the default [CollectionRef].
  factory CollectionRef(String id,
      [CollectionRef? parent, DocumentRef? delegate]) {
    final key = '${parent?.path ?? ''}${delegate?.id ?? ''}/$id/';
    final collectionRef =
        _cache.putIfAbsent(key, () => CollectionRef._(id, parent, delegate));
    collectionRef._conditions = null;
    return collectionRef;
  }

  final _utils = Utils.instance;
  final Map<String, dynamic?> _data = {};

  @override
  Stream<Map<String, dynamic>> get stream => _utils.stream(path, _conditions);

  @override
  Future<Map<String, dynamic>?> get() async {
    return _data[path] ?? await _utils.get(path, true, _conditions);
  }

  @override
  DocumentRef doc([String? id]) {
    id ??= int.parse(
            '${Random().nextInt(1000000000)}${Random().nextInt(1000000000)}')
        .toRadixString(35)
        .substring(0, 9);
    return DocumentRef(id, this);
  }

  @override
  CollectionRef where(
    field, {
    isEqualTo,
  }) {
    final conditions = <List>[];
    void addCondition(dynamic field, String operator, dynamic value) {
      List<dynamic> condition;

      condition = <dynamic>[field, operator, value];
      conditions.add(condition);
    }

    if (isEqualTo != null) addCondition(field, '==', isEqualTo);

    _conditions = conditions;

    return this;
  }
}
