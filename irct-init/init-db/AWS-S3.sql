set @S3BeforeGetResultId = (select IF(max(id) is NULL,0, max(id)) from EventConverterImplementation) + 1;
set @S3AfterSaveResultId = @S3BeforeGetResultId + 1;

insert into EventConverterImplementation(id, eventListener, name) values(@S3BeforeGetResultId,'edu.harvard.hms.dbmi.bd2k.irct.aws.event.result.S3AfterGetResult','S3 After Get Result');
insert into EventConverterImplementation(id, eventListener, name) values(@S3AfterSaveResultId,'edu.harvard.hms.dbmi.bd2k.irct.aws.event.result.S3AfterSaveResult','S3 After Save Result');

insert into event_parameters(id, name, value) values(@S3BeforeGetResultId, 'Bucket Name', @S3BucketName);
insert into event_parameters(id, name, value) values(@S3AfterSaveResultId, 'Bucket Name', @S3BucketName);

insert into event_parameters(id, name, value) values(@S3BeforeGetResultId, 'resultDataFolder', '/scratch/irct');
insert into event_parameters(id, name, value) values(@S3AfterSaveResultId, 'resultDataFolder', '/scratch/irct');

insert into event_parameters(id, name, value) values(@S3BeforeGetResultId, 's3Folder', concat('tmp/IRCT/', @resourceName, '/result/'));
insert into event_parameters(id, name, value) values(@S3AfterSaveResultId, 's3Folder', concat('tmp/IRCT/', @resourceName, '/result/'));
