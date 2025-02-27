docker run -ti --rm -v /Users/paulbloom/Documents/bids_data_02.14.2025:/data:ro bids/validator /data

docker run --privileged -it --rm \
 -v /Users/paulbloom/Documents/bids_data_02.14.2025:/data:ro \
 -v /Users/paulbloom/Documents/mriqc_out:/out \
 --user $(id -u):$(id -g) \
 nipreps/mriqc:24.0.1 \
 /data /out participant --participant-label sub-remind2002 \
 --notrack --verbose



