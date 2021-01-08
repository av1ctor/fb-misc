'' PDF Page Extractor, version 1.0
'' Copyright 2020 by Andre Victor (av1ctortv[@]gmail.com)

#include "../PDFer/Pdfer.bi"

sub showCopyright()
	print "PDF Page Extractor, version 1.0"
	print "Copyright 2020 by Andre Victor (av1ctortv[@]gmail.com)"
	print
end sub

sub showUsage()
	print "Usage:"
	print " pdfextract range input-file1 input-file2 ..."
	print "Notes:"
	print !" 1. The range can be, for example, 1-2,4,8,10-15"
	print !" 2. The input-file can be a pattern, for example: *.pdf"
	print
end sub

sub showError(msg as string)
	print "Error: "; msg
end sub

sub showProgress(completed as double)
	static as double last = 0
	
	if completed = 0 then
		last = 0
		return
	end if
	
	do while completed >= last + 0.05
		print ".";
		last += 0.05
	loop
	
	if completed = 1 then
		print "done!"
	end if
	
end sub

type Options
	size as integer
end type

function cmpfunc cdecl (a as any ptr, b as any ptr) as long
	return *cast(integer ptr, a) - *cast(integer ptr, b)
end function

sub main()
	showCopyright()
   
	if len(command(1)) = 0 then
		showUsage()
		exit sub
	end if
	
	dim opts as Options

	var c = 1
	do 
		var cmd = command(c)
		if left(cmd, 1) <> "-" then
			exit do
		end if
		
		select case mid(cmd, 2, 1)
		case else
			showError("Unknown option")
			return
		end select
		
		c += 1
	loop
	
	var range = command(c)
	c += 1
	if len(range) = 0 then
		showError("range not specified")
		return
	end if
	
	var count = 0
	do
		var fname = command(c)
		c += 1
		
		if len(fname) = 0 then
			if count = 0 then
				showError("input-file not specified" )
			end if
			exit do
		end if

		var inf = new PdfDoc(fname)
		var outf = new PdfDoc()
		
		print fname;
		showProgress(0.0)
		
		outf->importPages(inf, range)
		
		showProgress(0.1)

		if not outf->saveTo("extracted-" + fname) then
			showError("Could not create output file: 'extracted-" + fname + "'")
		end if
		
		delete outf
		delete inf
		
		count += 1
	loop
end sub

main()