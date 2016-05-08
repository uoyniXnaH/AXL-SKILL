axlCmdRegister("g", 'setGrid, ?cmdType "general")

defun(setGrid (s)
	let((o_grid)
		o_grid = axlDBGridGet("TOP")
		o_grid->name = 'all
		s = atof(s)
		o_grid->xGrids = s
		o_grid->yGrids = s
		axlDBGridSet(o_grid)
	)
)
