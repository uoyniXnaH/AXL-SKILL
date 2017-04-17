axlCmdRegister("fc" 'fc)

defun(fc ()
	;flag = nil
	;file = axlTempFile()
	;port = outfile(file)
	;axlDBControl('dynamicFillMode, nil)
	prog(()
		axlSetFindFilter(
			?enabled list("noall" "pins")
			?onButtons list("noall" "pins")
		)

		lo_allline = list()
		
		
		while(axlSelect()
			axlHighlightObject(axlGetSelSet())
			all = axlGetSelSet()
			foreach(i all
				axlDBAddProp(i list("DYN_THERMAL_CON_TYPE" "FULL_CONTACT"))
			)
		)
		
		case(axlUIGetUserData()->doneState
		(done
			;when(all == nil
			;	axlUIConfirm("Ineffective Operation")
				return(nil)
			
;----------------------------------------------
		
			
			

;----------------------------------------------
			;flag = t
		)
		(cancel
			;printf("cancel\n")
			return(nil)
		)
		)
		axlClearSelSet()
		
	)
	;close(port)
	;if(flag then
	;	axlUIWExpose(axlUIViewFileCreate(file "Report" nil))
	;)
	
)





;END
