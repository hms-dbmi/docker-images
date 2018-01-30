JDBC_DL_ORA      := http://files.thehyve.net
JDBC_DRIVER_ORA  := ojdbc6-12.1.0.2.jar

LIB_DIR          := $(dir $(lastword $(MAKEFILE_LIST)))
CP_ORA           := $(LIB_DIR)$(JDBC_DRIVER_ORA):$(LIB_DIR)

JDBC_DRIVER_ORA_PATH  := $(LIB_DIR)$(JDBC_DRIVER_ORA)

# For correctness, the dependency on XDB should be split off since some uses of this rule don't need XCB, but it doesn't matter a lot.
$(JDBC_DRIVER_ORA_PATH):
	curl -f $(JDBC_DL_ORA)/$(JDBC_DRIVER_ORA) > $@


.DELETE_ON_ERROR:
