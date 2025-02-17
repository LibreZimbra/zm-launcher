# Build mailboxd launcher and manager process.  Note that paths you
# specify here must not be owned in the install by less privileged
# user who could then hijack this launcher binary.  The defaults are
# bad bad bad, as those symlinks might not be owned by root.

SRC     = src

BUILD   = build

BUILD_ROOT := $(shell pwd)

all: $(BUILD) $(BUILD)/zmmailboxdmgr $(BUILD)/zmmailboxdmgr.unrestricted

include build.mk

$(BUILD):
	mkdir $(BUILD)

JAVA_BINARY ?= /usr/bin/java
MAILBOXD_MANAGER_PIDFILE ?= /opt/zimbra/log/zmmailboxd_manager.pid
MAILBOXD_MANAGER_DEPRECATED_PIDFILE ?= /opt/zimbra/log/zmmailboxd.pid
MAILBOXD_JAVA_PIDFILE ?= /opt/zimbra/log/zmmailboxd_java.pid
MAILBOXD_CWD ?= /opt/zimbra/log
JETTY_BASE ?= /opt/zimbra/mailboxd
JETTY_HOME ?= /opt/zimbra/common/jetty_home
MAILBOXD_OUTFILE ?= /opt/zimbra/log/zmmailboxd.out
GC_OUTFILE ?= /opt/zimbra/log/gc.log
ZIMBRA_LIB ?= /opt/zimbra/lib
ZIMBRA_USER ?= zimbra
ZIMBRA_CONFIG ?= /opt/zimbra/conf/localconfig.xml

LAUNCHER_CFLAGS = \
	-DJAVA_BINARY='"$(JAVA_BINARY)"' \
	-DMAILBOXD_MANAGER_PIDFILE='"$(MAILBOXD_MANAGER_PIDFILE)"' \
	-DMAILBOXD_MANAGER_DEPRECATED_PIDFILE='"$(MAILBOXD_MANAGER_DEPRECATED_PIDFILE)"' \
	-DMAILBOXD_JAVA_PIDFILE='"$(MAILBOXD_JAVA_PIDFILE)"' \
	-DMAILBOXD_CWD='"$(MAILBOXD_CWD)"' \
	-DJETTY_BASE='"$(JETTY_BASE)"' \
	-DJETTY_HOME='"$(JETTY_HOME)"' \
	-DMAILBOXD_OUTFILE='"$(MAILBOXD_OUTFILE)"' \
	-DGC_OUTFILE='"$(GC_OUTFILE)"' \
	-DZIMBRA_LIB='"$(ZIMBRA_LIB)"' \
	-DZIMBRA_USER='"$(ZIMBRA_USER)"' \
	-DZIMBRA_CONFIG='"$(ZIMBRA_CONFIG)"'

ifeq ($(ZIMBRA_USE_TOMCAT), 1)
LAUNCHER_CFLAGS += -DZIMBRA_USE_TOMCAT=1
endif

$(BUILD)/zmmailboxdmgr: $(SRC)/launcher/zmmailboxdmgr.c
	gcc $(MACDEF) $(LAUNCHER_CFLAGS) -g -Wall -Wmissing-prototypes -o $@ $<

$(BUILD)/zmmailboxdmgr.unrestricted: $(SRC)/launcher/zmmailboxdmgr.c
	gcc $(MACDEF) $(LAUNCHER_CFLAGS) -DUNRESTRICTED_JVM_ARGS -Wall -Wmissing-prototypes -o $@ $<

#
# Clean
#
clean:
	$(RM) -r $(BUILD)

FORCE: ;

install: all
	$(call install_libexec, build/zmmailboxdmgr)
	$(call install_libexec, build/zmmailboxdmgr.unrestricted)
