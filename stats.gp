set terminal png size 1920,1080 enhanced font "arial,8"
set output 'stats.jpg'

set style line 2  lc rgb 'red' lt 1 lw 1 #
set style line 3  lc rgb 'brown' lt 1 lw 1 #
set style line 4  lc rgb 'black' lt 1 lw 1 #
set style line 5  lc rgb 'green' lt 1 lw 3 #
set style line 6  lc rgb 'blue' lt 1 lw 2 #
set style line 7  lc rgb 'orange' lt 1 lw 1 #
set style line 8  lc rgb 'yellow' lt 1 lw 1 #
#set style data histogram
set style data line
set key opaque
set style histogram cluster gap 1
set style fill pattern border -1
set boxwidth 0.9
set yrange [0:100]
set xtics format ""
set xtics rotate
set grid ytics
set grid xtics
set xtics 1
set ytics 1

# 1     2       3       4       5       6       7       8
# test  pfhd    phqm    vmaf    ssim    psnr    bitrate speed
set title "stats"
set title "stats"
plot "stats.csv" using ($4):xtic(1) title "VMAF" ls 2, "stats.csv" using 3 title "PHQM" ls 6, "stats.csv" using 6 title "PSNR" ls 7, "stats.csv" using ($7/100) title "Bitrate" ls 5, "stats.csv" using ($8/60) title "Speed" ls 4
