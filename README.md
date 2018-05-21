# CamelStudioX_Mac
Integrated Development Environment on Mac For Mips Chips Designed by Camel Micro

## Version 3.2.1
----

### Build 19 on 21.05.2018

- Fix a bug of failing to cancel upload sheet.

## Version 3.2.0
----

### Build 18 on 03.05.2018

- Correct some UI mistakes in Help Window
- New Feature: Drag and drop files in Project Inspector
- New Feature: Auto Update

## Version 3.1.2
----

### Build 16 on 02.05.2018

- Fix a bug of failing to upload binary since the second upload

### Build 17 on 02.05.2018

- Fix a bug of failing to upload binary after serial monitor is opened
- Fix a bug of "Name disappears" in the project inspector
- Now serial monitor and uploader can remember the last selected serial port

## Version 3.1.1
----

### Build 15 on 30.04.2018

- Fix a bug of num2Dec in M2 official library
- Fix a bug of modifying files unexpectedly
- Use new uploader, reduce 70% uploading time ( 20s -> 6s )

## Version 3.1.0
----

### Build 14 on 29.04.2018

- Improve the robutness of processing uploading failure
- Remove debug output

## Version 3.0.3
----

### Build 13 on 08.04.2018

- Add an option in Project Config Panel to use a customed Makefile
- Use a library of markdown compatible to older system version

## Version 3.0.2
----

### Build 12 on 06.04.2018

- Use a new file icon, it does work this time! 
- A new looking for the refresh button.
- Fix bug: Unexpected exit when new project button on welcome window is clicked.

## Version 3.0.1
----

### Build 10 on 05.04.2018

- Fix bug: fail to create directories automatically
- Optimize key equivalent: Use Control(^) as modification of project menus

### Build 11 on 05.04.2018

- WelcomeWindow has round corner now! It looks more beautiful now.
- Close button of welcome window can be hidden or shown automatically when the mouse enters or exits the left part of the window.

## Version 3.0
----

### Build 9 on 05.04.2018

- **Recoding Verion**, the whole framewrok is designed again
- Optimize serial monitor user interface: now you can input data to send in the serial data frame
- **USE NEW FILE TYPE: cmsproj**
- Optimize file management: treat the project directory as a package, all files in the project are managed and auto-saved
- Optimize main window, more space to show files
- Add **Data Analyzer**
- Show Hex is moved to data analyzer

## Version 2.2
----

### Build 8 on 01.04.2018

- Add "Import File" to the menu of side panel
- Automatically generate c file create a new project
- Fix: compiling fail when there is no release directory in project directory

## Version 2.1
----

### Build 7 on 31.03.2018

- Update mips gcc cross compiler toolchains to 7.3.0, with a smaller size than 7.1.0
- Build with Swift 4.1

## Version 2.0
----

### Build 6 on 29.03.2018

- Add code highlight, thanks to [raspu](https://github.com/raspu/Highlightr)
- Add preference

## Version 1.2
----

### Build 5 on 28.03.2018

- Fix a bug of parsing cms file: fail to build when LIBRARY or CUSTOM_LIBRARY is empty
- **Add Data Analyzer in Serial Monitor**, thanks to [alejandro-isaza](https://github.com/alejandro-isaza/PlotKit)
- Optimize url operation
- **Optimize project creation: create a project directory and then save the project file**

## Version 1.1
----

### Build 4 on 26.03.2018

- Change the logic of saving files
    - Using "Command + S" or the button in the toolbar to save the current file
    - Using "Command + Shit + S" to save the project configuration file
- Replace the line number scheme with LineNumberTextView.framework, thanks to [raphaelhanneken](https://github.com/raphaelhanneken)
    - Now the line number display normally when scrolling back the content in the editing area
- Introduce Markdown to What is new Window to make it easier to read, thanks to [crossroadlabs](https://crossroadlabs.xyz)
- Fix some translation mistakes

## Version 1.0.1
----

### Build 3 on 25.03.2018

- Change the text color when a file in side panel is selected or unselected
- Add Official Library header files viewer as CamelStudioX Helpq

##  Version 1.0.0
----

### Build 1 on 23.03.2018

- A new gui compared with CamelStudio
- Intagrate toolchains embeded
- Intagrate driver installer for CH340 and PL2303

### Build 2 on 24.03.2018

- Fix the bug that CamelStudioX crashs when Upload to board is clicked without project opened
- Fix the bug that CamelStudioX fails to upload binary due to too short wating time
- Add What is new MenuItem


