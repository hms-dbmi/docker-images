-- Set the resource parameters
-- parameter, resource name
-- IRCT_RESOURCE_NAME: deprecated
-- set @resourceName = 'i2b2-wildfly-${IRCT_RESOURCE_NAME}';

-- parameter, option to point to i2b2-wildfly instance
set @resourceURL = 'http://i2b2-wildfly:9090/i2b2/services/';
-- parameter, domain for i2b2 resource
set @domain = 'i2b2demo';
-- parameter, i2b2 user
set @userName = 'demo';
-- parameter, i2b2 user password
set @password = 'demouser';
set @ignoreCertificate = 'true';

set @resourceImplementingInterface = 'edu.harvard.hms.dbmi.bd2k.irct.ri.i2b2.I2B2XMLResourceImplementation';
set @resourceOntology = 'TREE';


-- Set the resource variables
set @resourceId = (select IFNULL(max(id), 0) from Resource) + 1;

-- Set the resource predicates
set @containsId = (select IFNULL(max(id), 0) from PredicateType) + 1;
set @constrainModifierId = @containsId + 1;
set @constrainValueId = @containsId + 2;
set @constrainDateId = @containsId + 3;

-- Set the Fields
set @encounter_ContainsId = (select IFNULL(max(id), 0) from Field) + 1;

set @modifier_FieldId = @encounter_ContainsId + 1;
set @encounter_ModifierId = @modifier_FieldId + 1;

set @operator_ConstrainValueId = @encounter_ModifierId + 1;
set @constraint_ConstrainValueId = @operator_ConstrainValueId + 1;
set @unitOfMeasure_ConstrainValueId = @constraint_ConstrainValueId + 1;
set @encounter_ConstrainValueId = @unitOfMeasure_ConstrainValueId + 1;

set @fromInclusive_ConstrainDateId = @encounter_ConstrainValueId + 1;
set @fromTime_ConstrainDateId = @fromInclusive_ConstrainDateId + 1;
set @fromDate_ConstrainDateId = @fromTime_ConstrainDateId + 1;
set @toInclusive_ConstrainDateId = @fromDate_ConstrainDateId + 1;
set @toTime_ConstrainDateId = @toInclusive_ConstrainDateId + 1;
set @toDate_ConstrainDateId = @toTime_ConstrainDateId + 1;
set @encounter_ConstrainDateId = @toDate_ConstrainDateId + 1;

-- INSERT THE RESOURCE
insert into Resource(id, implementingInterface, name, ontologyType) values(@resourceId, @resourceImplementingInterface, @resourceName, @resourceOntology);

-- INSERT THE RESOURCE PARAMERTERS
insert into resource_parameters(id, name, value) values(@resourceId, 'resourceName', @resourceName);
insert into resource_parameters(id, name, value) values(@resourceId, 'resourceURL', @resourceURL);
insert into resource_parameters(id, name, value) values(@resourceId, 'transmartURL', @transmartURL);
insert into resource_parameters(id, name, value) values(@resourceId, 'domain', @domain);
insert into resource_parameters(id, name, value) values(@resourceId, 'username', @userName);
insert into resource_parameters(id, name, value) values(@resourceId, 'password', @password);
insert into resource_parameters(id, name, value) values(@resourceId, 'ignoreCertificate', @ignoreCertificate);
insert into resource_parameters(id, name, value) values(@resourceId, 'clientId', @auth0ClientId);
insert into resource_parameters(id, name, value) values(@resourceId, 'namespace', @auth0Domain);

