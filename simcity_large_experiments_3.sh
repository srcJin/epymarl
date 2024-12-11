#!/bin/bash

# All simcity_large commands
commands=(
    "python src/main.py --config=qmix --env-config=simcity_large"
    "python src/main.py --config=qmix_ns --env-config=simcity_large"
    "python src/main.py --config=vdn --env-config=simcity_large"
    "python src/main.py --config=vdn_ns --env-config=simcity_large"
    "python src/main.py --config=ippo --env-config=simcity_large"
    "python src/main.py --config=ippo_ns --env-config=simcity_large"
    "python src/main.py --config=maddpg --env-config=simcity_large"
    "python src/main.py --config=maddpg_ns --env-config=simcity_large"
)

running_jobs=()
num_parallel=8

# Function to clean up completed jobs
cleanup_jobs() {
    for i in "${!running_jobs[@]}"; do
        if ! kill -0 "${running_jobs[$i]}" 2>/dev/null; then
            unset 'running_jobs[i]' # Remove completed process
        fi
    done
    running_jobs=("${running_jobs[@]}") # Re-index array
}

# Run commands in parallel
for cmd in "${commands[@]}"; do
    # Wait for available slots
    while [ "${#running_jobs[@]}" -ge "$num_parallel" ]; do
        cleanup_jobs
        sleep 1
    done

    # Run the command in a new terminal
    echo "Running: $cmd"
    xterm -hold -e "$cmd" &
    job_pid=$!

    # Check if the PID is valid
    if [[ "$job_pid" =~ ^[0-9]+$ ]]; then
        running_jobs+=("$job_pid") # Track the process ID
    else
        echo "Failed to start job: $cmd"
    fi
done

# Wait for all remaining jobs to finish
wait
echo "All experiments completed."