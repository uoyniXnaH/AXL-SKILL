axlCmdRegister("test",'test)

defun(test ()

	file = axlTempFile()
	port = outfile(file)
	
	 axlVisibleDesign(nil)
	axlVisibleLayer("PIN/SOLDERMASK_TOP" t)
	axlVisibleLayer("PIN/SOLDERMASK_BOTTOM" t)
	axlVisibleLayer("PACKAGE GEOMETRY/SOLDERMASK_TOP" t)
	axlVisibleLayer("PACKAGE GEOMETRY/SOLDERMASK_BOTTOM" t)
	axlVisibleLayer("VIA CLASS" t)
	
	axlSetFindFilter(
		?enabled list("noall" "pins")
		?onButtons list("noall" "pins")
	)
	
	axlAddSelectAll()
	all = axlGetSelSet()
	pad = all
	drl = all
	axlClearSelSet()
	
	foreach(i all
		if(i->isMech then pad = remove(i pad))
		unless(i->isThrough drl = remove(i drl))
	)
	pad_count = length(pad)
	
	axlSetFindFilter(
		?enabled list("noall" "vias")
		?onButtons list("noall" "vias")
	)
	
	axlAddSelectAll()
	all = axlGetSelSet()
	axlClearSelSet()
	
	drl_count = length(drl) + length(all)
	
	fprintf(port, "Pads amount is %d\nDrill amount is %d\n", pad_count drl_count)

	close(port)
	axlUIWExpose(axlUIViewFileCreate(file "Report" nil))
)
