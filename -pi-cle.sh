#!/bin/zsh

# Prepare path
PROJECT_PATH_BASE=~/_repos/myXcProject
# default postfix - you can hardcode any desired postfix. Empty string "" is okay.
# default postfix used when no postfix provided in arguments.
DEFAULT_POSTFIX="3"
if [[ ! -z "$1" ]] && [[ ! $1 == --* ]]
then
    # Postfix from 1st argument
    POSTFIX="$1"
else
    POSTFIX="${DEFAULT_POSTFIX}"
fi
PROJECT_PATH="${PROJECT_PATH_BASE}${POSTFIX}"
if [[ "$*" == *"--forced-path"* ]];
then
    INDEX=1
    for ARGUMENT
    do
        if [[ $ARGUMENT == "--forced-path" ]]; then
            ARGUMENT_VALUE_INDEX=$((INDEX + 1))
            eval "ARGUMENT_VALUE=\${$ARGUMENT_VALUE_INDEX}"
            if [[ $ARGUMENT_VALUE == --* ]] || [[ $ARGUMENT_VALUE == "" ]] ; then
                echo "⛔️ passed wrong '--forced-path' argument"
                exit 0
            fi
            PROJECT_PATH=$ARGUMENT_VALUE
            break
        fi
        INDEX=$((INDEX + 1))
    done
fi

# HELP
if [[ "$*" =~ "--help" ]]
  then
    echo "Current path 👉 ${PROJECT_PATH}"
    echo "default path is ${PROJECT_PATH_BASE}${DEFAULT_POSTFIX}"
    echo ""
    echo "Main purpose of this script: cleaning and then 'bundler exec pod install'"
    echo "Positional arguments:"
    echo "    1st argument - used as postfix for base path to project."
    echo "        Example:"
    echo "        Assume that 'PROJECT_PATH_BASE=~/_repos/myXcProject' and script launched as"
    echo "        './-pi-cle.sh 2'"
    echo "        so script will will go to dir"
    echo "        '~/_repos/myXcProject2'"
    echo "        and start work there."
    echo "        Postfix is useful when you have several copies of project with different postfix."
    echo "Non-positional arguments:"
    echo "    --help - micro help"
    echo "    --forced-path - if non-empty value provided - then it will be used as path to project."
    echo "        'PROJECT_PATH_BASE' and any postfix will be ignored."
    echo "    --rmpfl - same as '--remove-podfilelock' - forces remove 'Podfile.lock'"
    echo "        if not provided - then 'git checkout Podfile.lock' called"
    echo "    --pdd - same as '--preserve-derived-data' - when provided skips remove of DerivedData"
    echo "    --ccpc - same as '--clean-cocoa-pods-cache' - when provided cleans CocoaPods cache."
    echo "    --clo - same as '--clean-only' - when provided stops after clean (no new terminal, no 'cd', no 'pod install')"
    echo "    --npc - same as '--no-pod-commands' - when provided skips pod's commands (like 'pod install')"
    echo "    --pru - same as '--pod-repo-update' - use 'pod install --repo-update' instead of simple 'pod install'"
    exit 0
fi

# Script starts work
cd ${PROJECT_PATH} || { echo "Wrong path"; exit 0; }
echo "👉 `pwd`"

# Podfile.lock
if [[ "$*" == *"--rmpfl"* ]] || [[ "$*" == *"--remove-podfilelock"* ]];
then
    rm -f Podfile.lock
    echo    "🧹 Podfile.lock             ";                                                echo "✅"
else
    echo -n "♻️  Podfile.lock..          ";                                                git checkout Podfile.lock;
fi

# `Pods` directory
echo -n     "🧹 Pods..                   ";   rm -rf Pods;                                 echo "✅"

# DerivedData
if [[ "$*" == *"--pdd"* ]] || [[ "$*" == *"--preserve-derived-data"* ]];
then
    echo -n "💿 DerivedData preserved    ";                                                echo "⚠️"
else
    echo -n "🧹 DerivedData..            ";  rm -rf ~/Library/Developer/Xcode/DerivedData; echo "✅"
fi

# CocoaPods
if [[ "$*" == *"--ccpc"* ]] || [[ "$*" == *"--clean-cocoa-pods-cache"* ]];
then
    echo -n "🧹 CocoaPods cache..        ";  rm -rf ~/Library/Caches/CocoaPods;            echo "✅"
fi

echo "Clean completed!"
say  "Clean completed"

# Clean only: no new terminal, no 'cd', just stop.
if [[ "$*" == *"--clo"* ]] || [[ "$*" == *"--clean-only"* ]];
then
    echo    "No \"cd\", no \"pod install\" - clean only. Done.";
    say "done"
    exit 0
fi

# Check: is there script parameters conflicts?
if [[ "$*" == *"--pru"* ]] || [[ "$*" == *"--pod-repo-update"* ]];
then
    if [[ "$*" == *"--npc"* ]] || [[ "$*" == *"--no-pod-commands"* ]];
    then
        echo "Error: --pod-repo-update and --no-pod-commands parameters conflict. Exit!";
        say "error"
        exit 0
    fi
fi

# Prepare commands in for new terminal
CD_COMMAND="cd ${PROJECT_PATH}"
if [[ "$*" == *"--npc"* ]] || [[ "$*" == *"--no-pod-commands"* ]];
then
    # No pod's commands after open new terminal
    COMMANDS_FOR_NEW_TERMINAL="${CD_COMMAND}";
else
    # Pod's commands
    POD_COMMAND="pod install"

    # Should use '--repo-update'?
    if [[ "$*" == *"--pru"* ]] || [[ "$*" == *"--pod-repo-update"* ]];
    then
        POD_COMMAND="pod install --repo-update"
    fi

    POD_COMMAND_WITH_DECORATIONS="bundler exec ${POD_COMMAND} && { say 'Good job'; echo '🍀 Good job!'; } || { say 'Welcome to the kingdom of eternal pain'; echo '🥀 Pain!'; }"

    COMMANDS_FOR_NEW_TERMINAL="${CD_COMMAND}\n${POD_COMMAND_WITH_DECORATIONS}";
fi

# Run new terminal and commands
osascript -e 'tell application "Terminal" to activate' \
  -e 'tell application "System Events" to tell process "Terminal" to keystroke "t" using command down' \
  -e "tell application \"Terminal\" to do script \"${COMMANDS_FOR_NEW_TERMINAL}\" in selected tab of the front window"
