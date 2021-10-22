#!/bin/bash
#A script to find which juce modules you need to include for a given JUCE class you are using.

#CONFIG -- Replace JUCE_MODULES_PATH with the file path to your JUCE modules directory.
JUCE_MODULES_PATH="$(dirname $0)/../../JUCE/modules"

#NOTE: This may not work for all classes. I have not tried them all.

USAGE_MSG="usage: $0 classname1 [classname2 ...]"
NOT_FOUND_MSG="NOT_FOUND"

if [ $# -le 0 ] 
then
    echo $USAGE_MSG
else
    for CLASS_NAME in "$@"
    do
        #TODO: make these grep commands actually find FOUND_LINE for all classes

        #FOUND_CLASS stores the first line found that has the desired class name in it. 
        FOUND_LINE=$(grep -R $CLASS_NAME $JUCE_MODULES_PATH | grep "juce_"$CLASS_NAME | head -n 1)
        #HACK: this is a bit of a hack. if there is no juce_CLASSNAME, we just look for the CLASSNAME. We do this because some class names are prefixed with "juce_", and some are not.
        if [ -z "$FOUND_LINE" ]
        then
            FOUND_LINE=$(grep -R $CLASS_NAME $JUCE_MODULES_PATH | grep $CLASS_NAME | head -n 1)
        fi
        #This PERL command parses the line for something like '/MODULE_NAME/CLASS_NAME' or '"MODULE_NAME"/CLASS_NAME'),
        #and extracts the module name
        PERL_COMMAND='s|.*JUCE\/modules\/(.+?)\/.+(juce_)?'
        PERL_COMMAND+=$CLASS_NAME
        PERL_COMMAND+='.*|\1|'

        MODULE=$(echo $FOUND_LINE | perl -pe $PERL_COMMAND)

        if [ -z "$MODULE" ]
        then
            MODULE=$NOT_FOUND_MSG
        fi

        echo $CLASS_NAME "is in module:" $MODULE

    done
fi
