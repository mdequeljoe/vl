function validateVl(spec){
  var ajv = new Ajv({schemaId: "auto", jsonPointers: true});
  var validate = ajv.addMetaSchema(jsonSchemaDraft06).compile(schema);
  var v = validate(spec);
  return v ? v : validate.errors;
}  

function compileSpec(spec){
  var vgSpec = vl.compile(spec).spec;
  return vgSpec;
}
