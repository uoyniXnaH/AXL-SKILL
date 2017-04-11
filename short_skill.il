axlCmdRegister("suf" 'shape_update_force)
defun(shape_update_force ()
	axlShapeDynamicUpdate(nil t)
	axlDBControl('dynamicFillMode, 'wysiwyg)
)

axlCmdRegister("su" 'shape_update_sh)
defun(shape_update_sh ()
	shape_update()
	shape_update()
)

defun(shape_update ()
	axlShapeDynamicUpdate(nil nil)
	axlDBControl('dynamicFillMode, 'wysiwyg)
)

axlCmdRegister("mkncpin" 'mark_ncpin)
defun(mark_ncpin ()
	axlDBControl('highlightColor 4)
	axlHighlightObject(axlDBDummyNet(nil) t)
)

axlCmdRegister("dbd", 'db_check, ?cmdType "general")
defun(db_check ()
	axlShell("dbdoctor")
	axlShell("FORM dbdoctor_allegro drc YES")
	axlShell("FORM dbdoctor_allegro shapes YES")
	axlShell("FORM dbdoctor_allegro xnets YES")
	axlShell("FORM dbdoctor_allegro execute")
	axlShell("FORM dbdoctor_allegro vlog")
)


