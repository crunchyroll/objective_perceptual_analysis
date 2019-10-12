set terminal png size 1920,1080 enhanced font "arial,8"
set output 'stats.jpg'

set style line 2  lc rgb 'red' lt 1 lw 1 #
set style line 3  lc rgb 'brown' lt 1 lw 1 #
set style line 4  lc rgb 'black' lt 1 lw 1 #
set style line 5  lc rgb 'green' lt 1 lw 3 #
set style line 6  lc rgb 'blue' lt 1 lw 2 #
set style line 7  lc rgb 'orange' lt 1 lw 1 #
#set style data histogram
set style data line
set key opaque
#set style histogram cluster gap 1
set style fill pattern border -1
set boxwidth 0.9
set yrange [0:100]
set xtics format ""
set xtics rotate
set grid ytics
set grid xtics
set xtics 1
set ytics 1

set title "test"
plot "stats.csv" using 3:xtic(1) title "vmaf" ls 2, "stats.csv" using (100*$4) title "ssim" ls 3, "stats.csv" using ($5) title "psnr" ls 4, "stats.csv" using ($6/100) title "bitrate" ls 5, "stats.csv" using ($7/100) title "speed" ls 6, "stats.csv" using 2 title "phqm" ls 7
