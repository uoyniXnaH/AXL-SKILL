
axlCmdRegister("sldv", 'sldv, ?cmdType "general")

defun(sldv ()
	let((g_err ll_winBox lo_sld lo_via g_bot g_top s_file p_rpt)
		g_err = nil
		
		axlVisibleDesign(nil)
		axlVisibleLayer("BOARD GEOMETRY/SOLDERMASK_TOP" t)
		axlVisibleLayer("BOARD GEOMETRY/SOLDERMASK_BOTTOM" t)
		axlVisibleLayer("PACKAGE GEOMETRY/SOLDERMASK_TOP" t)
		axlVisibleLayer("PACKAGE GEOMETRY/SOLDERMASK_BOTTOM" t)
		axlVisibleLayer("PIN/SOLDERMASK_TOP" t)
		axlVisibleLayer("PIN/SOLDERMASK_BOTTOM" t)
		axlVisibleLayer("VIA CLASS" t)
		
		ll_winBox = axlWindowBoxGet()
		axlWindowBoxSet(list(0:0 5:5))
		
		axlSetFindFilter(?enabled '("noall" "vias") ?onButtons '("noall" "vias"))
		axlClearSelSet()
		axlAddSelectAll()
		lo_via = axlGetSelSet()
		axlClearSelSet()
		axlSetFindFilter(
			?enabled '("noall" "pins" "shapes" "lines")
			?onButtons '("noall" "pins" "shapes" "lines")
		)
		
		s_file = axlTempFile()
		p_rpt  = outfile(s_file)
		
		foreach(i lo_via
			axlAddSelectBox(sldv_iRec(i->xy i->bBox))
			lo_sld = axlGetSelSet()
			axlClearSelSet()
			
			when(length(lo_sld) > 1
				g_top = nil
				g_bot = nil
				
				foreach(j lo_sld
				;deal with pins and other obj repsectively
					if(j->objType == "pin"
					then
						if(j->isMirrored g_bot = t g_top = t)
					else
						when(rexMatchp("TOP$" j->layer) g_top = t)
						when(rexMatchp("BOTTOM$" j->layer) g_bot = t)
					);if pin
				);foreach sld obj
				when(g_top && g_bot
					fprintf(p_rpt, "via @ %L\n", i->xy)
					axlHighlightObject(i)
					g_err = t
				);when sld at top&bot
			);when sld obj>1
		);foreach via
		unless(g_err fprintf(p_rpt, "No errors found.\n"))
		
		close(p_rpt)
		axlUIWExpose(axlUIViewFileCreate(s_file "Check Report" nil))
		axlTempFileRemove(s_file)
		
		axlWindowBoxSet(ll_winBox)
	);let
)

;work out the inner square of a via(circle)
defun(sldv_iRec (f_xy l_bBox)
	prog((f_x f_y f_r f_delta)
		f_x = car(f_xy)
		f_y = cadr(f_xy)
		f_r = (caadr(l_bBox)-caar(l_bBox)) * 0.5
		f_delta = f_r / 1.41
		return(list(list(f_x-f_delta f_y+f_delta) list(f_x+f_delta f_y-f_delta)))
	)
)


;END
