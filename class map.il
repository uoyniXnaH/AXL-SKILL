defun(clsMap_main ()
	prog((o_form s_addr s_aLayer s_aCls s_aSubcls o_aLayer x_layerColor)
		s_addr = clsMap_form()
		
		s_aLayer  = axlGetActiveLayer()
		s_aCls    = car(parseString(s_aLayer "/"))
		s_aSubcls = cadr(parseString(s_aLayer "/"))
		o_aLayer  = axlLayerGet(s_aLayer)
		
		x_layerColor = o_aLayer->color
		
		o_form = axlFormCreate((gensym) s_addr nil 'clsMap_formAct t)
		axlBuildClassPopup(o_form "class")
		axlFormSetField(o_form, "class", s_aCls)
		axlSubclassFormPopup(o_form "subclass" s_aCls nil)
		axlFormSetField(o_form, "subclass", s_aSubcls)
		axlFormSetField(o_form, "subcolor", axlIsVisibleLayer(s_aLayer))
		when(axlIsVisibleLayer(s_aLayer) axlFormSetField(o_form, "subcolor", x_layerColor))
		
		axlFormDisplay(o_form)
	)
)

defun(clsMap_formAct (o_form)
	case(o_form->curField
		("class"
			axlSubclassFormPopup(o_form, "subclass", axlFormGetField(o_form, "class"), nil)
			
			s_aLayer = strcat(axlFormGetField(o_form, "class") "/" axlFormGetField(o_form, "subclass"))
			o_aLayer = axlLayerGet(s_aLayer)
			axlSetActiveLayer(s_aLayer)
			
			x_layerColor = o_aLayer->color
			if(axlIsVisibleLayer(s_aLayer)
			then
				axlFormSetField(o_form, "subcolor", x_layerColor)
				axlFormSetField(o_form, "subcolor", t)
			else
				axlFormSetField(o_form, "subcolor", 'black)
				axlFormSetField(o_form, "subcolor", nil)
			)
		)
		("subclass"
			s_aLayer = strcat(axlFormGetField(o_form, "class") "/" axlFormGetField(o_form, "subclass"))
			o_aLayer = axlLayerGet(s_aLayer)
			axlSetActiveLayer(s_aLayer)
			
			x_layerColor = o_aLayer->color
			if(axlIsVisibleLayer(s_aLayer)
			then
				axlFormSetField(o_form, "subcolor", x_layerColor)
				axlFormSetField(o_form, "subcolor", t)
			else
				axlFormSetField(o_form, "subcolor", 'black)
				axlFormSetField(o_form, "subcolor", nil)
			)
		)
		("subcolor"
			s_aLayer = strcat(axlFormGetField(o_form, "class") "/" axlFormGetField(o_form, "subclass"))
			o_aLayer = axlLayerGet(s_aLayer)
			if(axlFormGetField(o_form, "subcolor")
			then
				axlFormSetField(o_form, "subcolor", o_aLayer->color)
				axlVisibleLayer(s_aLayer t)
				printf("layer %s open\n", s_aLayer)
				axlVisibleUpdate(t)
			else
				axlFormSetField(o_form, "subcolor", 'black)
				axlVisibleLayer(s_aLayer nil)
				axlVisibleUpdate(t)
				printf("layer %s close\n", s_aLayer)
			)
		)
		(t t)
	)
)

defun(clsMap_form ()
	prog((s_addr p_file)
		s_addr = "./clsMap.form"
		p_file = outfile(s_addr)
		fprintf(p_file "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(p_file "FORM\n")
		fprintf(p_file "FIXED\n")
		fprintf(p_file "PORT 50 50\n")
		fprintf(p_file "HEADER \"ww\"\n")
		fprintf(p_file "POPUP <class>\"class\"\"class\"\n")
		fprintf(p_file "POPUP <subclass>\"subclass\"\"subclass\"\n")
		fprintf(p_file "\n")
		fprintf(p_file "TILE\n")
		fprintf(p_file "\n")
		
		fprintf(p_file "FIELD class\n")
		fprintf(p_file "FLOC 5 4\n")
		fprintf(p_file "ENUMSET 15\n")
		fprintf(p_file "OPTIONS prettyprint\n")
		fprintf(p_file "POP \"class\"\n")
		fprintf(p_file "ENDFIELD\n")
		
		fprintf(p_file "FIELD subcolor\n")
		fprintf(p_file "FLOC 2 7\n")
		fprintf(p_file "COLOR 2 1\n")
		fprintf(p_file "OPTIONS colorchooser\n")
		fprintf(p_file "ENDFIELD\n")
		
		fprintf(p_file "FIELD subclass\n")
		fprintf(p_file "FLOC 5 7\n")
		fprintf(p_file "ENUMSET 19\n")
		fprintf(p_file "OPTIONS prettyprint ownerdrawn\n")
		fprintf(p_file "POP \"subclass\"\n")
		fprintf(p_file "ENDFIELD\n\n")	
		
		fprintf(p_file "\n")
		fprintf(p_file "ENDTILE\n")
		fprintf(p_file "ENDFORM\n")
		
		close(p_file)
		return(s_addr)
	)
)
