#Automatic map of last month of world-wide seismicity

gmt begin ex22
	gmt set FONT_ANNOT_PRIMARY 10p FONT_TITLE 18p FORMAT_GEO_MAP ddd:mm:ssF

	# Get data from USGS using the curl

SITE="https://earthquake.usgs.gov/fdsnws/event/1/query.csv"
TIME="starttime=2022-01-01%2000:00:00&endtime=2022-01-25%2000:00:00"
MAG="minmagnitude=3"
ORDER="orderby=magnitude"
URL="${SITE}?${TIME}&${MAG}&${ORDER}"
curl -s $URL > usgs_quakes_22.txt

# Count the number of events used in title later.
	file=$(gmt which @usgs_quakes_22.txt -G)
	n=$(gmt info $file -h1 -Fi -o2)

# Pull out the first and last timestamp to use in legend
	first=$(gmt info -h1 -f0T -i0 $file -C --TIME_UNIT=d -I1 -o0 --FORMAT_CLOCK_OUT=-)
	last=$(gmt info -h1 -f0T -i0 $file -C --TIME_UNIT=d -I1 -o1 --FORMAT_CLOCK_OUT=-)


	#set me = "$user@@$(hostname)"
	me="nbladis @@ GMT"

	# Standard seismicity color table
	gmt makecpt -Cred,green,blue -T0,100,300,10000 -N

	# Plotting. Step 1 lay down map, Step 2 plot quakes with size = magnitude * 0.015":
	gmt coast -Rg -JK180/22c -B45g30 -B+t"World-wide earthquake activity" -Ggray76 -Sgray44 -A1000 -Y7c
	gmt plot -C -Sci -Wfaint -hi1 -i2,1,3,4+s0.015 $file

	# Create legend input file for NEIS quake plot
	cat > neis.legend <<- END
	H 16p,Helvetica-Bold $n events during $first to $last
	D 0 1p
	N 3
	V 0 1p
	S 0.25c c 0.25c red   0.25p 0.5c Shallow depth (0-100 km)
	S 0.25c c 0.25c green 0.25p 0.5c Intermediate depth (100-300 km)
	S 0.25c c 0.25c blue  0.25p 0.5c Very deep (> 300 km)
	D 0 1p
	V 0 1p
	N 7
	V 0 1p
	S 0.25c c 0.15c - 0.25p 0.75c M 3
	S 0.25c c 0.20c - 0.25p 0.75c M 4
	S 0.25c c 0.25c - 0.25p 0.75c M 5
	S 0.25c c 0.30c - 0.25p 0.75c M 6
	S 0.25c c 0.35c - 0.25p 0.75c M 7
	S 0.25c c 0.40c - 0.25p 0.75c M 8
	S 0.25c c 0.45c - 0.25p 0.75c M 9
	D 0 1p
	V 0 1p
	N 1
	END

	# legend text
	cat <<- END >> neis.legend
	G 0.25l
	P

	END


	gmt legend -DJBC+o0/1c+w18c/4.2c -F+p+glightyellow neis.legend

	rm neis.legend usgs_quakes_22.txt
gmt end show
