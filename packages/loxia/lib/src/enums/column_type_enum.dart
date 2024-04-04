enum ColumnType {
  int("int"),
  integer("integer"),
  tinyint("tinyint"),
  smallint("smallint"),
  mediumint("mediumint"),
  bigint("bigint"),
  unsignedBigInt("unsigned big int"),
  int2("int2"),
  int8("int8"),
  character("character"),
  varchar("varchar"),
  varyingCharacter("varying character"),
  nchar("nchar"),
  nativeCharacter("native character"),
  nvarchar("nvarchar"),
  text("text"),
  clob("clob"),
  blob("blob"),
  real("real"),
  double("double"),
  doublePrecision("double precision"),
  float("float"),
  numeric("numeric"),
  decimal("decimal"),
  boolean("boolean"),
  date("date"),
  time("time"),
  datetime("datetime"),
  json("json");

  final String value;

  const ColumnType(this.value);
}
