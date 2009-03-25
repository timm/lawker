<? 
include("config.php");  
include("lastRSS.php");
/*the include file looks like this:
<? $slurping =  "http://lawker.googlecode.com/svn/fridge/etc/config.xml"; ?>
*/
function rss($feed,$n = 5) {
	$rss = new lastRSS;
	$rss->cache_dir = './cache';
	$rss->cache_time = 3600; // one hour
	$rs = $rss->get($feed);
	foreach ($rs['items'] as $item) {
		$date = explode(" ",$item[pubDate]);
     		$out = $out .  "<p> <a href=" . $item[enclosure][url] ."> $date[2] $date[1]</a>: " .
                                 preg_replace('/....div.*/','',$item[description] ) ;

		$n   = $n - 1;
		if ($n == 0) {break; }; 
	}
	return $out;
}
function s($string) { 
	 $list = explode(',',$string);
	 if (sizeof($list) == 1) {
		return s0($string); 
	} else { return specials($string,$list); }
}
function s0($string) {
	 global $magic;
	 if ( $magic[$string] ) {
	    return $magic[$string];
	 } else { return query("//strings/string[@id='" . $string . "']"); }
}
function specials($string,$list) {
	return rss($list[2],$list[1]); 
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

function filter_specials($lines,$what,$zap) {	
	$use = 0;
	$out  = "";
	foreach(split("\n",$lines) as $line) {
	     if ($use) { $out .= filter_special($line,$zap) . "\n"; }
             else      { if (empty($line)) { $use=1 ; }}}
	if (empty($what)) {
		return $out; 
	} else { return "<div id=\"$what\">$out</div>"; }
}
function filter_special($line,$zap) {
	if (empty($zap)) {
		$tmp=$line; 
        } else { $tmp= preg_replace($zap,"",$line); }
	if(preg_match("/RSS/",$tmp)) {
		return "RSS11";
	}
	if(preg_match("/^.BODY/i",$tmp)) {
	    $words = preg_split('/\s+/', $tmp);
#	    $words = explode(" ",$tmp);
	    $url= s("source") . "/" . $words[1];
	    $contents = slurp($url);
	    return "<p><a href=\"$url\">${words[1]}</a> &raquo; </p><pre>". filter_specials($contents,"","") . "</pre>\n" ;
	}
	if(preg_match("/^.CODE/i",$tmp)) {
	       $words = preg_split('/\s+/', $tmp);
	    $url= s("source") . "/" . $words[1];
	    $contents = slurp($url);
	    return "<p><a href=\"$url\">${words[1]}</a> &raquo; </p><pre>". $contents . "</pre>\n" ;
	}
	if(preg_match("/^.IN/i",$tmp)) {
		    $words = preg_split('/\s+/', $tmp);
	    $url= s("source") . "/" . $words[1];
	    return slurp($url) . "\n";
	}
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
function foriegnContents($file,$type) {
	$path  = preg_replace("/_/",".",$file);
	$path  = preg_replace("/$type:/","http://",$path);
        $tmp   = slurp($path) ;
	return filter_specials($tmp, "$type",s($type));      
}
function contents($permalink) { 
	 global $files;
	 global $config;
	 $between="";
	 	$out = "";
   	foreach ($files as $file) {
	     if (preg_match("/^awk:/",$file)) {
			$tmp=foriegnContents($file,"awk");
		 } else {
 		    $splits = preg_split("/[_\.]/",$file);
	 	    if ($splits[1] ) {        $fname = $splits[0] . "." . $splits[1];
		                     } else { $fname = "doc/" . $file . ".html" ; }
		    $path  = s("source")."/".$fname;
	            $tmp   = slurp($path) ;  
		    if ($splits[1] && s($splits[1])) { 			
			    $tmp=filter_specials($tmp, $splits[1],s($splits[1])); 
		    } 
	        }
		$meta  = "<p class=\"meta\">";
		$sep   = " categories: ";
	        $cats  = $config-> xpath("//files/file[@where='".$fname."']/what");
                if(sizeof($cats)> 1) {  
                  foreach($cats as $key=>$val) {	 
                     $meta .= $sep . "<a href=\"?" . $val . "\">" . $val . "</a>" ;
		     $sep = ",";
                }}
#		$meta.=" <div 
#				   class=\"js-kit-rating\" 
#				   	title=\"\" permalink=\"" . s("site") . "/?$fname\">" . "
#				   thumbsize=\"small\" starColor=\"Golden\" style=\"float: right;\"> 
#		          <script src=\"http://js-kit.com/ratings.js\"></script></div>";

	
			$out  .= $between . "<a name=\"$file\"></a>" . $meta . "</p>" .
                         preg_replace(s("join"),"<a href=\"" . s("site") . 
                         "/?$fname\">$1</a>",$tmp) ;
		$between = "<hr>";
	}
	return $out;
}
function title() {
	 global $files;
	 if (sizeof($files) == 1) { 
	 	 $thing = $files[0];
	 	 if (!preg_match("/\_html/",$thing)) {
		 	$thing = "doc/" . $thing . ".html";
		 };
	 	 $thing =  preg_replace("/_/",".",$thing) ;
	     return " " . query("//files/file[@where='" .  $thing  ."']/title");
	 } else { $str = "";
	 		  $sep = "";
	 		  foreach ( $_GET as $key=>$val ) { 	        
	 		  	$str .= $sep . $key;
				$sep = " and ";
			  } 
	 	    return $str; }
}
$config = simplexml_load_string(slurp($slurping));
$files=thefiles();
if (sizeof($files) == 0) { $files[]= s("default") ; }
$magic["Content"]=contents(md5(implode(",",$_GET)));
$magic["Title"]=title();
$pieces  = explode(s("delimiter"), slurp(s("source") . "/" . s("index") . "/index.html"));
foreach($pieces as $piece) { 	print ($raw = 1 - $raw) ?  $piece :   s($piece); }
?>
