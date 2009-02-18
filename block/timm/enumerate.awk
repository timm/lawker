function all (fun,a,max,   i) {
	if (max) 
		for(i=1;i<=max;i++) @fun(a[i]) 
	else  
		for(i in a) @fun(a[i])
}
function collect (fun,a,b,max,   i) {
	if (max)
		for(i=1;i<=max;i++) b[i]= @fun(a[i])
	else
		for(i in a) b[i]= @fun(a[i])
}
function select (fun,a,b,max,   i) {
	if (max)
		for(i=1;i<=max;i++) {
			if (@fun(a[i])) b[i]= a[i] }
	else
		for(i in a) {
			if (@fun(a[i])) b[i]= a[i] }
}
function reject (fun,a,b,max,   i) {
	if (max)
		for(i=1;i<=max;i++) {
			if (! @fun(a[i])) b[i]= a[i] }
	else
		for(i in a) {
			if (! @fun(a[i])) b[i]= a[i] }
}
BEGIN {Fail="someUnLIKELYSymbol"}
function detect (fun,a,max,   i) {
	if (max)
		for(i=1;i<=max;i++) {
			if (@fun(a[i])) return a[i] }
	else	
		for(i in a) {
			if (@fun(a[i])) return a[i] }
	return Fail
}
function inject (fun,a,carry,max,   i) {
	if (max)
		for(i=1;i<=max;i++)
			 carry = @fun(a[i],carry) 
	else
		for(i in a)
			 carry = @fun(a[i],carry) 
	return carry
}
