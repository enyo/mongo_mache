part of rodin;


/// This class describes a model.
///
/// When created, it reflects the model and extracts all fields including
/// annotations (as soon as it's possible) for the specifications.
///
/// At the moment, all specifications have to be stored in the _specifications
/// attribute.
class ModelDescription {

  List<String> _validTypes = [
                              "dart.core.String",
                              "dart.core.num",
                              "dart.core.bool",
                              "dart.core.DateTime"
                             ];

  Type modelClass;

  Db db;

  DbCollection dbCollection;

  Map<String, List<Specification>> specifications;

  /// A map from fieldName to fieldType (as string. eg: dart.core.String)
  Map<String, String> fields = { };

  ModelDescription(this.modelClass, this.db, { this.specifications }) {
    if (!db.connection.connected) {
      throw new RodinException("You can only add models with a valid database connection.");
    }
    _reflectModel();
  }

  // Reflects the model, and builds a field map.
  void _reflectModel() {

    ClassMirror reflectedClass = reflectClass(modelClass);

    var className = MirrorSystem.getName(reflectedClass.simpleName);
    var collectionName = className
        .replaceAll(new RegExp(r"Model$"), "")
        .replaceAllMapped(new RegExp(r"(.)([A-Z])"), (match) => "${match[1]}_${match[2]}")
        .toLowerCase();

    dbCollection = db.collection(collectionName + "s");

    reflectedClass.members.forEach((Symbol parameterSymbol, ParameterMirror parameter) {

      var parameterName = MirrorSystem.getName(parameterSymbol);

      if (parameterName != "specifications" &&
          !parameter.isPrivate &&
          !parameter.isStatic) {

        String parameterType = MirrorSystem.getName(parameter.type.qualifiedName);

        if (!_validTypes.any((type) => type == parameterType)) {
          throw new RodinException("Invalid type for field '${parameterName}': ${parameterType}");
        }

        fields[parameterName] = parameterType;
      }
    });
  }

}