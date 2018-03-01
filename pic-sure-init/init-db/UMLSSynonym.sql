set @umlsSynonymBeforeFindId = (select IF(max(id) is NULL,0, max(id)) from EventConverterImplementation) + 1;

insert into EventConverterImplementation(id, eventListener, name) values(@umlsSynonymBeforeFindId,'edu.harvard.hms.dbmi.bd2k.irct.findtools.event.find.UMLSSynonymBeforeFind','UMLS Synonym Before Find');

insert into event_parameters(id, name, value) values(@umlsSynonymBeforeFindId, 'jdbcDriverName', 'oracle.jdbc.driver.OracleDriver');
insert into event_parameters(id, name, value) values(@umlsSynonymBeforeFindId, 'connectionString', 'CONNECTION STRING');
insert into event_parameters(id, name, value) values(@umlsSynonymBeforeFindId, 'username', 'USERNAME');
insert into event_parameters(id, name, value) values(@umlsSynonymBeforeFindId, 'password', 'PASSWORD');
insert into event_parameters(id, name, value) values(@umlsSynonymBeforeFindId, 'storedSynByPTProcedure', 'UMLS.QUERIES.GET_SYN_BY_PT(?, ?)');
insert into event_parameters(id, name, value) values(@umlsSynonymBeforeFindId, 'storedSynByPTSABProcedure', 'UMLS.QUERIES.GET_SYN_BY_PT_SAB(?, ?, ?)');
insert into event_parameters(id, name, value) values(@umlsSynonymBeforeFindId, 'newTermColumn', 'STR');