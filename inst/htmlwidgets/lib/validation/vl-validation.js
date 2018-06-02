function validateVl(spec){
  var ajv = new Ajv({schemaId: "auto", jsonPointers: true});
  var validate = ajv.addMetaSchema(jsonSchemaDraft06).compile(schema);
  var v = validate(spec);
  return v ? v : validate.errors;
}  

function logVegaWarnings(spec){
  var log = [];
  var logger = {warn: function(m){ log.push(m)}};
  var vspec = vl.compile(spec, {logger: logger}).spec;
  return log;
}