
axlCmdRegister("pkg", 'package_out)

defun(package_out ()
	file = axlTempFile()
	port = outfile(file)
	
	prog((i all addr)
		axlSetFindFilter(
			?enabled   '("noall" "symbols")
			?onButtons '("noall" "symbols")
		)
		while(axlSelect()
			axlHighlightObject(axlGetSelSet())
			all = axlGetSelSet()
		)
		axlClearSelSet()
		case(axlUIGetUserData()->doneState
		(done
			when(!all
				fprintf(port, "\316\264\321\241\324\361\310\316\272\316\306\367\274\376") return(nil)
			)
			addr = axlDMDirectoryBrowse("." t)
			when(!stringp(addr) printf("Cancel\n") return(nil))
			foreach(i all
				;printf("%L", i)
				if(axlWritePackageFile(i->definition addr) then
					fprintf(port, "%s has been exported.\n", i->name)
				else
					fprintf(port, "%s export failed.\n", i->name)
				)
			)
		)
		(cancel printf("Cancel\n"))
	)
	)
	close(port)
	axlUIWExpose(axlUIViewFileCreate(file "Package Export" t))
)
