sudo docker run \
    --name="liosam_ros" \
    --network="host" \
    -it \
    --rm \
    --privileged \
    --workdir="/opt/liosam_ws" \
    --volume="$(pwd)/config/ouster_metadata_8_2_2021.json:/opt/ouster_metadata.json" \
    --volume="$(pwd)/config/params.yaml:/opt/liosam_ws/src/LIO-SAM/config/params.yaml" \
    --volume="$(pwd)/launch/run.launch:/opt/liosam_ws/src/LIO-SAM/launch/run.launch" \
    liosam:latest
