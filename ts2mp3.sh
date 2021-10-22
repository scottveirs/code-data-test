# ts2mp3.sh expects two arguments:
#1 node name (one string with underscores, e.g. bush_point (NOTE: no leading rpi_ !)
#2 UNIX timestamp of desired S3 folder within the nodes hls folder
#3 Start time in hours after the UNIX timestamp
#4 Stop time in hours after the UNIX timestamp

# Add some logic to skip data that isn't between the desired start and stop times
# i.e. within aws sync call or in the for loop (delete some .ts segments; rename others)

echo "You provided $# arguments: $1, $2, $3, and $4"
aws s3 sync s3://streaming-orcasound-net/rpi_$1/hls/$2/ .
for file in live*; do mv "$file" "${file#live}"; done;
for i in *.ts ; do
    mv $i `printf '%04d' ${i%.ts}`.ts
done
printf "file '%s'\n" *.ts > mylist.txt

ffmpeg -f concat -safe 0 -i mylist.txt -c copy all.ts
ffmpeg -i all.ts -c:v libx264 -c:a copy -bsf:a aac_adtstoasc output.mp4
ffmpeg -i output.mp4 output.mp3

mv *.ts data-input-dir
mv mylist.txt data-input-dir
mv live.m3u8 data-input-dir
rm output.mp4
mv output.mp3 data-output-dir

