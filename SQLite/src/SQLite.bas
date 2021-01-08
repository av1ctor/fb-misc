'' SQLite Helper Library for FreeBASIC
'' Copyright 2017 by Andre Victor (av1ctortv[@]gmail.com)

#include once "../SQLite.bi" 
#include once "../List/List.bi" 
#include once "../Dict/Dict.bi" 

''''''''
function SQLite.open(fileName as const zstring ptr) as boolean
	
	if sqlite3_open( fileName, @instance ) then 
  		errMsg = *sqlite3_errmsg( instance )
		sqlite3_close( instance ) 
		return false
	end if 
	
	errMsg = ""
	return true
	
end function

''''''''
function SQLite.open() as boolean

	function = open(":memory:")

end function

''''''''
sub SQLite.close()
	if instance <> null then
		sqlite3_close( instance ) 
		instance = null
		errMsg = ""
	end if
end sub

''''''''
function SQLite.getErrorMsg() as const zstring ptr
	function = strptr(errMsg)
end function

''''''''
private function callback cdecl _
	( _
		byval dset as any ptr, _
		byval argc as long, _
		byval argv as zstring ptr ptr, _
		byval colName as zstring ptr ptr _
	) as long
	
	var ds = cast(SQLiteDataSet ptr, dset)
	
	var row = ds->newRow(argc)
  
	for i as integer = 0 to argc - 1
		dim as zstring ptr text = null
		if( argv[i] <> 0 ) then
			if *argv[i] <> 0 then 
				text = argv[i]
			end if
		end if
				
		row->newColumn(colName[i], text)
	next 
	
	function = 0
   
end function 
	
''''''''	
function SQLite.exec(query as const zstring ptr) as SQLiteDataSet ptr

	var ds = new SQLiteDataSet
	
	dim as zstring ptr errMsg_ = null
	if sqlite3_exec( instance, query, @callback, ds, @errMsg_ ) <> SQLITE_OK then 
		delete ds
		errMsg = *errMsg_
		sqlite3_free(errMsg_)
		return null
	else
		errMsg = ""
	end if 
	
	return ds

end function

''''''''	
function SQLite.exec(stmt as SQLiteStmt ptr) as SQLiteDataSet ptr

	var ds = new SQLiteDataSet
	
	stmt->reset()
	
	do
		if stmt->step_() <> SQLITE_ROW then
			exit do
		end if
		
		var nCols = stmt->colCount()
		var row = ds->newRow(nCols)
		
		for i as integer = 0 to nCols - 1
			row->newColumn( stmt->colName( i ), stmt->colValue( i ) )
		next
	loop
	
	function = ds
	
end function

''''''''	
function SQLite.execScalar(query as const zstring ptr) as zstring ptr

	dim as SQLiteDataSet ds
	
	dim as zstring ptr errMsg_ = null
	if sqlite3_exec( instance, query, @callback, @ds, @errMsg_ ) <> SQLITE_OK then 
		errMsg = *errMsg_
		sqlite3_free(errMsg_)
		return null
	else
		errMsg = ""
	end if 
	
	if ds.hasNext then
		var val = (*ds.row)[0]
		if val = null then
			return null
		end if
		
		var val2 = cast(zstring ptr, allocate(len(*val)+1))
		*val2 = *val
		function = val2
	else
		function = null
	end if
	
end function

''''''''	
function SQLite.execNonQuery(query as const zstring ptr) as boolean

	var ds = new SQLiteDataSet
	
	dim as zstring ptr errMsg_ = null
	if sqlite3_exec( instance, query, null, ds, @errMsg_ ) <> SQLITE_OK then 
		errMsg = *errMsg_
		sqlite3_free(errMsg_)
		function = false
	else
		errMsg = ""
		function = true
	end if 
	
	delete ds

end function

''''''''	
function SQLite.execNonQuery(stmt as SQLiteStmt ptr) as boolean

	do
		if stmt->step_() <> SQLITE_ROW then
			exit do
		end if
	loop
	
	function = true

end function
	
''''''''	
function SQLite.prepare(query as const zstring ptr) as SQLiteStmt ptr

	var res = new SQLiteStmt(this.instance)
	if not res->prepare(query) then
		errMsg = *sqlite3_errmsg(instance)
		delete res
		return null
	else
		errMsg = ""
	end if
	
	function = res

end function

''''''''
function SQLite.lastId() as long
	function = sqlite3_last_insert_rowid(instance)
end function

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

''''''''
constructor SQLiteDataSet()
	rows = new TList(10, len(SQLiteDataSetRow))
	currRow = null
end constructor	
	
