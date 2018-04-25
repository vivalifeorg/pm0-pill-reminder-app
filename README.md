# Build Directions

Install Xcode 9.3 (Which requires High Sierra). Build the main project. That is all you need to do. 

Reproducable builds are essential in iOS developement.

# Other tools

No other tools are required to build. Fastlane and cocoapods are required for
longterm development use, as is Sourcery.

# Pod files

The pods are intentionally checked into the repo to prevent the "dissapearing vendor"
problem. The phaxio pod is currently copied from their repo into the app as a
development pod with several modifications. Pod install will not overwrite this. 

When you do a pod install, a few extra files from the "Down" dependency will be
installed. 

# Version Numbers

The main version number (0.1, etc) is updated by humans. Be careful how it is
advanced as you cannot go backwards easily. The other part of the version number
is done automatically based off the date to make TestFlight work well. 

# Help files

There are several pieces of markdown text in which the in-app help is written.
That's not yet been exported to markdown files yet, but the text is mostly in 
pm0/Medications/RxAddEdit/RXEntryHelpText.swift

# Art files 

The art files for the app are mostly checked into the Art repo, not this one.
The actual files used in the app are also copied into this repo, as used in the app. These can
easily be adapted into android versions. The iOS app uses many PDF icons.

# Generated Files

There are some files generated on every build

# Database files 

The database files are generated from the database project and copied into the
app. See the project build scripts in the run script phase for more. 

# Navigation overview

This is currently being completed, but is not yet finished. 

# App Name

Please do not reanme the "App" from "pm0" internal to the project. That does
great violence to the internal structure of the project files. Chaning the text
under the icon is fine.
