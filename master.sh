#!/bin/bash
# SEO swissgeodata.


ROOT=/tmp/test
places="/home/gabi/Dokumente/places_test.txt"
layers="/home/gabi/Dokumente/layers_test.txt"
metadata="/tmp/test/metadata.txt"
HTTP="/"
OUTPUT=/tmp/_includes/site-index.html 

for lang in de fr it en
do
	echo $lang  # Loop through languages
  while read l # Loop through layers
	do
		#echo $l  # Loop through layers
	     curl -silent http://api3.geo.admin.ch/rest/services/api/MapServer?searchText=$l"&"lang=$lang > $metadata
		 abstract=$(cat $metadata |grep -Po 'abstract"."\K.*?(?=",")')
		 fullname=$(cat $metadata |grep -Po 'fullName":"\K.*?(?=",")')
		 name=$(cat $metadata |grep -Po 'name":"\K.*?(?=")')
		 dataowner=$(cat $metadata |grep -Po 'dataOwner":"\K.*?(?=",")')
		 urlDetails=$(cat $metadata |grep -Po 'urlDetails":"\K.*?(?=",")')
		 idGeoCat=$(cat $metadata |grep -Po 'idGeoCat":"\K.*?(?=",")')
		 inspireUpperAbstract=$(cat $metadata |grep -Po 'inspireUpperAbstract":"\K.*?(?=",")')
		 inspireUpperName=$(cat $metadata |grep -Po 'inspireUpperName":"\K.*?(?=",")')
		 downloadUrl=$(cat $metadata |grep -Po 'downloadUrl":"\K.*?(?=",")')
	     dataStatus=$(cat $metadata |grep -Po 'dataStatus":"\K.*?(?=",")')
		 #echo $abstract	
		 #echo $fullname 
		 #echo $name 
		 #echo urlDetails $urlDetails
			#echo $dataowner 
			#echo $idGeoCat 
			#echo $inspireUpperAbstract 
			#echo $downloadUrl 
			#echo $inspireUpperName
    		#echo dataStatus $dataStatus
			#echo bild https://api3.geo.admin.ch/static/images/legends/${l}_${lang}.png

	 while read p # Loop through places
		do
			#echo $p  
				ort=${p%;*;*;*}
				ort=$(echo $ort | sed 's/ //g')
					temp=${p%;*;*}
				plz=${temp#*;}
					temp=${p#*;*;}
				kanton=${temp%;*}
				url_end=${p##*;}
				#echo kanton $kanton
				#echo ort $ort
				#echo plz $plz
				#echo url_end $url_end
		
# Simple automated HTML template

mkdir -p $ROOT/$lang/$kanton/$ort/

cat > $ROOT/$lang/$kanton/$ort/$plz-$ort-$l.html << _EOF_
<!doctype html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title> $ort $name</title>
<meta name="keywords" content="maps Switzerland, map viewer, Confederation, geodata, public platform, geographical information, geoportal, orthophotos, geolocation, geoinformation, Geodaten, Geoinformation, Bund, Plattform, Karte, Kartendienst, Kartenviewer $inspireUpperAbstract $ort $kanton $inspireUpperName $name $fullname">
</head>
 
<body>
 
<center><h1><span>$plz $ort $fullname </span> </h1> <br> ($dataowner)</p></center>
<p>$abstract</p>
</div>
<iframe src='https://map.geo.admin.ch/embed.html?topic=ech&lang=$lang&layers=$l$url_end' width='100%' height='350' frameborder='0' style='border:0'></iframe>

  <br>
  <h2> <span>Legend</span>  </h2><br>
  
    <img src="https://api3.geo.admin.ch/static/images/legends/${l}_${lang}.png" alt="layer legend img">
  </div>
  <br><br>

  <h2>  <span>Information</span>  </h2><br>
  <table>
    <tbody><tr><td>Print</td> <td><a target="_blank" href="https://map.geo.admin.ch/?topic=ech&widgets=print&lang=$lang&layers=$l$url_end">
      PDF</a</tr>
      <tr><td>Info</td>
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
    <div></div></tr>
  </tbody></table>
</div>
</div>
</div>


</body>
 
</html>
_EOF_

																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											unset url_end
unset kanton
unset ort
unset plz

		done < $places # End through places
		
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


done # End through languages


 

i=0
echo "<UL>" > $OUTPUT
for filepath in `find "$ROOT" -maxdepth 10 -mindepth 1 -type d| sort`; do
  path=`basename "$filepath"`
  echo "  <LI>$path</LI>" >> $OUTPUT
  echo "  <UL>" >> $OUTPUT
  for i in `find "$filepath" -maxdepth 1 -mindepth 1 -type f| sort`; do
    file=`basename "$i"`
    echo "    <LI><a href=\"/$path/$file\">$file</a></LI>" >> $OUTPUT
  done
  echo "  </UL>" >> $OUTPUT
done
echo "</UL>" >> $OUTPUT


exit 0

