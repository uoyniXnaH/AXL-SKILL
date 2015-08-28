;slt character list temporary empty
;target: drl character counted from A-Z
;        slt character counted from OA-OZ

axlCmdRegister("nc",'auto_drill)

;l_tmp: list temp
;s_tmp: string temp
;f_tmp: float temp
;i_tmp: integer temp
;tmp:   undefined temp

defun(auto_drill ()
	
	;drill characters pre-list
	drlChar = list("A" "B" "C" "D" "F" "G" "H" "I" "K" "L" "M" "N" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" "OA" "OB" "OC" "OD" "OE" "OF" "OG" "OH")
	sltChar = list()
	
	;get units
	l_tmp = axlDBGetDesignUnits()
	unit = nth(0 l_tmp)
	;cross figure: 20mil or 0.5mm
	coef = 1.0
	if(unit == "millimeters" then
		coef = 0.025
	)
	
	;list of pin padstack dbid
	l_hole = list()		;all hole
	l_plt  = list()		;pltd circle
	l_nplt = list()		;npltd circle
	l_slot = list()		;slot
	l_nslt = list()		;npltd slot
	
	;pin
	axlVisibleDesign(nil)
	axlVisibleLayer("PIN/TOP" t)
	axlSetFindFilter(
		?enabled list("noall" "pins")
		?onButtons list("noall" "pins")
	)
	
	axlAddSelectAll()
	l_tmp = axlGetSelSet()	;l_tmp: list of pins dbid
	axlClearSelSet()
	
	foreach(i l_tmp
	;i:pin dbid
		if(i->isThrough then
			if(not(exists(x l_hole x == i->definition)) then
				l_hole = cons(i->definition l_hole)
			)
		);end if through
	)
	
	foreach(i l_hole
	;i:padstack dbid
		s_tmp = strcat(i->holeType i->plating)
		case(s_tmp
			("circle_drillPLATED"
				l_plt = cons(i l_plt)
			)
			("circle_drillNON_PLATED"
				l_nplt = cons(i l_nplt)
			)
			("oval_slotPLATED"
				l_slot = cons(i l_slot)
			)
			("oval_slotNON_PLATED"
				l_nslt = cons(i l_nslt)
			)
			(t
				printf("%s can not be classified. Its type is %s\n", i->name s_tmp)
			)
		);end case
	)
	
	;via add to pltd
	l_tmp = axlGetAllViaList()
	l_plt = append(l_tmp l_plt)
	
	;circle padstack list elements rebuilt to be '(diameter dbid) for sort
	l_tmp = list()
	foreach(i l_plt
		;printf("%.2f\n", i->drillDiameter)
		f_tmp = i->drillDiameter
		l_tmp = cons(list(f_tmp i) l_tmp)
	)
	l_plt = l_tmp
	
	l_tmp = list()
	foreach(i l_nplt
		f_tmp = i->drillDiameter
		l_tmp = cons(list(f_tmp i) l_tmp)
	)
	l_nplt = l_tmp
	
	;slot padstack list elements rebuilt to be '(WidHgt* dbid) for sort
	;*WidHgt eg:Wid=(f)20.00 Hgt=(f)25.00 then WidHgt=(i)20002500
	l_tmp = list()
	foreach(i l_slot
		f_tmp = i->drillFigureWidth * 100
		i_tmp = fix(f_tmp)
		f_tmp = (i->drillFigureHeight + 100) * 100
		tmp   = concat(i_tmp fix(f_tmp))
		s_tmp = symbolToString(tmp)
		i_tmp = atoi(s_tmp)
		l_tmp = cons(list(i_tmp i) l_tmp)
	)
	l_slot = l_tmp
	
	;nslot same to slot
	l_tmp = list()
	foreach(i l_nslt
		f_tmp = i->drillFigureWidth * 100
		i_tmp = fix(f_tmp)
		f_tmp = (i->drillFigureHeight + 100) * 100
		tmp   = concat(i_tmp fix(f_tmp))
		s_tmp = symbolToString(tmp)
		i_tmp = atoi(s_tmp)
		l_tmp = cons(list(i_tmp i) l_tmp)
	)
	l_nslt = l_tmp
	
	;sort by diameter or WidHgt
	l_plt  = sortcar(l_plt 'lessp)
	l_nplt = sortcar(l_nplt 'lessp)
	l_slot = sortcar(l_slot 'lessp)
	l_nslt = sortcar(l_nslt 'lessp)
	
	;i_tmp is drill char order, init 0
	i_tmp = 0
	if(length(l_plt) > 0 then
		f_tmp = caar(l_plt)
		;printf("%d\n", length(l_plt))
		for(i 0 (length(l_plt)-1)
			;l_tmp:(diameter dbid)
			l_tmp = nth(i l_plt)
			when(f_tmp < car(l_tmp)
				f_tmp = car(l_tmp)
				i_tmp = i_tmp+1
			)
			s_tmp = nth(i_tmp drlChar)
			axlPadstackEdit(cadr(l_tmp) 'drillChar s_tmp)
			axlPadstackEdit(cadr(l_tmp) 'drillFigureName "CROSS")
			axlPadstackEdit(cadr(l_tmp) 'drillFigureWidth 20*coef)
			axlPadstackEdit(cadr(l_tmp) 'drillFigureHeight 20*coef)
			
			;printf("%s\n", cadr(l_tmp)->name)
		)
		i_tmp = i_tmp+1
	);end pltd
	
	if(length(l_nplt) > 0 then
		f_tmp = caar(l_nplt)
		for(i 0 (length(l_nplt)-1)
			l_tmp = nth(i l_nplt)
			when(f_tmp < car(l_tmp)
				f_tmp = car(l_tmp)
				i_tmp = i_tmp+1
			)
			s_tmp = nth(i_tmp drlChar)
			axlPadstackEdit(cadr(l_tmp) 'drillChar s_tmp)
			axlPadstackEdit(cadr(l_tmp) 'drillFigureName "CROSS")
			axlPadstackEdit(cadr(l_tmp) 'drillFigureWidth 20*coef)
			axlPadstackEdit(cadr(l_tmp) 'drillFigureHeight 20*coef)
		)
		i_tmp = i_tmp+1
	);end nplt
	
	if(length(l_slot) > 0 then
		;printf("%d\n", length(l_slot))
		tmp = caar(l_slot)
		for(i 0 (length(l_slot)-1)
			l_tmp = nth(i l_slot)
			when(tmp < car(l_tmp)
				tmp = car(l_tmp)
				i_tmp = i_tmp+1
			)
			s_tmp = nth(i_tmp drlChar)
			axlPadstackEdit(cadr(l_tmp) 'drillChar s_tmp)
		)
		i_tmp = i_tmp+1
	);end slot
	
	if(length(l_nslt) > 0 then
		;printf("%d\n", length(l_slot))
		tmp = caar(l_nslt)
		for(i 0 (length(l_nslt)-1)
			l_tmp = nth(i l_nslt)
			when(tmp < car(l_tmp)
				tmp = car(l_tmp)
				i_tmp = i_tmp+1
			)
			s_tmp = nth(i_tmp drlChar)
			axlPadstackEdit(cadr(l_tmp) 'drillChar s_tmp)
		)
	);end nslt
)

;END
