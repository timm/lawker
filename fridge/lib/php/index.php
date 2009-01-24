<? 
include("config.php");  

/*the include file looks like this:
<? 
	$slurping =  "http://lawker.googlecode.com/svn/fridge/etc/config.xml";
?>
*/

function s($string) { 
	 global $magic;
	 if ( $magic[$string] ) {
	    return $magic[$string];
	 } else { return query("//strings/string[@id='" . $string . "']"); }
}
function query($path) {
	global $config;
	$result= $config -> xpath($path);
	return trim($result[0]);
}
function slurp($url) {
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_HEADER, 0);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	$contents = curl_exec($ch);
	curl_close($ch);
	return $contents;
}
function filter_lines($lines,$what,$zap) {	
	$use = 0;
	$out  = "";
	foreach(split("\n",$lines) as $line) {
	     if ($use) { $out .= filter_line($line,$zap) . "\n"; }
             else      { if (empty($line)) { $use=1 ; }}}
	return "<div id=\"$what\">$out</div>";
}
function filter_line($line,$zap) {
	$tmp= preg_replace($zap,"",$line);
	$tmp= preg_replace("/^\.(\S+)\s+(\S.*)$/","<$1>$2</$1>",$tmp);
	$tmp= preg_replace("/^\.(\S+)\s*$/","<$1>",$tmp);
	return $tmp;
}
function thefiles() {
	 global $config;
	 foreach ( $_GET as $key=>$val ) { 
		 if ( preg_match('/^[a-z]/',$key) ) {
		      $files[]= $key;
		 } else { $wheres[] = $key ; 
         }}
	 if (sizeof($wheres)> 0) {
	   foreach ($wheres as $key) {
	      $com= "//files/file[what='".$key."']";
	      $tmp= $config-> xpath($com);
	      foreach($tmp as $one) {	 
	            $where = $one["where"];
		    $all["$where"]++ ;
           }}
           if (sizeof($all) > 0 ) {
	      foreach($all as $key => $value) {
		   if ($value == sizeof($wheres)) {
		      $files[]=$key ;
         }}}}
	 return $files;
}
function contents() { 
	 global $files;
	 global $config;
	 $out="";
	 foreach ($files as $file) {
		 $splits  = preg_split("/[_\.]/",$file);
		 if ($splits[1] ) {        $fname = $splits[0] . "." . $splits[1];
		                  } else { $fname = "doc/" . $file . ".html" ; }
		$path  = s("source")."/".$fname;
		$tmp   = slurp($path) ;
		if ($splits[1]) {
		   if (s($splits[1])) { 			
			   $tmp=filter_lines($tmp, $splits[1],s($splits[1]));}}
		$meta  = "<p class=\"meta\">";
		$sep   = " categories: ";
	        $cats  = $config-> xpath("//files/file[@where='".$fname."']/what");
                if(sizeof($cats)> 1) {  
                  foreach($cats as $key=>$val) {	 
                     $meta .= $sep . "<a href=\"?" . $val . "\">" . $val . "</a>" ;
		     $sep = ", ";
                }}
		$out  .= "<a name=$file></a>" . 
                         preg_replace(s("join"),"<a href=\"" . s("site") . 
                         "/?$fname\">$1</a>",$tmp) . $meta . "</p>";
	}
	return $out;
}
function title() {
	 global $files;
	 if (sizeof($files) == 1) { 
	     return " " . query("//files/file[@where='" . preg_replace("/_\./",".",$files[0]) ."']/title");
	 } else { return $files[1] . "..."; }
}
function titles() {
	 global $files;
	 print "<h1>On this page..</h1>";
	 print "<ul>";
	  foreach ($files as $file) {
	     print "<li><a href=\"#$file\">". query("//files/file[@where='" . $file ."']/title") . "</a>";
	}
	print "</ul>";
}
$config = simplexml_load_string(slurp($slurping));
$files=thefiles();
if (sizeof($files) == 0) { $files[]= s("default") ; }
$magic["Content"]=contents();
$magic["Title"]=title();
$pieces  = explode(s("delimiter"), slurp(s("source") . "/" . s("index") . "/index.html"));
foreach($pieces as $piece) { 	print ($raw = 1 - $raw) ?  $piece :   s($piece); }
?>
