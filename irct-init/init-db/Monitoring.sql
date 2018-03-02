set @MonitoringBeforeProcessId = (select IF(max(id) is NULL,0, max(id)) from EventConverterImplementation) + 1;
set @MonitoringBeforeQueryId = @MonitoringBeforeProcessId + 1;

insert into EventConverterImplementation(id, eventListener, name) values(@MonitoringBeforeProcessId,'edu.harvard.hms.dbmi.bd2k.irct.monitoring.event.action.MonitoringBeforeProcess','Monitoring Before Process');
insert into EventConverterImplementation(id, eventListener, name) values(@MonitoringBeforeQueryId,'edu.harvard.hms.dbmi.bd2k.irct.monitoring.event.action.MonitoringBeforeQuery','Monitoring Before Query');
