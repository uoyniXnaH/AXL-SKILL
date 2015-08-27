

axlCmdRegister("seg" 'short_seg)

defun(short_seg ()
	file = axlTempFile()
	port = outfile(file)
	flag = 0
	
	minLen = 2.00
	
	stmp = axlUIPrompt("\324\312\320\355\327\356\320\241\317\337\263\244" "2.00")
	if(stmp != nil then 
		minLen = atof(stmp)
		if(minLen == nil then
			axlUIConfirm("\312\344\310\353\316\336\320\247\243\254\262\311\323\303\304\254\310\317\326\265\241\243(2.0)")
			minLen = 2.00
		)
		
		axlSetFindFilter(
			?enabled list("noall" "clinesegs" "pins" "vias" "shapes")
			?onButtons list("noall" "clinesegs")
		)
		;printf("select segs...\n")
		
		axlAddSelectAll()
		all = axlGetSelSet()
		axlClearSelSet()
		
		axlSetFindFilter(
			?onButtons list("noall" "pins" "vias" "shapes")
		)
		;printf("all segs selected, prepare to select pins...\n")
		
		foreach(i all
			strt = car(i->startEnd)
			end  = cadr(i->startEnd)
			distance = axlDistance(strt end)
			if(distance < minLen then
				if(axlSingleSelectPoint(strt) then
					axlClearSelSet()
				else
					if(flag == 0 then flag = 1)
					axlHighlightObject(i)
					;printf("one seg detected...\n")
					fprintf(port, "Segment @ %L\n", strt)
				)
			)
		)
		
		if(flag == 0 then fprintf(port, "\n\316\264\267\242\317\326\315\344\325\333\241\243\n"))
		
		close(port)
		axlUIWExpose(axlUIViewFileCreate(file "\274\354\262\351\261\250\270\346" nil))
	
	else
		printf("Cancelled\n")
	)
)


;END
	