-- INSERT RESOURCE DATATYEPS
insert into Resource_dataTypes(Resource_id, datatypes) values(@resourceId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:DATETIME');
insert into Resource_dataTypes(Resource_id, datatypes) values(@resourceId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:DATE');
insert into Resource_dataTypes(Resource_id, datatypes) values(@resourceId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:INTEGER');
insert into Resource_dataTypes(Resource_id, datatypes) values(@resourceId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:STRING');
insert into Resource_dataTypes(Resource_id, datatypes) values(@resourceId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:FLOAT');

-- INSERT RESOURCE RELATIONSHIPS
insert into Resource_relationships(Resource_id, relationships) values(@resourceId, 'edu.harvard.hms.dbmi.bd2k.irct.ri.i2b2.I2B2OntologyRelationship:PARENT');
insert into Resource_relationships(Resource_id, relationships) values(@resourceId, 'edu.harvard.hms.dbmi.bd2k.irct.ri.i2b2.I2B2OntologyRelationship:CHILD');
insert into Resource_relationships(Resource_id, relationships) values(@resourceId, 'edu.harvard.hms.dbmi.bd2k.irct.ri.i2b2.I2B2OntologyRelationship:SIBLING');
insert into Resource_relationships(Resource_id, relationships) values(@resourceId, 'edu.harvard.hms.dbmi.bd2k.irct.ri.i2b2.I2B2OntologyRelationship:MODIFIER');
insert into Resource_relationships(Resource_id, relationships) values(@resourceId, 'edu.harvard.hms.dbmi.bd2k.irct.ri.i2b2.I2B2OntologyRelationship:TERM');

-- INSERT RESOURCE LogicalOperators
insert into Resource_LogicalOperator(id, logicalOperator) values(@resourceId, 'AND');
insert into Resource_LogicalOperator(id, logicalOperator) values(@resourceId, 'OR');
insert into Resource_LogicalOperator(id, logicalOperator) values(@resourceId, 'NOT');

-- CONTAINS PREDICATE
insert into PredicateType(id, defaultPredicate, description, displayName, name) values(@containsId, 1, 'Contains value', 'Contains', 'CONTAINS');
insert into PredicateType_dataTypes(PredicateType_id, dataTypes) values(@containsId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:STRING');
insert into PredicateType_dataTypes(PredicateType_id, dataTypes) values(@containsId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:INTEGER');
insert into PredicateType_dataTypes(PredicateType_id, dataTypes) values(@containsId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:FLOAT');

insert into Field(id, description, name, path, relationship, required) values(@encounter_ContainsId, 'By Encounter', 'By Encounter', 'ENCOUNTER', null, 0);
insert into Field_permittedValues(Field_Id, permittedValues) values(@encounter_ContainsId, 'YES');
insert into Field_permittedValues(Field_Id, permittedValues) values(@encounter_ContainsId, 'NO');

insert into PredicateType_Field(PredicateType_id, fields_id) values(@containsId, @encounter_ContainsId);

insert into Resource_PredicateType(Resource_Id, supportedPredicates_id) values(@resourceId, @containsId);

-- CONSTRAIN BY MODIFER
insert into PredicateType(id, defaultPredicate, description, displayName, name) values(@constrainModifierId, 0, 'Constrain by Modifier', 'Constrain by Modifier', 'CONSTRAIN_MODIFIER');
insert into PredicateType_dataTypes(PredicateType_id, dataTypes) values(@constrainModifierId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:STRING');
insert into PredicateType_dataTypes(PredicateType_id, dataTypes) values(@constrainModifierId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:INTEGER');
insert into PredicateType_dataTypes(PredicateType_id, dataTypes) values(@constrainModifierId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:FLOAT');

insert into Field(id, description, name, path, relationship, required) values(@modifier_FieldId, 'Constrain by a modifier of this entity', 'Modifier', 'MODIFIER_KEY', 'edu.harvard.hms.dbmi.bd2k.irct.ri.i2b2.I2B2OntologyRelationship:MODIFIER', 1);

insert into Field(id, description, name, path, relationship, required) values(@encounter_ModifierId, 'By Encounter', 'By Encounter', 'ENCOUNTER', null, 0);
insert into Field_permittedValues(Field_Id, permittedValues) values(@encounter_ModifierId, 'YES');
insert into Field_permittedValues(Field_Id, permittedValues) values(@encounter_ModifierId, 'NO');

insert into PredicateType_Field(PredicateType_id, fields_id) values(@constrainModifierId, @modifier_FieldId);
insert into PredicateType_Field(PredicateType_id, fields_id) values(@constrainModifierId, @encounter_ModifierId);


insert into Resource_PredicateType(Resource_Id, supportedPredicates_id) values(@resourceId, @constrainModifierId);

-- CONSTRAIN BY VALUE
insert into PredicateType(id, defaultPredicate, description, displayName, name) values(@constrainValueId, 0, 'Constrains by Value', 'Constrain by Value', 'CONSTRAIN_VALUE');
insert into PredicateType_dataTypes(PredicateType_id, dataTypes) values(@constrainValueId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:STRING');
insert into PredicateType_dataTypes(PredicateType_id, dataTypes) values(@constrainValueId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:INTEGER');
insert into PredicateType_dataTypes(PredicateType_id, dataTypes) values(@constrainValueId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:FLOAT');

insert into Field(id, description, name, path, relationship, required) values(@operator_ConstrainValueId, 'Operator', 'Operator', 'OPERATOR', null, 1);
insert into Field_permittedValues(Field_Id, permittedValues) values(@operator_ConstrainValueId, 'EQ');
insert into Field_permittedValues(Field_Id, permittedValues) values(@operator_ConstrainValueId, 'NE');
insert into Field_permittedValues(Field_Id, permittedValues) values(@operator_ConstrainValueId, 'GT');
insert into Field_permittedValues(Field_Id, permittedValues) values(@operator_ConstrainValueId, 'GE');
insert into Field_permittedValues(Field_Id, permittedValues) values(@operator_ConstrainValueId, 'LT');
insert into Field_permittedValues(Field_Id, permittedValues) values(@operator_ConstrainValueId, 'LE');
insert into Field_permittedValues(Field_Id, permittedValues) values(@operator_ConstrainValueId, 'BETWEEN');
insert into Field_permittedValues(Field_Id, permittedValues) values(@operator_ConstrainValueId, 'LIKE[exact]');
insert into Field_permittedValues(Field_Id, permittedValues) values(@operator_ConstrainValueId, 'LIKE[begin]');
insert into Field_permittedValues(Field_Id, permittedValues) values(@operator_ConstrainValueId, 'LIKE[end]');
insert into Field_permittedValues(Field_Id, permittedValues) values(@operator_ConstrainValueId, 'LIKE[contains]');

insert into Field(id, description, name, path, relationship, required) values(@constraint_ConstrainValueId, 'Constraint', 'Constraint', 'CONSTRAINT', null, 1);
insert into Field_dataTypes(Field_id, dataTypes) values(@constraint_ConstrainValueId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:STRING');
insert into Field_dataTypes(Field_id, dataTypes) values(@constraint_ConstrainValueId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:INTEGER');
insert into Field_dataTypes(Field_id, dataTypes) values(@constraint_ConstrainValueId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:FLOAT');

insert into Field(id, description, name, path, relationship, required) values(@unitOfMeasure_ConstrainValueId, 'Unit of Measure', 'Unit of Measure', 'UNIT_OF_MEASURE', null, 0);
insert into Field_dataTypes(Field_id, dataTypes) values(@unitOfMeasure_ConstrainValueId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:STRING');

insert into Field(id, description, name, path, relationship, required) values(@encounter_ConstrainValueId, 'By Encounter', 'By Encounter', 'ENCOUNTER', null, 0);
insert into Field_permittedValues(Field_Id, permittedValues) values(@encounter_ConstrainValueId, 'YES');
insert into Field_permittedValues(Field_Id, permittedValues) values(@encounter_ConstrainValueId, 'NO');


insert into PredicateType_Field(PredicateType_id, fields_id) values(@constrainValueId, @operator_ConstrainValueId);
insert into PredicateType_Field(PredicateType_id, fields_id) values(@constrainValueId, @constraint_ConstrainValueId);
insert into PredicateType_Field(PredicateType_id, fields_id) values(@constrainValueId, @unitOfMeasure_ConstrainValueId);
insert into PredicateType_Field(PredicateType_id, fields_id) values(@constrainValueId, @encounter_ConstrainValueId);


insert into Resource_PredicateType(Resource_Id, supportedPredicates_id) values(@resourceId, @constrainValueId);
-- CONSTRAIN BY DATE
insert into PredicateType(id, defaultPredicate, description, displayName, name) values(@constrainDateId, 0, 'Constrains by Date', 'Constrain by Date', 'CONSTRAIN_DATE');


insert into Field(id, description, name, path, relationship, required) values(@fromInclusive_ConstrainDateId, 'Inclusive From Date', 'From Inclusive', 'FROM_INCLUSIVE', null, 1);
insert into Field_permittedValues(Field_Id, permittedValues) values(@fromInclusive_ConstrainDateId, 'YES');
insert into Field_permittedValues(Field_Id, permittedValues) values(@fromInclusive_ConstrainDateId, 'NO');


insert into Field(id, description, name, path, relationship, required) values(@fromTime_ConstrainDateId, 'From Date Start or End', 'From Time', 'FROM_TIME', null, 1);
insert into Field_permittedValues(Field_Id, permittedValues) values(@fromTime_ConstrainDateId, 'START_DATE');
insert into Field_permittedValues(Field_Id, permittedValues) values(@fromTime_ConstrainDateId, 'END_DATE');


insert into Field(id, description, name, path, relationship, required) values(@fromDate_ConstrainDateId, 'From Date', 'From Date', 'FROM_DATE', null, 1);
insert into Field_dataTypes(Field_id, dataTypes) values(@fromDate_ConstrainDateId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:DATE');

insert into Field(id, description, name, path, relationship, required) values(@toInclusive_ConstrainDateId, 'Inclusive To Date', 'To Inclusive', 'TO_INCLUSIVE', null, 1);
insert into Field_permittedValues(Field_Id, permittedValues) values(@toInclusive_ConstrainDateId, 'YES');
insert into Field_permittedValues(Field_Id, permittedValues) values(@toInclusive_ConstrainDateId, 'NO');

insert into Field(id, description, name, path, relationship, required) values(@toTime_ConstrainDateId, 'To Date Start or End', 'To Time', 'TO_TIME', null, 1);
insert into Field_permittedValues(Field_Id, permittedValues) values(@toTime_ConstrainDateId, 'START_DATE');
insert into Field_permittedValues(Field_Id, permittedValues) values(@toTime_ConstrainDateId, 'END_DATE');

insert into Field(id, description, name, path, relationship, required) values(@toDate_ConstrainDateId, 'To Date', 'To Date', 'TO_DATE', null, 1);
insert into Field_dataTypes(Field_id, dataTypes) values(@toDate_ConstrainDateId, 'edu.harvard.hms.dbmi.bd2k.irct.model.resource.PrimitiveDataType:DATE');

insert into Field(id, description, name, path, relationship, required) values(@encounter_ConstrainDateId, 'By Encounter', 'By Encounter', 'ENCOUNTER', null, 0);
insert into Field_permittedValues(Field_Id, permittedValues) values(@encounter_ConstrainDateId, 'YES');
insert into Field_permittedValues(Field_Id, permittedValues) values(@encounter_ConstrainDateId, 'NO');

insert into PredicateType_Field(PredicateType_id, fields_id) values(@constrainDateId, @fromInclusive_ConstrainDateId);
insert into PredicateType_Field(PredicateType_id, fields_id) values(@constrainDateId, @fromTime_ConstrainDateId);
insert into PredicateType_Field(PredicateType_id, fields_id) values(@constrainDateId, @fromDate_ConstrainDateId);
insert into PredicateType_Field(PredicateType_id, fields_id) values(@constrainDateId, @toInclusive_ConstrainDateId);
insert into PredicateType_Field(PredicateType_id, fields_id) values(@constrainDateId, @toTime_ConstrainDateId);
insert into PredicateType_Field(PredicateType_id, fields_id) values(@constrainDateId, @toDate_ConstrainDateId);
insert into PredicateType_Field(PredicateType_id, fields_id) values(@constrainDateId, @encounter_ConstrainDateId);

insert into Resource_PredicateType(Resource_Id, supportedPredicates_id) values(@resourceId, @constrainDateId);
