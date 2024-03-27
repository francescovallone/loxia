sealed class PrimaryKey<T> {
  const PrimaryKey();
}

class PrimaryKeyInt extends PrimaryKey<int> {
  final bool autoIncrement;

  const PrimaryKeyInt({this.autoIncrement = true});
}

class PrimaryKeyString extends PrimaryKey<String> {
  final bool isUUID;

  const PrimaryKeyString({this.isUUID = false});
}
