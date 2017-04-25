
axlCmdRegister("cell" 'cell ?cmdType "general")

let((timer o_world o_world2)
defun(cell ()
	o_world = makeTable("world")
	o_world2 = makeTable("world2")
	for(i 0 101
		o_world[i] = makeTable("row" 0)
		o_world2[i] = makeTable("row2" 0)
	)
	;initial condition
	o_world[40][40] = 1
	o_world[40][41] = 1
	o_world[41][40] = 1
	;o_world[42][41] = 1
	axlDBCreateCircle(list(800:800 8.0) 2.0 "BOARD GEOMETRY/SILKSCREEN_TOP")
	axlDBCreateCircle(list(800:820 8.0) 2.0 "BOARD GEOMETRY/SILKSCREEN_TOP")
	axlDBCreateCircle(list(820:800 8.0) 2.0 "BOARD GEOMETRY/SILKSCREEN_TOP")
	;axlDBCreateCircle(list(840:820 8.0) 2.0 "BOARD GEOMETRY/SILKSCREEN_TOP")
	
	timer = axlUIWTimerAdd(nil 500 nil 'timerCallback)
)

defun(timerCallback (window timer elapsedTime)
	axlClearSelSet()
	axlSetFindFilter(?enabled list("noall" "lines") ?onButtons list("noall" "lines"))
	for(i 1 100
		for(j 1 100
			o_world2[i][j] = o_world[i][j]
		)
	)
	for(i 1 100
		for(j 1 100
			if(life(i j)==2
			then
				when(o_world[i][j]==0
					axlDBCreateCircle(list(20.0*i:20.0*j 8.0) 2.0 "BOARD GEOMETRY/SILKSCREEN_TOP")
				);when
				o_world[i][j] = 1
			else
				axlAddSelectBox(list(20.0*i:20.0*j (20.0*i+8):(20.0*j+8)))
				o_world[i][j] = 0
			);if life
		);for j
	);for i
	axlDeleteObject(axlGetSelSet())
)

defun(life (x y)
	prog((x_count)
		x_count = o_world2[x-1][y-1]+o_world2[x][y-1]+o_world2[x+1][y-1]+o_world2[x-1][y]
					+o_world2[x+1][y]+o_world2[x-1][y+1]+o_world2[x][y+1]+o_world2[x+1][y+1]
		return(x_count)
	)
)


defun(stopTimer (l_save)
	axlUIWTimerRemove(timer)
)

axlTriggerSet('save 'stopTimer)

);let


;END
