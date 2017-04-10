#!/bin/bash
# SEO swissgeodata.
#LANG=de_CH.UTF-8

ftp_u=tbd
ftp_p=tbd
ftp_dir=ftp.ihostfull.com/htdocs/

ROOT=/tmp/test
places="/home/gabi/Dokumente/places_test.txt"
layers="/home/gabi/Dokumente/layers_test.txt"
metadata_unicode="/tmp/test/metadata_unicode.txt"
metadata="/tmp/test/metadata.txt"
HTTP="/"
APO="'"
STRICHPUNKT=";"
OUTPUT="/tmp/test/index.html" 
SPEC_CHAR="ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ"
NORM_CHAR="AAAAAAACEEEEIIIIDNOOOOOOUUUUYPSaaaaaaaceeeeiiiionoooooouuuuyby"

rm -rf $ROOT$HTTP 
mkdir $ROOT

for lang in de fr it en
do
	echo $lang  # Loop through languages
  while read l # Loop through layers
	do
		echo $lang $l  # Loop through layers
		 
	     curl -silent http://api3.geo.admin.ch/rest/services/api/MapServer?searchText=$l"&"lang=$lang > $metadata_unicode
 		 #file -bi $metadata_unicode
	    # echo -e "$(cat $metadata_unicode) " | iconv -f ISO-8859-1 -t latin1 > $metadata
		#file -bi $metadata
		 #iconv -f us-ascii -t utf-8 $metadata_unicod > $metadata
	     #recode ISO-8859-1..UTF-8 $metadata
		 echo -e "$(cat $metadata_unicode) " | ascii2uni -a U -q > $metadata
 		# echo -e "$(cat $metadata_unicode) " | convmv -f ISO-8859-1 -t UTF-8 > $metadata
		 abstract=$(echo -e "$(cat $metadata) " | grep -Po '(?<="abstract":")[^"]*' | head -1) 
		 fullname=$(echo -e "$(cat $metadata) " | grep -Po '(?<="fullName":")[^"]*' | head -1) 
		 fullname_nospace=$(echo $fullname | sed 's/ /-/g')
			 fullname_nospace=$(echo $fullname_nospace | sed 's/:/-/g')
			 fullname_nospace=$(echo $fullname_nospace | sed 's/;/-/g')
			 fullname_nospace=$(echo $fullname_nospace | sed 's/,/-/g')
			 fullname_nospace=$(echo $fullname_nospace | sed 's/(/-/g')
			 fullname_nospace=$(echo $fullname_nospace | sed 's/)/-/g')
			 fullname_nospace=$(echo $fullname_nospace | sed 's/'$APO'/-/g')
			 fullname_nospace=$(echo $fullname_nospace | sed 'y/'$SPEC_CHAR'/'$NORM_CHAR'/')
			 fullname_nospace=$(echo $fullname_nospace | sed 's/--/-/g')
		 name=$(echo -e "$(cat $metadata) " | grep -Po '(?<="name":")[^"]*' | head -1) 
		 dataowner=$(echo -e "$(cat $metadata) " | grep -Po '(?<="dataOwner":")[^"]*' | head -1) 
		 urlDetails=$(echo -e "$(cat $metadata) " | grep -Po '(?<="urlDetails":")[^"]*' | head -1) 
		 idGeoCat=$(echo -e "$(cat $metadata) " | grep -Po '(?<="idGeoCat":")[^"]*' | head -1) 
		 inspireUpperAbstract=$(echo -e "$(cat $metadata) " | grep -Po '(?<="inspireUpperAbstract":")[^"]*' | head -1)
		 inspireUpperName=$(echo -e "$(cat $metadata) " | grep -Po '(?<="inspireUpperName":")[^"]*' | head -1) 
		 downloadUrl=$(echo -e "$(cat $metadata) " | grep -Po '(?<="downloadUrl":")[^"]*' | head -1) 
	     dataStatus=$(echo -e "$(cat $metadata) " | grep -Po '(?<="dataStatus":")[^"]*' | head -1) 

	 while read p # Loop through places
		do
				ort=${p%;*;*;*}
				ort=$(echo $ort | sed 's/ //g')
					temp=${p%;*;*}
				plz=${temp#*;}
					temp=${p#*;*;}
				kanton=${temp%;*}
				url_end=${p##*;}
		
		# Simple automated HTML template

		mkdir -p $ROOT/$lang/$kanton/$ort/

		cat > $ROOT/$lang/$kanton/$ort/$plz-$ort-$fullname_nospace.html << _EOF_
<!doctype html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=us-ascii">
<title> $ort ($kanton) $name</title>
<meta name="keywords" content="maps Switzerland, map viewer, Confederation, geodata, public platform, geographical information, geoportal, orthophotos, geolocation, geoinformation, Geodaten, Geoinformation, Bund, Plattform, Karte, Kartendienst, Kartenviewer $inspireUpperAbstract $ort $kanton $inspireUpperName $name $fullname">
</head>
 
<body>
 
<center><h1><span>$plz $ort ($kanton) $fullname </span> </h1> <br> ($dataowner)<br></center>
<p>$abstract</p>
<br>
<iframe src='https://map.geo.admin.ch/embed.html?topic=ech&lang=$lang&layers=$l$url_end' width='100%' height='350' frameborder='0' style='border:0'></iframe>

  <br>
  <h2> <span>Legende</span>  </h2><br>
  
    <img src="https://api3.geo.admin.ch/static/images/legends/${l}_${lang}.png" alt="Click in map">

  <br><br>

  <h2>  <span>Information</span>  </h2><br>
  <table>
    <tbody>
	<tr>
	<td>Print</td>
	 <td><a target="_blank" href="https://map.geo.admin.ch/?topic=ech&widgets=print&lang=$lang&layers=$l$url_end">
      PDF</a</td>
    </tr>
	<tr>
    <td>Info</td>
      <td><a target="_blank" href="http://www.geocat.ch/geonetwork/srv/eng/metadata.show?uuid=$idGeoCat&amp;currTab=simple">
      Detail</a></td>
    </tr>
	<tr>
	<td>Detail</td>
      <td><a target="_blank" href="$urlDetails">
      Detail</a></td>
    </tr>
     <tr>
      <td>Download</td>
      <td><a href="$downloadUrl" target="new">Link</a></td>
    </tr>
     <tr>
      <td>Data status</td>
      <td>$dataStatus</td>
    <div></tr>
  </tbody></table>
</div>
</div>


</body>
 
</html>
_EOF_

				curl -s -T $ROOT/$lang/$kanton/$ort/$plz-$ort-$fullname_nospace.html ftp://$ftp_u:$ftp_p@$ftp_dir$lang/$kanton/$ort/$plz-$ort-$fullname_nospace.html --ftp-create-dirs

				#update index site for place
				output_index=$ROOT/$lang/$kanton/$ort/index.html

				if [ -s $output_index ]
					then
						sed -i '$ d' $output_index 
						echo "<a href="$plz-$ort-$fullname_nospace.html">$fullname_nospace PLZ $plz </a><br/>" >> $output_index
						echo "</body>" >> $output_index
				else
					echo "<!doctype html>" > $output_index
					echo "<html>" >> $output_index
					echo "<head>" >> $output_index
					echo "<meta http-equiv="Content-Type" content="text$HTTP html$STRICHPUNKT charset=UTF-8">" >> $output_index
					echo "    <title> $plz $ort ($kanton)</title>" >> $output_index
					echo "<meta name="keywords" content="maps Switzerland, map viewer, Confederation, geodata, public platform, geographical information, geoportal, orthophotos, geolocation, geoinformation, Geodaten, Geoinformation, Bund, Plattform, Karte, Kartendienst, Kartenviewer  $ort $kanton ">"  >> $output_index
					echo "</head>" >> $output_index
					echo "<body>" >> $output_index
					echo "<center><h1><span>$plz $ort ($kanton) </span> </h1> <br> " >> $output_index
					echo "<a href="$plz-$ort-$fullname_nospace.html">$fullname_nospace PLZ $plz </a><br/>" >> $output_index
					echo "</body>" >> $output_index
				fi
				curl -s -T $output_index ftp://$ftp_u:$ftp_p@$ftp_dir$lang/$kanton/$ort/index.html --ftp-create-dirs

				#clean up after places run
				rm $ROOT/$lang/$kanton/$ort/$plz-$ort-$fullname_nospace.html
				unset url_end
				unset kanton
				unset ort
				unset plz
				unset output_index

		done < $places # End through places
		
		rm -f $metadata
		rm -f $metadata_unicode
		unset abstract
		unset fullname
		unset name
		unset dataowner
		unset urlDetails
		unset idGeoCat
		unset inspireUpperAbstract
		unset inspireUpperName
		unset downloadUrl
	    unset dataStatus

  		done < $layers # End through layers
    #generate index file to Gemeinde
	echo "<!doctype html>" > $ROOT/$lang/index.html
	echo "<html>" >> $ROOT/$lang/index.html
	echo "<head>" >> $ROOT/$lang/index.html
	echo "<meta http-equiv="Content-Type" content="text$HTTP html$STRICHPUNKT charset=UTF-8">" >> $ROOT/$lang/index.html
	echo "    <title> Swissgeodata $lang </title>" >> $ROOT/$lang/index.html
	echo "<meta name="keywords" content="maps Switzerland, map viewer, Confederation, geodata, public platform, geographical information, geoportal, orthophotos, geolocation, geoinformation, Geodaten, Geoinformation, Bund, Plattform, Karte, Kartendienst, Kartenviewer  ">"  >> $ROOT/$lang/index.html
	echo "</head>" >> $ROOT/$lang/index.html
	echo "<body>" >> $ROOT/$lang/index.html
	echo "<center><h1><span>Swissgeodata $lang  </span></center></h1> <br> " >> $ROOT/$lang/index.html
	z=0
	echo "<UL>" >> $ROOT/$lang/index.html
	for filepath in `find "$ROOT/$lang" -maxdepth 1 -mindepth 1 -type d| sort`; do
	  path=`basename "$filepath"`
	  echo "  <LI>$path</LI>" >> $ROOT/$lang/index.html
	  echo "  <UL>" >> $ROOT/$lang/index.html
	  for z in `find "$filepath" -maxdepth 1 -mindepth 1 -type d| sort`; do
    	file=`basename "$z"`
    	echo "    <LI><a href=\"/$lang/$path/$file\"index.html>$file</a></LI>" >> $ROOT/$lang/index.html
	  done
	  echo "  </UL>" >> $ROOT/$lang/index.html
	done
	echo "</UL>" >> $ROOT/$lang/index.html
	echo "</body>" >> $ROOT/$lang/index.html
	echo "</html>" >> $ROOT/$lang/index.html

	curl -s -T $ROOT/$lang/index.html ftp://$ftp_u:$ftp_p@$ftp_dir$lang/ --ftp-create-dirs


	done # End through languages

 



