proc enable_tracequeue { ns redqueue } {
	global tchan_ 
	## $self instvar tchan_ node_
	set redq $redqueue
	set tchan_ [open all.q w]
	$redq trace curq_
	$redq trace ave_
	$redq attach $tchan_
}

proc enable_tracequeue_DT { ns redqueue } {
	global tchan_ 
	## $self instvar tchan_ node_
	set redq $redqueue
	set tchan_ [open all.q w]
	$redq trace curq_
	$redq attach $tchan_
}
