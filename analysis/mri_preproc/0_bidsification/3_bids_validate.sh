# run docker image for bids validator from command line
docker run -ti --rm -v /neurodata/mindful_brain_project/data/bids_data:/data:ro bids/validator /data
