#!/sbin/openrc-run

depend() {
    after net network-online logger docker
    provide buildkite-agent
}

start() {
    BUILDKITE_DIR=/home/buildkite/.buildkite-agent

    chown -hR buildkite:buildkite $BUILDKITE_DIR

    nohup sudo --user buildkite $BUILDKITE_DIR/bin/buildkite-agent start 2>&1 >> /var/log/buildkite-agent.log &
    sleep 1
    echo $! > /var/run/buildkite-agent.pid

    # check if processes running
    sleep 1
    kill -0 $(cat /var/run/buildkite-agent.pid) &> /dev/null
    if [ $? -ne 0 ]; then
        echo "failed to start buildkite agents"
        cat /var/log/buildkite.log
        exit 1
    fi
}

stop () {
    kill -15 $(cat /var/run/buildkite-agent.pid)

    for i in {1..600}
    do
        kill -0 $(cat /var/run/buildkite-agent.pid) &> /dev/null
        if [ $? -eq 0 ]; then
            break
        fi
        echo "Waiting for the process to finish"
        sleep 1
    done
    kill -9 $(cat /var/run/buildkite-agent.pid)
    rm /var/run/buildkite-agent.pid

    exit 0
}