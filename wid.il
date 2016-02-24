axlCmdRegister("wid" 'wid_main ?cmdType "general")

;GLOBAL VAR :
;lo_layerTree

defun(wid_main ()
	let((s_formAddr o_form)
		s_formAddr = wid_form()
		o_form = axlFormCreate((gensym) s_formAddr nil 'wid_formAct nil nil)
		
		wid_formInit()
		;axlFormGetField(o_form "refWidth")
		axlFormDisplay(o_form)
		if(isFile(s_formAddr) then
			deleteFile(s_formAddr)
		);if
	)
)

defun(wid_formAct (o_form)
	case(o_form->curField
		("allOn" wid_layerSel(t))
		("allOff" wid_layerSel(nil))
		("hilight" axlHighlightObject(wid_filterCline()))
		("dehilight" axlDehighlightObject(wid_filterCline()))
		("change" wid_changeCline(axlFormGetField(o_form "noFix")))
		(t t)
	);case
	
	case(o_form->doneState
		(3 axlDehighlightObject(wid_filterCline()))
		;(3 axlFormGetField(o_form "refWidth"))
	);case
	
	axlShapeDynamicUpdate(nil nil)
	axlDBControl('dynamicFillMode, 'wysiwyg)
)

defun(wid_formInit ()
	lo_layerTree = list()
	let((x_layer s_layerName)
		x_layer = axlGetParam("paramLayerGroup:etch")->nChildren
		lo_layerTree = cons(axlFormTreeViewAddItem(o_form "layer" "TOP" nil nil t) lo_layerTree)
		if(x_layer > 2 then
			for(i 2 x_layer - 1
				sprintf(s_layerName, "L%d", i)
				lo_layerTree = cons(axlFormTreeViewAddItem(o_form "layer" s_layerName nil nil t) lo_layerTree)
			)
		)
		lo_layerTree = cons(axlFormTreeViewAddItem(o_form "layer" "BOTTOM" nil nil t) lo_layerTree)
		axlFormSetField(o_form "filter" "0")
		axlFormSetField(o_form "refWidth" 5.0)
		axlFormSetField(o_form "tgtWidth" 5.0)
	)
)

defun(wid_layerSel (g_sel)
	foreach(i lo_layerTree
		axlFormTreeViewSetSelectState(o_form "layer" i g_sel)
	)
)

defun(wid_filterCline ()
	prog((s_layer lo_cline f_width)
		axlVisibleLayer("ETCH" nil)
		foreach(i lo_layerTree
			if(axlFormTreeViewGetSelectState(o_form "layer" i) == 1 then
				s_layer = axlFormTreeViewGetLabel(o_form "layer" i)
				axlVisibleLayer(strcat("ETCH/" s_layer) t)
			)
		);foreach
		axlVisibleUpdate(t)
		
		axlSetFindFilter(
			?enabled list("noall" "clinesegs")
			?onButtons list("noall" "clinesegs")
		)
		;printf("selecting\n")
		lo_cline = list()
		axlAddSelectAll()
		lo_cline = axlGetSelSet()
		axlClearSelSet()
		unless(lo_cline return(nil))
		
		f_width = axlFormGetField(o_form "refWidth")
		;f_width = atof(f_width)
		;printf("%f\n", f_width)
		case(axlFormGetField(o_form "filter")
		("0"
			foreach(i lo_cline
				when(i->width >= f_width lo_cline = remove(i lo_cline))
			)
		)
		("1"
			foreach(i lo_cline
				when(i->width != f_width lo_cline = remove(i lo_cline))
			)
		)
		("2"
			foreach(i lo_cline
				when(i->width <= f_width lo_cline = remove(i lo_cline))
			)
		)
		);case
		;printf("%L\n", lo_cline)
		return(lo_cline)
	)
)

defun(wid_changeCline (g_noFix)
	axlDBIgnoreFixed(g_noFix)
	axlDBControl('dynamicFillMode, nil)
	let((lo_cline)
		lo_cline = wid_filterCline()
		unless(lo_cline return(nil))
		axlChangeWidth(lo_cline axlFormGetField(o_form "tgtWidth"))
	)
	axlShapeDynamicUpdate(nil nil)
	axlDBControl('dynamicFillMode, 'wysiwyg)
)

defun(wid_form ()
	prog((s_addr file)
		s_addr = "./wid.form"
		file = outfile(s_addr)
		fprintf(file "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(file "FORM\n")
		fprintf(file "FIXED\n")
		fprintf(file "PORT 40 50\n")
		fprintf(file "HEADER \"Width Set\"\n")
		fprintf(file "\n")
		fprintf(file "POPUP <ENUM>\"<\"\"0\",\"=\"\"1\",\">\"\"2\".\n")
		fprintf(file "TILE\n")
		fprintf(file "\n")
		
		fprintf(file "FIELD layer\n")
		fprintf(file "FLOC 1 1\n")
		fprintf(file "TREEVIEW 18 9\n")
		fprintf(file "ENDFIELD\n")
		
		fprintf(file "FIELD allOn\n")
		fprintf(file "FLOC 20 1\n")
		fprintf(file "MENUBUTTON \"All On\" 8 2\n")
		fprintf(file "ENDFIELD\n")
		
		fprintf(file "FIELD allOff\n")
		fprintf(file "FLOC 30 1\n")
		fprintf(file "MENUBUTTON \"All Off\" 8 2\n")
		fprintf(file "ENDFIELD\n")
		
		fprintf(file "TEXT \"Width \"\n")
		fprintf(file "TLOC 20 5\n")
		fprintf(file "ENDTEXT\n")
		
		fprintf(file "FIELD filter\n")
		fprintf(file "FLOC 25 5\n")
		fprintf(file "ENUMSET 3\n")
		fprintf(file "POP \"ENUM\"\n")
		fprintf(file "ENDFIELD\n")
		
		fprintf(file "FIELD refWidth\n")
		fprintf(file "FLOC 31 5\n")
		fprintf(file "REALFILLIN 6 99\n")
		fprintf(file "ENDFIELD\n")
		
		fprintf(file "FIELD hilight\n")
		fprintf(file "FLOC 20 8\n")
		fprintf(file "MENUBUTTON \"Highlight\" 8 3\n")
		fprintf(file "ENDFIELD\n")
		
		fprintf(file "FIELD dehilight\n")
		fprintf(file "FLOC 30 8\n")
		fprintf(file "MENUBUTTON \"Dehilight\" 8 3\n")
		fprintf(file "ENDFIELD\n")
		
		fprintf(file "TEXT \"Change to \"\n")
		fprintf(file "TLOC 20 11\n")
		fprintf(file "ENDTEXT\n")
		
		fprintf(file "FIELD tgtWidth\n")
		fprintf(file "FLOC 29 11\n")
		fprintf(file "REALFILLIN 6 99\n")
		fprintf(file "ENDFIELD\n")
		
		fprintf(file "FIELD noFix\n")
		fprintf(file "FLOC 20 14\n")
		fprintf(file "CHECKLIST \"Ignore Fix\"\n")
		fprintf(file "ENDFIELD\n")
		
		fprintf(file "FIELD change\n")
		fprintf(file "FLOC 20 16\n")
		fprintf(file "MENUBUTTON \"Change\" 8 3\n")
		fprintf(file "ENDFIELD\n")
		
		fprintf(file "\n")
		fprintf(file "ENDTILE\n")
		fprintf(file "ENDFORM\n")
		
		close(file)
		return(s_addr)
	)
)


;END
