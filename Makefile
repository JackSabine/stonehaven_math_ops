.ONESHELL:

ifndef PROJECT_ROOT
  $(error You must define the project root by sourcing project.sh)
endif

WORKDIR := $(PROJECT_ROOT)/work

COMPILE_LIST += -f $(PROJECT_ROOT)/rtl/file_list
COMPILE_LIST += -f $(PROJECT_ROOT)/dv/file_list

TB_TOP := multiplier_tb

co: | work
	cd $(WORKDIR)
	xvlog $(COMPILE_LIST) -L uvm --sv
	xelab -top $(TB_TOP) -snapshot $(TB_TOP)_snapshot -debug all -L uvm

so: | work
	cd $(WORKDIR)
	xsim $(TB_TOP)_snapshot -tclbatch $(PROJECT_ROOT)/xsim_cfg.tcl

sim: co so | work

waves: | work
	cd $(WORKDIR)
	xsim --gui $(TB_TOP)_snapshot.wdb

work:
	mkdir $(WORKDIR)

clean:
	rm -rf $(WORKDIR)
	rm -rf xsim.dir

