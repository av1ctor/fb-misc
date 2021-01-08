#include once "../List.bi"

''''
type Type1
	value as integer
	declare constructor(value as integer)
end type

constructor Type1(value as integer)
	this.value = value
end constructor

''''
function generate() as TList ptr

	var list = new TList(10, len(Type1))
	
	var node1 = cast(Type1 ptr, list->add())
	node1->value = 1234
	
	var node2 = cast(Type1 ptr, list->add())
	node2->value = 5678
	
	var node3 = cast(Type1 ptr, list->add())
	node3->value = 9012
	
	return list
	
end function

''''
sub main()
	var list = generate()

	var node = cast(Type1 ptr, list->head())
	do while node <> null
		print node->value
		node = list->next_(node)
	loop
	
	delete list
end sub


main()