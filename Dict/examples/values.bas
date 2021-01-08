#include once "../Dict.bi"

''''
type Type1
	value as integer
	declare constructor(value as integer)
end type

constructor Type1(value as integer)
	this.value = value
end constructor

''''
function generate() as TDict ptr

	var dict = new TDict(10)
	dict->add("foo", new Type1(1234))
	dict->add("bar", new Type1(5678))
	dict->add("baz", new Type1(9012))
	
	return dict

end function

''''
sub main()
	var dict = generate()
	
#define lookup_(dict, key) cast(Type1 ptr, dict->lookup(key))
	
	print lookup_(dict, "foo")->value
	print lookup_(dict, "bar")->value
	print lookup_(dict, "baz")->value
	
	delete dict

end sub

main()