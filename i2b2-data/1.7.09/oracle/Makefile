INDEX = 1 2 3 4 5 6

DATASOURCES = \
	Crcdata \
	Hivedata \
	Imdata \
	Metadata \
	Pmdata \
	Workdata
SCHEMAS = \
	i2b2demodata \
	i2b2hive \
	i2b2imdata \
	i2b2metadata \
	i2b2pm \
	i2b2workdata


include ./lib/makefile.inc

RUN_SQL   = groovy -cp '$(CP_ORA)' scripts/run_sql.groovy
RUN_ANT   = ant -k -f

DATASOURCE_PATH = $(I2B2_DATA_HOME)/edu.harvard.i2b2.data/Release_1-7/NewInstall

load: $(JDBC_DRIVER_ORA_PATH)
	$(MAKE) load_tablespaces
	$(MAKE) load_users
	$(MAKE) load_datasources

load_users:
	$(foreach schema,$(SCHEMAS),$(call gen_users,$(schema)))
	$(RUN_SQL) $(foreach schema,$(SCHEMAS), -f ddl/$(schema).sql)

# TODO:
#load_passwords:
#	php -d variables_order=E ddl/passwords.sql.php $(SCHEMAS) | \
#		$(RUN_SQL) --sequential

# tablespaces.sql must be recreated everytime because its contents depend on
# an environment variable
load_tablespaces: ddl/tablespaces.sql.php
	$(call gen_tablespaces,create)
	$(RUN_SQL) -f ddl/tablespaces.sql

# generate tablespace sql statement
define gen_tablespaces
	php -d variables_order=E ddl/tablespaces.sql.php $(1) > ddl/tablespaces.sql;
endef

# generate user sql statements
define gen_users
	$(info)
	php -d variables_order=E ddl/create_users.sql.php $(1) > ddl/$(1).sql
endef

# generate db properties file
define gen_db_props
	$(info)
	php -d variables_order=E ddl/db.properties.php $(1) > $(DATASOURCE_PATH)/$(2)/db.properties
endef

# run datasource create tables
define ds_create_tables
	$(info)
	$(RUN_ANT) $(DATASOURCE_PATH)/$(1)/data_build.xml create_$(shell echo $(1) | tr A-Z a-z)_tables_release_1-7
endef

# run datasource create procedures
define ds_create_procedures
	$(info)
	$(RUN_ANT) $(DATASOURCE_PATH)/$(1)/data_build.xml create_procedures_release_1-7
endef

# run datasource create triggers
define ds_create_triggers
	$(info)
	$(RUN_ANT) $(DATASOURCE_PATH)/$(1)/data_build.xml create_triggers_release_1-7
endef

# run datasource data load
define ds_load_data
	$(info)
	$(RUN_ANT) $(DATASOURCE_PATH)/$(1)/data_build.xml db_$(shell echo $(1) | tr A-Z a-z)_load_data
endef

### run all ant target builds for datasource
define ds_create_all_objects
	$(info)
	$(call ds_create_tables,$(1))
	$(call ds_create_procedures,$(1))
	$(call ds_create_triggers,$(1))
	$(call ds_load_data,$(1))
endef

# load i2b2 datasources
load_datasources:
	$(foreach ndx,$(INDEX), $(call gen_db_props,$(word $(ndx),$(SCHEMAS)),$(word $(ndx),$(DATASOURCES))))
	$(foreach ds,$(DATASOURCES),$(call ds_create_tables,$(ds)))
	$(foreach ds,Crcdata,$(call ds_create_procedures,$(ds)))
	$(foreach ds,Pmdata,$(call ds_create_triggers,$(ds)))
	$(foreach ds,Hivedata Imdata Metadata Pmdata Workdata,$(call ds_load_data,$(ds)))
	$(RUN_ANT) $(DATASOURCE_PATH)/Crcdata/data_build.xml db_demodata_load_data

drop: $(JDBC_DRIVER_ORA_PATH)
	$(MAKE) drop_users
	$(MAKE) drop_tablespaces

drop_tablespaces:
	$(call gen_tablespaces,drop)
	$(RUN_SQL) -f ddl/tablespaces.sql

drop_users:
	php -d variables_order=E ddl/drop_users.sql.php $(SCHEMAS) | \
		$(RUN_SQL) --sequential


clean_all:
	find ddl -name '*.sql' -delete -o
