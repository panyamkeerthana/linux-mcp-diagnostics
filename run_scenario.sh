#!/bin/bash

# Script to run goose troubleshooting for specific scenarios
# Command: ./run_scenario.sh <scenario-number> <vm-ip-address>

set -e

SCENARIO="$1"
VM_IP="$2"

if [ -z "$SCENARIO" ]; then
    echo "Error: No scenario number provided"
    exit 1
fi

if [ -z "$VM_IP" ]; then
    echo "Error: No VM IP address provided"
    exit 1
fi

# Map scenario numbers to directories
case "$SCENARIO" in
    1)
        SCENARIO_DIR="scenarios/01_selinux_port_denial"
        PROMPT="My remote host $VM_IP httpd service failed to start with a control process error. Provide the diagnosis and fix for it."
        ;;
    2)
        SCENARIO_DIR="scenarios/02_ssh_permissions"
        PROMPT="A user named \"testuser\" cannot log in via SSH using public key authentication and receives \"Permission denied\" when connecting to testuser@$VM_IP. Diagnose the root cause and fix the system so secure SSH login works again."
        ;;
    3)
        SCENARIO_DIR="scenarios/03_systemd_oom_limit"
        PROMPT="The chronyd service on $VM_IP is crashing or failing to stay active. Job for chronyd.service failed because of an out-of-memory (OOM) siutation. Provide diagnosis and a fix for this."
        ;;
    4)
        SCENARIO_DIR="scenarios/04_cascading_db_failure"
        PROMPT="The MariaDB service on $VM_IP won't start. I suspect it might be a disk issue, but even after checking that, it still won't stay running. Can you do a full diagnosis and fix all the blockers?"
        ;;
    *)
        echo "Error: Unknown scenario number: $SCENARIO"
        echo "Valid scenarios: 1, 2, 3, 4"
        exit 1
        ;;
esac

echo "=========================================="
echo "Running Scenario $SCENARIO"
echo "VM IP: $VM_IP"
echo "Prompt: $PROMPT"
echo "=========================================="
echo ""

# Create a unique session name for this run
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SESSION_NAME="scenario${SCENARIO}_${VM_IP//./-}_${TIMESTAMP}"

# Run the one-shot goose command with a named session
goose run --text "$PROMPT" --name "$SESSION_NAME"

echo ""
echo "=========================================="
echo "Scenario $SCENARIO completed!"
echo "=========================================="
echo ""

# Ask if user wants to export the chat session
read -p "Do you want to export the goose chat session? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Save export in the scenario directory
    EXPORT_FILE="${SCENARIO_DIR}/${SESSION_NAME}.json"

    echo "Exporting chat session to $EXPORT_FILE"
    goose session export --name "$SESSION_NAME" --format json --output "$EXPORT_FILE"

    echo "Export saved to: $EXPORT_FILE"
    echo ""

    # Ask if user wants to evaluate against the rubric
    read -p "Do you want to evaluate this session against the rubric? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        RUBRIC_FILE="${SCENARIO_DIR}/rubric.yaml"
        RESULTS_FILE="${SCENARIO_DIR}/results_${SESSION_NAME}.yaml"

        if [ ! -f "$RUBRIC_FILE" ]; then
            echo "Error: Rubric file not found at $RUBRIC_FILE"
            echo "Skipping evaluation."
        else
            # Check if GEMINI_API_KEY is set
            if [ -z "$GEMINI_API_KEY" ]; then
                echo "Error: GEMINI_API_KEY environment variable is not set"
                echo "Skipping evaluation."
            else
                echo "Running rubric evaluation..."
                rubric-kit evaluate \
                    --from-chat-session "$EXPORT_FILE" \
                    --rubric-file "$RUBRIC_FILE" \
                    --output-file "$RESULTS_FILE" \
                    --model gemini/gemini-2.5-flash

                echo "Evaluation results: $RESULTS_FILE"
            fi
        fi
    else
        echo "Skipping evaluation."
    fi
else
    echo "Skipping export."
fi
