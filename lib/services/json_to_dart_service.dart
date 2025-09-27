import 'dart:convert';

class JsonToDartService {
  static String generateDartModel({
    required String json,
    required String className,
    bool nullSafety = true,
    bool generateEquatable = false,
    bool generateCopyWith = false,
    bool useNumForNumbers = false,
    bool generateToJson = true,
    bool generateFromJson = true,
    bool useJsonAnnotation = true,
    bool generateToString = false,
  }) {
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(json);
      return _generateClass(
        jsonMap,
        className,
        nullSafety: nullSafety,
        generateEquatable: generateEquatable,
        generateCopyWith: generateCopyWith,
        useNumForNumbers: useNumForNumbers,
        generateToJson: generateToJson,
        generateFromJson: generateFromJson,
        useJsonAnnotation: useJsonAnnotation,
        generateToString: generateToString,
      );
    } catch (e) {
      throw Exception('Invalid JSON: $e');
    }
  }

  static String _generateClass(
    Map<String, dynamic> jsonMap,
    String className, {
    required bool nullSafety,
    required bool generateEquatable,
    required bool generateCopyWith,
    required bool useNumForNumbers,
    required bool generateToJson,
    required bool generateFromJson,
    required bool useJsonAnnotation,
    required bool generateToString,
  }) {
    final buffer = StringBuffer();
    final imports = <String>{};

    // Add imports
    if (generateEquatable) {
      imports.add('import \'package:equatable/equatable.dart\';');
    }
    if (useJsonAnnotation) {
      imports.add('import \'package:json_annotation/json_annotation.dart\';');
    }

    if (imports.isNotEmpty) {
      buffer.writeln(imports.join('\n'));
      buffer.writeln();
    }

    // Add part directive for json_annotation
    if (useJsonAnnotation && (generateToJson || generateFromJson)) {
      final fileName = _camelCaseToSnakeCase(className);
      buffer.writeln('part \'$fileName.g.dart\';');
      buffer.writeln();
    }

    // Add class annotation
    if (useJsonAnnotation) {
      buffer.writeln('@JsonSerializable()');
    }

    // Class declaration
    final extendsClause = generateEquatable ? ' extends Equatable' : '';
    buffer.writeln('class $className$extendsClause {');

    // Generate fields
    final fields = <String>[];
    final constructorParams = <String>[];

    for (final entry in jsonMap.entries) {
      final key = entry.key;
      final value = entry.value;
      final fieldName = _sanitizeFieldName(key);
      final fieldType = _getFieldType(value, useNumForNumbers, nullSafety);

      // Add json key annotation if different from field name
      if (useJsonAnnotation && key != fieldName) {
        buffer.writeln('  @JsonKey(name: \'$key\')');
      }

      buffer.writeln('  final $fieldType $fieldName;');
      fields.add(fieldName);

      final paramType = nullSafety && !fieldType.endsWith('?')
          ? 'required '
          : '';
      constructorParams.add('${paramType}this.$fieldName');
    }

    buffer.writeln();

    // Constructor
    buffer.writeln('  const $className({');
    for (int i = 0; i < constructorParams.length; i++) {
      final param = constructorParams[i];
      if (i == constructorParams.length - 1) {
        buffer.writeln('    $param,');
      } else {
        buffer.writeln('    $param,');
      }
    }
    buffer.writeln('  });');
    buffer.writeln();

    // Generate fromJson
    if (generateFromJson) {
      if (useJsonAnnotation) {
        buffer.writeln(
          '  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);',
        );
      } else {
        buffer.writeln(
          '  factory $className.fromJson(Map<String, dynamic> json) {',
        );
        buffer.writeln('    return $className(');
        for (final entry in jsonMap.entries) {
          final key = entry.key;
          final value = entry.value;
          final fieldName = _sanitizeFieldName(key);
          final conversion = _getFromJsonConversion(
            key,
            fieldName,
            value,
            useNumForNumbers,
          );
          buffer.writeln('      $fieldName: $conversion,');
        }
        buffer.writeln('    );');
        buffer.writeln('  }');
      }
      buffer.writeln();
    }

    // Generate toJson
    if (generateToJson) {
      if (useJsonAnnotation) {
        buffer.writeln(
          '  Map<String, dynamic> toJson() => _\$${className}ToJson(this);',
        );
      } else {
        buffer.writeln('  Map<String, dynamic> toJson() {');
        buffer.writeln('    return {');
        for (final entry in jsonMap.entries) {
          final key = entry.key;
          final fieldName = _sanitizeFieldName(key);
          buffer.writeln('      \'$key\': $fieldName,');
        }
        buffer.writeln('    };');
        buffer.writeln('  }');
      }
      buffer.writeln();
    }

    // Generate copyWith
    if (generateCopyWith) {
      buffer.writeln('  $className copyWith({');
      for (final field in fields) {
        final fieldInfo = _getFieldInfoFromJson(jsonMap, field);
        final fieldType = _getFieldType(
          fieldInfo,
          useNumForNumbers,
          nullSafety,
        );
        // Use double nullable for copyWith parameters
        final copyWithType = fieldType.endsWith('?')
            ? '${fieldType.substring(0, fieldType.length - 1)}??'
            : '$fieldType??';
        buffer.writeln('    $copyWithType $field,');
      }
      buffer.writeln('  }) {');
      buffer.writeln('    return $className(');
      for (final field in fields) {
        buffer.writeln('      $field: $field ?? this.$field,');
      }
      buffer.writeln('    );');
      buffer.writeln('  }');
      buffer.writeln();
    }

    // Generate toString
    if (generateToString) {
      buffer.writeln('  @override');
      buffer.writeln('  String toString() {');
      buffer.write('    return \'$className(');
      final toStringFields = fields
          .map((field) => '$field: \$$field')
          .join(', ');
      buffer.writeln('$toStringFields)\';');
      buffer.writeln('  }');
      buffer.writeln();
    }

    // Generate Equatable props
    if (generateEquatable) {
      buffer.writeln('  @override');
      buffer.writeln(
        '  List<Object${nullSafety ? '?' : ''}> get props => [${fields.join(', ')}];',
      );
      buffer.writeln();
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _getFieldType(
    dynamic value,
    bool useNumForNumbers,
    bool nullSafety,
  ) {
    final nullableSuffix = nullSafety ? '?' : '';

    if (value == null) {
      return 'dynamic$nullableSuffix';
    }

    if (value is String) {
      return 'String$nullableSuffix';
    }

    if (value is int) {
      return useNumForNumbers ? 'num$nullableSuffix' : 'int$nullableSuffix';
    }

    if (value is double) {
      return useNumForNumbers ? 'num$nullableSuffix' : 'double$nullableSuffix';
    }

    if (value is bool) {
      return 'bool$nullableSuffix';
    }

    if (value is List) {
      if (value.isEmpty) {
        return 'List<dynamic>$nullableSuffix';
      }
      final itemType = _getFieldType(value.first, useNumForNumbers, nullSafety);
      return 'List<$itemType>$nullableSuffix';
    }

    if (value is Map) {
      return 'Map<String, dynamic>$nullableSuffix';
    }

    return 'dynamic$nullableSuffix';
  }

  static String _getFromJsonConversion(
    String key,
    String fieldName,
    dynamic value,
    bool useNumForNumbers,
  ) {
    if (value is List && value.isNotEmpty) {
      return '(json[\'$key\'] as List?)?.cast<${_getFieldType(value.first, useNumForNumbers, false).replaceAll('?', '')}>()';
    }

    if (value is Map) {
      return 'json[\'$key\'] as Map<String, dynamic>?';
    }

    if (value is num && useNumForNumbers) {
      return 'json[\'$key\'] as num?';
    }

    return 'json[\'$key\']';
  }

  static dynamic _getFieldInfoFromJson(
    Map<String, dynamic> jsonMap,
    String fieldName,
  ) {
    // Find the original key for this field name
    for (final entry in jsonMap.entries) {
      if (_sanitizeFieldName(entry.key) == fieldName) {
        return entry.value;
      }
    }
    return null;
  }

  static String _sanitizeFieldName(String name) {
    // Convert to camelCase and remove invalid characters
    final parts = name.split(RegExp(r'[^a-zA-Z0-9]'));
    if (parts.isEmpty) return 'field';

    final first = parts.first.toLowerCase();
    final rest = parts
        .skip(1)
        .map(
          (part) => part.isEmpty
              ? ''
              : part[0].toUpperCase() + part.substring(1).toLowerCase(),
        )
        .join('');

    final result = first + rest;

    // Ensure it doesn't start with a number
    if (RegExp(r'^[0-9]').hasMatch(result)) {
      return 'field$result';
    }

    // Reserve keywords
    const reservedWords = [
      'class',
      'enum',
      'extends',
      'implements',
      'import',
      'library',
    ];
    if (reservedWords.contains(result)) {
      return '${result}Field';
    }

    return result.isEmpty ? 'field' : result;
  }

  static String _camelCaseToSnakeCase(String camelCase) {
    return camelCase
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst(RegExp(r'^_'), '');
  }

  static bool isValidJson(String json) {
    try {
      jsonDecode(json);
      return true;
    } catch (e) {
      return false;
    }
  }
}
