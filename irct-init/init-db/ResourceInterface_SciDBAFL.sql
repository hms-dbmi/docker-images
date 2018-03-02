-- SET THE RESOURCE PARAMETERS
set @resourceName = 'SciDBAFL';

-- Set the resource variables
set @resourceId = (select IF(id is NULL,0,max(id)) from Resource) + 1;
insert into Resource(id, implementingInterface, name, ontologyType) values(@resourceId,
	'edu.harvard.hms.dbmi.bd2k.irct.ri.scidb.SciDBAFLResourceImplementation',
	@resourceName,
	'TREE'
);

-- INSERT THE RESOURCE PARAMERTERS
insert into resource_parameters(id, name, value) values(@resourceId, 'resourceName', @resourceName);
insert into resource_parameters(id, name, value) values(@resourceId, 'resourceURL', @sciDBHost);
insert into resource_parameters(id, name, value) values(@resourceId, 'username', @sciDBUser);
insert into resource_parameters(id, name, value) values(@resourceId, 'password', @sciDBPassword);

-- SET THE RESOURCE PREDICATES
set @predicatetype_AFL = (select max(id) from PredicateType) + 1;
insert into PredicateType(id, defaultPredicate, description, displayName, name) values(@predicatetype_AFL, 0, 'iQuery', 'AFL Query', 'AFL');

-- SET THE FIELDS
set @field_IQUERY = (select max(id) from Field) + 1;
insert into Field(id, description, name, path, relationship, required) values(@field_IQUERY, 'iQuery', 'iQuery query string', 'IQUERY', null, 1);

	-- Add the field to the PREDICATE
insert into PredicateType_Field(PredicateType_id, fields_id) values(@predicatetype_AFL, @field_IQUERY);

-- Finally add the PREDICATE to the RESOURCE
insert into Resource_PredicateType(Resource_Id, supportedPredicates_id) values(@resourceId, @predicatetype_AFL);
