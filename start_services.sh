#!/bin/bash

# Array of Ruby programs and their corresponding PID files
declare -A RUBY_SERVICES=(
    [service1]="/path/to/service1.rb:/path/to/pid1.pid"
    [service2]="/path/to/service2.rb:/path/to/pid2.pid"
    [service3]="/path/to/service3.rb:/path/to/pid3.pid"
)

# Function to start a Ruby service as a daemon
start_service() {
    local service_name=$1
    local program_pid=${RUBY_SERVICES[$service_name]#*:}
    local program_path=${RUBY_SERVICES[$service_name]%:*}

    if [ -f "$program_pid" ]; then
        echo "The $service_name service is already running (PID: $(cat $program_pid))"
        return 1
    fi

    echo "Starting the $service_name service..."
    ruby "$program_path" &
    PID=$!
    echo $PID > "$program_pid"
    echo "$service_name service started with PID: $PID"
}

# Function to stop a running Ruby service
stop_service() {
    local service_name=$1
    local program_pid=${RUBY_SERVICES[$service_name]#*:}

    if [ ! -f "$program_pid" ]; then
        echo "The $service_name service is not running"
        return 1
    fi

    PID=$(cat "$program_pid")
    echo "Stopping the $service_name service with PID: $PID..."
    kill $PID
    rm "$program_pid"
    echo "$service_name service stopped"
}

# Function to check the status of a Ruby service
status_service() {
    local service_name=$1
    local program_pid=${RUBY_SERVICES[$service_name]#*:}

    if [ -f "$program_pid" ]; then
        PID=$(cat "$program_pid")
        echo "The $service_name service is running with PID: $PID"
    else
        echo "The $service_name service is not running"
    fi
}

# Main script logic
case "$1" in
    start)
        shift
        if [ "$1" = "all" ]; then
            for service_name in "${!RUBY_SERVICES[@]}"; do
                start_service "$service_name"
            done
        else
            for service_name in "$@"; do
                if [ -n "${RUBY_SERVICES[$service_name]}" ]; then
                    start_service "$service_name"
                else
                    echo "Invalid service: $service_name"
                fi
            done
        fi
        ;;
    stop)
        shift
        if [ "$1" = "all" ]; then
            for service_name in "${!RUBY_SERVICES[@]}"; do
                stop_service "$service_name"
            done
        else
            for service_name in "$@"; do
                if [ -n "${RUBY_SERVICES[$service_name]}" ]; then
                    stop_service "$service_name"
                else
                    echo "Invalid service: $service_name"
                fi
            done
        fi
        ;;
    restart)
        shift
        if [ "$1" = "all" ]; then
            for service_name in "${!RUBY_SERVICES[@]}"; do
                stop_service "$service_name"
                start_service "$service_name"
            done
        else
            for service_name in "$@"; do
                if [ -n "${RUBY_SERVICES[$service_name]}" ]; then
                    stop_service "$service_name"
                    start_service "$service_name"
                else
                    echo "Invalid service: $service_name"
                fi
            done
        fi
        ;;
    status)
        shift
        if [ $# -eq 0 ]; then
            for service_name in "${!RUBY_SERVICES[@]}"; do
                status_service "$service_name"
            done
        else
            for service_name in "$@"; do
                if [ -n "${RUBY_SERVICES[$service_name]}" ]; then
                    status_service "$service_name"
                else
                    echo "Invalid service: $service_name"
                fi
            done
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status} [service1 service2 ... | all]"
        exit 1
esac

exit 0
