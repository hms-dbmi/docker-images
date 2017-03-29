set @capitalizationBeforeFindId = (select IF(max(id) is NULL,0, max(id)) from EventConverterImplementation) + 1;

insert into EventConverterImplementation(id, eventListener, name) values(@capitalizationBeforeFindId,'edu.harvard.hms.dbmi.bd2k.irct.findtools.event.find.CapitalizationBeforeFind','Capitalization Before Find');

insert into event_parameters(id, name, value) values(@capitalizationBeforeFindId, 'allCaps', 'true');
insert into event_parameters(id, name, value) values(@capitalizationBeforeFindId, 'allLowerCase', 'true');
insert into event_parameters(id, name, value) values(@capitalizationBeforeFindId, 'wordCapitalization', 'true');