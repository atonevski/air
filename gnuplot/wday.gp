set terminal wxt enhanced size 600, 400 font "DroidSans"

# set output 'wday.png'
# set terminal png size 600, 400

set grid 
set style fill transparent solid 0.027397 noborder
set style circle radius 0.10

set xdata time
set timefmt '%Y-%m-%d'

set xrange [-1 : 7]
set xtics ('' -1, 'Sun' 0, 'Mon' 1, 'Tue' 2, 'Wed' 3, 'Thu' 4, 'Fri' 5, 'Sat' 6)

set yrange [0 : 500]

plot 'wday.data' using (tm_wday(timecolumn(1))):2 with circles lc rgb 'blue'
