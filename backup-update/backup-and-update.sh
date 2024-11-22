#!/bin/bash

# Function to run command with KDE authentication
run_with_auth() {
    if [ -x "$(command -v kdesu)" ]; then
        kdesu -c "$1"
    elif [ -x "$(command -v pkexec)" ]; then
        pkexec "$@"
    else
        echo "No authentication method available"
        notify "Authentication Error" "No KDE authentication method found" dialog-error
        exit 1
    fi
}

notify() {
    # -h used to set a hint for the application, this will make the notification stay in the system tray widget
    notify-send "$1" "$2" -i $3 -h "string:desktop-entry:org.kde.plasmashell" -a "Software update"

    # this will not keep the notification in system tray widget
    #notify-send "$1" "$2" -i $3 -a "Software update"
}

# Check for available updates using pamac
if ! pamac checkupdates -a | grep -v "Your system is up to date" | grep -q .; then
    # Send notification if system is up to date
    notify "Sytem is up to date" "No pending updates found" system-software-update

    echo "No updates available."
    exit 0
fi


echo "Updates are available. Creating system backup..."

# Create temporary script for authenticated operations
TEMP_SCRIPT=$(mktemp)
chmod +x "$TEMP_SCRIPT"

cat > "$TEMP_SCRIPT" << 'EOF'
#!/bin/bash
if ! timeshift --create --comments "Before system updates"; then
    exit 1
fi

if ! pamac upgrade -a; then
    exit 10
fi
EOF

# Run the temporary script with authentication
if ! run_with_auth "$TEMP_SCRIPT"; then
    # Check exit code to determine failure reason
    case $? in
        1)  # timeshift failure
            notify "Backup failed" "Could not create system backup. Software update aborted" dialog-error
            ;;
        10) # pamac upgrade failure
            notify "Update failed" "Could not install system updates" dialog-error
            ;;
        *)  # other unknown error
            notify "Error" "Unknown error during update process" dialog-error
            ;;
    esac

    # Clean up temporary script
    rm -f "$TEMP_SCRIPT"
    exit 1
fi

# Clean up temporary script
rm -f "$TEMP_SCRIPT"

# Success notification
notify "Update completed" "Updates installed successfully" system-software-update
echo "Updates installed successfully."
