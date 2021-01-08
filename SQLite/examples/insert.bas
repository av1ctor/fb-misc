#include once "../SQLite.bi"

''''
sub insert(db as SQLite ptr, stmt as SQLiteStmt ptr, key as string, value as integer)
	stmt->reset()
	stmt->bind(1, key)
	stmt->bind(2, value)
	if not db->execNonQuery(stmt) then
		print "Error inserting values:"; *db->getErrorMsg()
	end if
end sub

''''
sub generate(db as SQLite ptr) 
	
	if not db->execNonQuery("create table dict(key varchar(64) primary key not null, value integer not null)") then
		print "Error creating table:"; *db->getErrorMsg()
		return
	end if
	
	var stmt = db->prepare("insert into dict(key, value) values (?,?)")
	if stmt = null then
		print "Error creating statement:"; *db->getErrorMsg()
		return
	end if
	
	insert(db, stmt, "foo", 1234)
	insert(db, stmt, "bar", 5678)
	insert(db, stmt, "baz", 9012)
	
end sub

''''
sub main()
	var db = new SQLite()
	if db = null then
		return
	end if

	db->open()
	
	generate(db)
	
	var ds = db->exec("select key, value from dict order by key asc")
	if ds = null then
		print "Error selecting values:"; *db->getErrorMsg()
	else
		do while ds->hasNext()
			var row = ds->row
			print *(*row)["key"]; "="; *(*row)["value"]
			ds->next_()
		loop
		
		delete ds
	end if
	
	db->close()
	
	delete db
end sub

main()