''''''''
destructor SQLiteDataSet()
	var r = cast(SQLiteDataSetRow ptr, rows->head)
	do while r <> null
		r->destructor		'' NOTA: não user delete, porque foi criado com placement new
		r = rows->next_(r)
	loop
	
	delete rows
	currRow = null
end destructor

''''''''
function SQLiteDataSet.hasNext() as boolean
	return currRow <> null
end function

''''''''
sub SQLiteDataSet.next_() 
	if currRow <> null then
		currRow = rows->next_(currRow)
	end if
end sub

''''''''
property SQLiteDataSet.row() as SQLiteDataSetRow ptr
	return currRow
end property

''''''''
function SQLiteDataSet.newRow(cols as integer) as SQLiteDataSetRow ptr
	var p = rows->add()
	var r = new (p) SQLiteDataSetRow(cols)
	if currRow = null then
		currRow = r
	end if
	return r
end function

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

''''''''
constructor SQLiteDataSetRow(numCols as integer)
	if numCols = 0 then
		numCols = 16
	end if
	dict = new TDict(numCols, true, true, true)
	redim cols(0 to numCols-1)
	cnt = 0
end constructor	
	
''''''''
destructor SQLiteDataSetRow()
	cnt = 0
	delete dict
end destructor

''''''''
sub SQLiteDataSetRow.newColumn(name_ as const zstring ptr, value as const zstring ptr)
	if dict->lookup(name_) = null then
		dim as zstring ptr value2 = null
		if value <> null then
			value2 = cast(zstring ptr, allocate(len(*value)+1))	
			*value2 = *value
		end if
		
		var node = dict->add( name_, value2 )
		
		cnt += 1
		if cnt-1 > ubound(cols) then
			redim preserve cols(0 to cnt-1+8)
		end if

		cols(cnt-1).name = cast(zstring ptr, node->key)
		cols(cnt-1).value = value2
	end if
end sub

''''''''
operator SQLiteDataSetRow.[](index as const zstring ptr) as zstring ptr
	return dict->lookup( index )
end operator

''''''''
operator SQLiteDataSetRow.[](index as integer) as zstring ptr
	if index >= 0 and index <= cnt-1 then
		return cols(index).value
	else
		return null
	end if
end operator

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

''''''''
constructor SQLiteStmt(db as sqlite3 ptr)
	this.db = db
end constructor

''''''''
destructor SQLiteStmt()
	if stmt <> null then
		sqlite3_finalize(stmt)
	end if
end destructor

''''''''
function SQLiteStmt.prepare(query as const zstring ptr) as boolean
	function = sqlite3_prepare_v2(db, query, -1, @stmt, null) = SQLITE_OK
end function
	
''''''''	
sub SQLiteStmt.bind(index as integer, value as integer)
	sqlite3_bind_int(stmt, index, value)
end sub
	
''''''''	
sub SQLiteStmt.bind(index as integer, value as longint)
	sqlite3_bind_int64(stmt, index, value)
end sub
	
''''''''	
sub SQLiteStmt.bind(index as integer, value as double)
	sqlite3_bind_double(stmt, index, value)
end sub
	
''''''''	
sub SQLiteStmt.bind(index as integer, value as const zstring ptr)
	
	'' NOTE: the value string can't be freed or modified until exec() is called!
	
	if value = null then
		sqlite3_bind_null(stmt, index)
	else
		sqlite3_bind_text(stmt, index, value, len(*value), null)
	end if
end sub

''''''''	
sub SQLiteStmt.bind(index as integer, value as const wstring ptr)

	'' NOTE: the value string can't be freed or modified until exec() is called!
	
	if value = null then
		sqlite3_bind_null(stmt, index)
	else
		sqlite3_bind_text16(stmt, index, value, len(*value), null)
	end if
end sub

''''''''	
sub SQLiteStmt.bindNull(index as integer)
	sqlite3_bind_null(stmt, index)
end sub

''''''''	
function SQLiteStmt.step_() as long
	function = sqlite3_step(stmt)
end function

''''''''
sub SQLiteStmt.reset()
	sqlite3_reset(stmt)
end sub

''''''''
sub SQLiteStmt.clear_()
	sqlite3_clear_bindings(stmt)
end sub

''''''''
function SQLiteStmt.colCount() as integer
	function = sqlite3_column_count(stmt)
end function

''''''''
function SQLiteStmt.colName(index as integer) as const zstring ptr
	function = sqlite3_column_name(stmt, index)
end function

''''''''
function SQLiteStmt.colValue(index as integer) as const zstring ptr
	function = sqlite3_column_text(stmt, index)
end function
