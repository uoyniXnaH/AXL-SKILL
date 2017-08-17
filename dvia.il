
axlCmdRegister("dvia" 'dvia)

defun(dvia ()
	axlDBControl('dynamicFillMode, nil)
	prog((all o_temp l_temp f_pinRot l_pinXy)
		axlSetFindFilter(
			?enabled list("noall" "vias")
			?onButtons list("noall" "vias")
		)

		lo_allline = list()
		
		while(axlSelect()
			axlHighlightObject(axlGetSelSet())
			all = axlGetSelSet()
			foreach(i all
				when(or(i->net->name == "GND" i->net->name == "" !i->net) axlDeleteObject(i))
			);foreach
		);while
		
		case(axlUIGetUserData()->doneState
		(done
			;when(all == nil
			;	axlUIConfirm("Ineffective Operation")
				return(nil)
		);done
		(cancel
			;printf("cancel\n")
			return(nil)
		);cancel
		);case
		axlClearSelSet()
	);prog
);defun

;END
