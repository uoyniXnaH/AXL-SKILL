

axlCmdRegister("gvia" 'gvia)

defun(gvia ()
	prog((all s_viaName p_viaXy)
		axlSetFindFilter(
			?enabled list("noall" "vias")
			?onButtons list("noall" "vias")
		)
		while(axlSelect()
			axlHighlightObject(axlGetSelSet())
			all = axlGetSelSet()
			foreach(i all
				s_viaName = i->name
				p_viaXy   = i->xy
				axlDBCreateVia(s_viaName p_viaXy "GND")
				axlDeleteObject(i)
			);foreach
		);while
		
		case(axlUIGetUserData()->doneState
		(done
				return(nil)
		);done
		(cancel
			return(nil)
		);cancel
		);case
		axlClearSelSet()
	);prog	
)


;END
