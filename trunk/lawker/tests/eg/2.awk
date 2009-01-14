#use "../../array/array.awk"

BEGIN {
    New[1]="tim";
    New[2]="tam";
    print length(New) 
    array(New)
    print length(New) 
}