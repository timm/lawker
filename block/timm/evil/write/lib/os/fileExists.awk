function fileExists(f,  exists) {
	exists = (getline < f) > 0;	
	close(f);
	return exists;
}
