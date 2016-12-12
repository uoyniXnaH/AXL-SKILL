;===================================
;单元模块
;rpd
;读取等长组，以grid的形式将网络名-等效长度-偏差显示到form
;等效长度=线长（含内层补偿）+via补偿+pin补偿
;#Prototype
;===================================
;版本历史：
;===================================
;V0.1：20161211
;initial release
;===================================

;axlCmdRegister("rpd",'rpd_main, ?cmdType "general")

defun(rpd_main ()
	let((o_form addr file o_dsn lo_mg r_colNet r_colLength r_colDelay ls_col1 v_col1)
		rpd_form()
		o_form = axlFormCreate((gensym) addr nil 'rpd_formAct t)
		rpd_init()
		axlFormDisplay(o_form)
		when(isFile(addr) errset(deleteFile(addr)))
	);let
)

defun(rpd_formAct (o_form)
	case(o_form->curField
	("popMgName" axlFormSetFieldEditable(o_form "btnRefresh" t) rpd_refresh())
	("btnRefresh" rpd_refresh())
	("ckVia" axlFormSetFieldEditable(o_form "fillinVia" axlFormGetField(o_form "ckVia")))
	("ckPin" axlFormSetFieldEditable(o_form "fillinPin" axlFormGetField(o_form "ckPin")))
	;(t printf("no return\n"))
	);case
)

defun(rpd_init ()
	axlFormSetFieldEditable(o_form "fillinVia" nil)
	axlFormSetFieldEditable(o_form "fillinPin" nil)
	axlFormSetField(o_form "fillinVia" 0.0)
	axlFormSetField(o_form "fillinPin" 0.0)
	;axlFormSetFieldEditable(o_form "gridNet" nil)
	axlFormSetFieldEditable(o_form "btnRefresh" nil)
	axlFormSetField(o_form "fillinRatio" 1.0)
	
	o_dsn = axlDBGetDesign()
	lo_mg = o_dsn->matchgroup
	axlFormBuildPopup(o_form, "popMgName", mapcar(lambda((x) x->name) lo_mg))
	
	r_colNet = make_formGridCol()
	r_colNet->fieldType = 'STRING
	r_colNet->colWidth = 3
	r_colNet->align = 'center
	r_colLength = make_formGridCol()
	r_colLength->fieldType = 'REAL
	r_colLength->colWidth = 2
	r_colLength->align = 'center
	r_colDelay = make_formGridCol()
	r_colDelay->fieldType = 'REAL
	r_colDelay->colWidth = 1
	r_colDelay->align = 'center
	
	ls_col1 = list("\315\370\302\347\303\373\263\306" "\265\310\320\247\263\244\266\310" "\306\253\262\356")
	v_col1 = listToVector(ls_col1)
	
	axlFormGridInsertCol(o_form "gridNet" r_colNet)
	axlFormGridInsertCol(o_form "gridNet" r_colLength)
	axlFormGridInsertCol(o_form "gridNet" r_colDelay)
	axlFormGridInsertRows(o_form "gridNet" 1 1)
	axlFormGridSetBatch(o_form "gridNet" 'rpd_gridInit, v_col1)
	
	axlFormGridUpdate(o_form "gridNet")
)

defun(rpd_gridInit (v_col1)
	let((r_cell)
		for(i 0 2
			r_cell = axlFormGridNewCell()
			r_cell->col = i+1
			r_cell->row = 1
			r_cell->value = v_col1[i]
			axlFormGridBatch(r_cell)
		)
	)
)

defun(rpd_refresh ()
	let((o_dsn x_tgt x_temp lo_mg o_mg l_name l_length l_delay f_viaDelay f_pinDelay f_temp
		f_tempNet f_innerSuf ls_col v_col)
		axlFormGridDeleteRows(o_form "gridNet" 2 99)
		
		;init list and temp
		l_length = list()
		l_delay  = list()
		x_temp   = 0
		x_tgt    = 0
		
		;set via delay and pin delay
		f_viaDelay = 0.0
		f_pinDelay = 0.0
		when(axlFormGetField(o_form "ckVia") f_viaDelay = axlFormGetField(o_form "fillinVia"))
		when(axlFormGetField(o_form "ckPin") f_pinDelay = axlFormGetField(o_form "fillinPin"))
		
		o_dsn = axlDBGetDesign()
		lo_mg = o_dsn->matchgroup
		foreach(i lo_mg
			when(i->name == axlFormGetField(o_form "popMgName")
				o_mg = i
			)
		);foreach lo_mg, find current matchgroup
		
		l_name = mapcar(lambda((x) x->name) o_mg->groupMembers)
		
		foreach(i o_mg->groupMembers
			foreach(j i->rpd
				when(rexMatchp(strcat(o_mg->name ".*::$") cadr(j)) x_tgt = x_temp)
			);foreach rpd, find target for current rpd
			x_temp = x_temp + 1
			
			if(i->objType == "net"
			then
				rpd_eqvLen(i)
				l_length = cons(f_temp l_length)
			else
				f_tempNet = 0.0
				foreach(j i->groupMembers
					rpd_eqvLen(j)
					f_tempNet = f_tempNet + f_temp
				);foreach net
				l_length = cons(f_tempNet l_length)
			);if net, count length, if not net(Xnet), count length of every net and sum
		);foreach o_mg, find all length and target net/xnet for current matchgroup
		l_length = reverse(l_length)
		
		;commit data to form
		for(i 0 length(l_name)-1
			ls_col = list(nth(i l_name) nth(i l_length) nth(i l_length)- nth(x_tgt l_length))
			v_col  = listToVector(ls_col)
			axlFormGridInsertRows(o_form "gridNet" 2 1)
			axlFormGridSetBatch(o_form "gridNet" 'rpd_gridNet v_col)
		)
		axlFormGridUpdate(o_form "gridNet")
	);let
)

defun(rpd_gridNet (v_col)
	let((r_cell)
		for(i 0 2
			r_cell = axlFormGridNewCell()
			r_cell->col = i+1
			r_cell->row = 2
			r_cell->value = v_col[i]
			axlFormGridBatch(r_cell)
		)
	)
)

;calculate equivalent length of a net
;eqv length = L(out_layer)+ratio*L(inner_layer)+via*via_delay+pin*pin_delay
defun(rpd_eqvLen (o_net)
	f_temp = axlDBGetLength(o_net)
	f_innerSuf = axlFormGetField(o_form "fillinRatio")
	foreach(i o_net->branches
		foreach(j i->children
			when(j->objType == "path"
				if(rexMatchp("[0-9]$" j->layer) f_temp = f_temp+(f_innerSuf-1)* axlDBGetLength(j))
			)
			when(j->objType == "via" f_temp = f_temp + f_viaDelay)
			when(j->objType == "pin" f_temp = f_temp + f_pinDelay)
		);foreach child of branch
	);foreach branch of net
)

defun(rpd_form ()
	addr = "./rpd_form.form"
	file = outfile(addr)
	fprintf(file "FILE_TYPE=FORM_DEFN VERSION=2\n")
	fprintf(file "FORM\n")
	fprintf(file "FIXED\n")
	fprintf(file "PORT 56 50\n")
	fprintf(file "HEADER \"\265\310\263\244\270\250\326\372\271\244\276\337\"\n")
	fprintf(file "POPUP <ENUM>\"1\"\"1\".\n")
	fprintf(file "TILE\n")
	fprintf(file "\n")
	
	fprintf(file "FIELD popMgName\n")
	fprintf(file "FLOC 1 1\n")
	fprintf(file "ENUMSET 20\n")
	fprintf(file "POP \"ENUM\"\n")
	fprintf(file "ENDFIELD\n")
	
	fprintf(file "TEXT \"\304\332\262\343\327\337\317\337\261\266\302\312\" \"innerLayerRatio\"\n")
	fprintf(file "TLOC 27 1\n")
	fprintf(file "ENDTEXT\n")
	
	fprintf(file "FIELD fillinRatio\n")
	fprintf(file "FLOC 38 1\n")
	fprintf(file "REALFILLIN 6 10\n")
	fprintf(file "ENDFIELD\n")
	
	fprintf(file "GRID gridNet\n")
	fprintf(file "FLOC 1 4\n")
	fprintf(file "FSIZE 53 21\n")
	fprintf(file "OPTIONS HLINES VLINES\n")
	
	fprintf(file "GHEAD TOP\n")
	fprintf(file "HEADSIZE 0\n")
	fprintf(file "OPTIONS 3D\n")
	fprintf(file "ENDGHEAD\n")
	
	fprintf(file "GHEAD SIDE\n")
	fprintf(file "HEADSIZE 0\n")
	fprintf(file "OPTIONS 3D\n")
	fprintf(file "ENDGHEAD\n")
	
	fprintf(file "ENDGRID\n")
	
	fprintf(file "FIELD ckVia\n")
	fprintf(file "FLOC 2 27\n")
	fprintf(file "CHECKLIST \"\271\375\277\327\262\271\263\245\"\n")
	fprintf(file "ENDFIELD\n")
	
	fprintf(file "FIELD fillinVia\n")
	fprintf(file "FLOC 12 27\n")
	fprintf(file "REALFILLIN 6 10\n")
	fprintf(file "ENDFIELD\n")
	
	fprintf(file "FIELD ckPin\n")
	fprintf(file "FLOC 22 27\n")
	fprintf(file "CHECKLIST \"Pin\262\271\263\245\"\n")
	fprintf(file "ENDFIELD\n")
	
	fprintf(file "FIELD fillinPin\n")
	fprintf(file "FLOC 31 27\n")
	fprintf(file "REALFILLIN 6 10\n")
	fprintf(file "ENDFIELD\n")
	
	fprintf(file "FIELD btnRefresh\n")
	fprintf(file "FLOC 43 26\n")
	fprintf(file "MENUBUTTON \"\313\242  \320\302\" 12 5\n")
	fprintf(file "ENDFIELD\n")
	
	fprintf(file "\n")
	fprintf(file "ENDTILE\n")
	fprintf(file "ENDFORM\n")
	
	close(file)
)
	


;END
