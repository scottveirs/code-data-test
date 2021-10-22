# ts2mp3.sh expects two arguments:
#1 node name (one string with underscores, e.g. bush_point (NOTE: no leading rpi_ !)
#2 UNIX timestamp of desired S3 folder within the nodes hls folder
#3 Start time in hours after the UNIX timestamp
#4 Stop time in hours after the UNIX timestamp

# Add some logic to skip data that isn't between the desired start and stop times
# i.e. within aws sync call or in the for loop (delete some .ts segments; rename others)

echo "You provided $# arguments: $1, $2, $3, and $4"
aws s3 sync s3://streaming-orcasound-net/rpi_$1/hls/$2/ data-input-dir
for file in data-input-dir/live*; do mv "$file" "${file#live}"; done;
for i in data-input-dir/*.ts ; do
    mv $i `printf '%04d' ${i%.ts}`.ts
done
printf "file '%s'\n" data-input-dir/*.ts > mylist.txt
ffmpeg -f concat -safe 0 -i mylist.txt -c copy data-output-dir/all.ts
ffmpeg -i data-output-dir/all.ts -c:v libx264 -c:a copy -bsf:a aac_adtstoasc data-output-dir/output.mp4
ffmpeg -i data-output-dir/output.mp4 output.mp3
