set terminal wxt enhanced size 1000, 400 font "DroidSans"

# set output 'hour.png'
# set terminal png size 1000, 400

set xtics font "DroidSans, 8"
set ytics font "DroidSans, 10"
set xlabel font "DroidSans, 12"
set ylabel font "DroidSans, 12"
set title font "DroidSans-Bold, 12"

set grid 
set style fill transparent solid 0.027397 noborder
set style circle radius 0.18

set xdata time
set timefmt '%H:%M'

# set format x "%M:%S"

set yrange[0 : 500]
set xrange [-1 : 24]

set xtics ("" -1, "00:00" 0, "01:00" 1, "02:00" 2, "03:00" 3, "04:00" 4, "05:00" 5, "06:00" 6,\
  "07:00" 7, "08:00" 8, "09:00" 9, "10:00" 10, "11:00" 11, "12:00" 12, "13:00" 13, "14:00" 14,\
  "15:00" 15, "16:00" 16, "17:00" 17, "18:00" 18, "19:00" 19, "20:00" 20, "21:00" 21, "22:00" 22,\
  "23:00" 23, "24:00" 24)

plot 'hour.data' using (tm_hour(timecolumn(1))):2 with circles lc rgb 'blue'
