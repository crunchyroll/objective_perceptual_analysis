set terminal png size 1920,1080 enhanced font "arial,8"
set output 'stats.jpg'

set style line 2  lc rgb 'red' lt 1 lw 1 #
set style line 3  lc rgb 'orange' lt 1 lw 1 #
set style line 4  lc rgb 'black' lt 1 lw 1 #
set style line 5  lc rgb 'green' lt 1 lw 3 #
set style line 6  lc rgb 'blue' lt 1 lw 3 #
#set style data histogram
set style data line
set key opaque
#set style histogram cluster gap 1
#set style fill pattern border -1
set boxwidth 0.9
set yrange [0:100]
set xtics format ""
set xtics rotate
set grid ytics
set grid xtics
set xtics 0
set ytics 1

set title "test"
plot "stats.dat" using 2:xtic(1) title "vmaf" ls 2, "stats.dat" using (100*$3) title "ssim" ls 3, "stats.dat" using ($4) title "psnr" ls 4, "stats.dat" using ($5/100) title "bitrate" ls 5, "stats.dat" using ($6/100) title "speed" ls 6

