import 'dart:convert';

import 'package:drift/drift.dart';

/// Stores an ordered `List<String>` as a JSON array in one text column.
///
/// Used for values that are only ever read and written as a whole (such as a
/// summary's takeaways), which avoids a child table and an extra join.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) => List<String>.unmodifiable(
    (jsonDecode(fromDb) as List<dynamic>).cast<String>(),
  );

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
