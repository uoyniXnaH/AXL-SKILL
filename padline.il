axlCmdRegister("padline", 'padline_main)

defun(padline_main ()
	prog((g_rpt s_file lo_pin)
		;g_rpt   = nil
		;s_file  = axlTempFile()
		;outport = outfile(s_file)
		axlDBControl('dynamicFillMode, nil)
		
		axlSetFindFilter(
			?enabled list("noall" "pins")
			?onButtons list("noall" "pins")
		)
		while(axlSelect()
			axlHighlightObject(axlGetSelSet())
			lo_pin = axlGetSelSet()
			foreach(i lo_pin
				padline_lineRedrw(i)
			)
		)
		axlClearSelSet()
		
		case(axlUIGetUserData()->doneState
		(done
			; when(lo_pin == nil
				; printf("Select nothing...")
				; return(nil)
			; )
			
			; foreach(i lo_pin
				
				; unless(padline_lineRedrw(i)
					; fprintf(outport, "Exception @ pin %L\n", i->xy)
					; g_rpt = t
				; )
			; )
			printf("done\n")
			return(nil)
		)
		(cancel
			printf("cancel\n")
			return(nil)
		)
		)
		;close(outport)
		;when(g_rpt
		;	axlUIWExpose(axlUIViewFileCreate(s_file "Report" nil))
		;)
	)
)

;get the dbid of the cline connected to selected pin
defun(padline_getPinLine (o_pin)
	prog((lo_line o_line lo_temp o_temp)
		lo_line = axlDBGetConnect(o_pin)
		
		;exception 1: more than 1 connection is not allowed
		when(length(lo_line) != 1 printf("E- *Error* Wrong connects\n") return(nil))
		
		o_line = car(lo_line)
		foreach(i o_line->segments
			lo_temp = axlDBGetConnect(i)
			when(lo_temp 
				;printf("%L\n", lo_temp)
				foreach(j lo_temp
					o_temp = car(j)
					;exception 2: arc cline is not allowed
					when(eq(o_temp o_pin) when(i->objType == "arc" printf("E- *Error* Arc line\n") return(nil)) return(i))
				)
			)
		)
		printf("Line not found\n")
		return(nil)
	)
)

;get bBox of pin/padstack
;bBox of padstack definition contains sldmsk, while this program is supposed to get etch bBox
;so we should make a poly/shape directly from etch pin, and rotate it to get bBox
defun(padline_bBox2Size (o_pin)
	axlVisibleLayer("PIN/SOLDERMASK_TOP" nil)
	axlVisibleLayer("PIN/SOLDERMASK_BOTTOM" nil)
	prog((f_pinRot l_pinXy s_layer lo_poly lo_shape o_temp
		l_bBox x_sizeX x_sizeY l_size)
		f_pinRot = o_pin->rotation
		l_pinXy  = o_pin->xy
		s_layer  = car(o_pin->startEnd)
		
		lo_poly  = axlPolyFromDB(o_pin ?layer s_layer)
		;printf("%L\n", lo_poly)
		lo_shape = axlDBCreateShape(car(lo_poly) nil "BOARD GEOMETRY/OUTLINE")
		o_temp   = axlTransformObject(car(lo_shape) ?angle -f_pinRot ?origin l_pinXy)
		l_bBox = o_temp->bBox
		;axlDeleteObject(lo_poly)
		axlDeleteObject(o_temp)
		
		x_sizeX = caadr(l_bBox) - caar(l_bBox)
		x_sizeY = cadadr(l_bBox) - cadar(l_bBox)
		
		l_size  = list(abs(x_sizeX) abs(x_sizeY))
		return(l_size)
	)
)

;judge if the angle between pin and cline is 90*n
;params: pin abs rotation & cline's dbid
;returns: when cline is parallel to pin, return 0;
;         when cline is vertical, return 1;
;         others, return nil
defun(padline_pinLineAngle (f_pinRot o_line)
	prog((g_temp0 g_temp1 f_pinRotCos f_lineAngCos ll_lineEnd l_partAng)
		f_pinRotCos  = abs(cos(axlDegToRad(f_pinRot)))
		ll_lineEnd   = o_line->startEnd
		f_lineAngCos = abs(caar(ll_lineEnd) - caadr(ll_lineEnd)) / axlDistance(car(ll_lineEnd) cadr(ll_lineEnd))
		l_partAng    = list(45.0 135.0 225.0 315.0)
		
		;printf("pincos:%f lincos:%f\n", f_pinRotCos f_lineAngCos)
		
		;if pin rotation is 45*(2n-1), more estimation added
		when(exists(i l_partAng (i == f_pinRot))
			when(abs(f_lineAngCos - f_pinRotCos) > 0.0001 return(nil))
			
			;when g_temp0=t, pin rotation=45/225
			g_temp0 = evenp(round(f_pinRot / 45) / 2)
			;when g_temp1=t, cline rotation=45/225
			g_temp1 = plusp((caar(ll_lineEnd) - caadr(ll_lineEnd)) * (cadar(ll_lineEnd) - cadadr(ll_lineEnd)))
			
			;xor
			unless(((!g_temp0)&&g_temp1)||(g_temp0&&(!g_temp1)) return(0))
			
			return(1)
		)

		;parallel then abs(cosA-cosB)=0
		when(abs(f_lineAngCos - f_pinRotCos) < 0.0001 return(0))
		
		;vertical then cosA^2+cosB^2=1
		when(abs(f_lineAngCos ** 2 + f_pinRotCos ** 2 - 1) < 0.0001 return(1))
		return(nil)
	)
)

;main function, change cline's width to fit pin's size, i.e. the single cline would be replaced by 2 cline with different widths, one (transition) close to pin would be thinner
defun(padline_lineRedrw (o_pin)
	prog((o_pinLine l_pinSize f_pinRot f_lineWid f_pinRelX f_lineLen s_layer
		f_pinRelY f_delta f_modLen l_startPt l_midPt l_endPt f_midPtX f_midPtY)
	;f_pinRelX : pin's edge's length parallel to cline
	;f_pinRelY : pin's edge's length vertical to cline
	;f_delta   : obviously delta
	;f_modLen  : transition's length
	;l_startPt : transition's start pt (previous cline's start pt)
	;l_midPt   : transition's end pt
	;l_endPt   : previous clines's end pt
		o_pinLine = padline_getPinLine(o_pin)
		l_pinSize = padline_bBox2Size(o_pin)
		f_pinRot  = o_pin->rotation
		f_lineWid = o_pinLine->width
		
				
		;when getPinLine returns nil, stop program
		unless(o_pinLine return(nil))
		
		;get angle and assign x&y
		case(padline_pinLineAngle(f_pinRot o_pinLine)
			(0 f_pinRelX = car(l_pinSize) f_pinRelY = cadr(l_pinSize))
			(1 f_pinRelY = car(l_pinSize) f_pinRelX = cadr(l_pinSize))
			(t printf("E- *Error* Not a vertical angle\n") return(nil))
		)
		
		;printf("relx:%f rely:%f\n", f_pinRelX f_pinRelY)
		
		;cline's width should exceed pin, or this program is unnecessary #currently no judge for that
		;when(2 * f_lineWid <= f_pinRelX + f_pinRelY printf("unneccessary\n") return(nil))
		
		f_delta   = sqrt(abs(f_lineWid ** 2 - f_pinRelY ** 2)) / 2
		if(f_lineWid < f_pinRelY
		then
			;printf("width smaller than y\n")
			f_modLen = (f_lineWid - f_pinRelX) / 2
		else
			f_modLen = f_pinRelX / 2 + f_delta
		)
		f_lineLen = axlDistance(car(o_pinLine->startEnd) cadr(o_pinLine->startEnd))
		
		;exception 3: pin's size and cline length should meet some req (mathematically)
		when(f_pinRelX < f_lineWid / 2 - f_delta printf("E- *Error* Pin size unsupported\n") return(nil))
		when(f_lineLen < f_modLen printf("E- *Error* Too short line\n") return(nil))
		
		;get the terminal of cline that connects to pin
		if(axlDistance(car(o_pinLine->startEnd) o_pin->xy) == 0
		then
			l_startPt = car(o_pinLine->startEnd)
			l_endPt   = cadr(o_pinLine->startEnd)
		else
			l_startPt = cadr(o_pinLine->startEnd)
			l_endPt   = car(o_pinLine->startEnd)
		)
		
		;get mid pt
		f_midPtX = f_modLen / f_lineLen * (car(l_endPt) - car(l_startPt)) + car(l_startPt)
		f_midPtY = f_modLen / f_lineLen * (cadr(l_endPt) - cadr(l_startPt)) + cadr(l_startPt)
		l_midPt  = list(f_midPtX f_midPtY)
		;printf("%L\n", f_modLen)
		
		;create transition
		s_layer = o_pinLine->layer
		axlDeleteObject(o_pinLine)
		axlDBCreateLine(list(l_startPt l_midPt), 5.0, s_layer)
		axlDBCreateLine(list(l_midPt l_endPt), f_lineWid, s_layer)
		return(t)
		
	)
)


;END
