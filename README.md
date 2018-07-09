# CamelStudioX_Mac
Integrated Development Environment on Mac For Mips Chips Designed by Camel Micro

## [Download the Latest Version from GitHub](https://github.com/daizhirui/CamelStudioX_Mac/releases/latest)

## [Download the Latest Version from HockeyApp](https://rink.hockeyapp.net/apps/798a2dae49b04400bcadaf69bda80417)

## [Documentation](https://daizhirui.github.io/CamelStudio_Library/)

### Version 3.7.0
----

#### Build 39 on 09.07.2018

- Fixed Bug: Fail to detect some linker error.

### Version 3.6.6
----

#### Build 38 on 25.06.2018

- Fixed Bug: Fail to open example second time.

### Version 3.6.5
----

#### Build 37 on 24.06.2018

- Improvement
    - Auto copy example files to user's project folder.
- New Features
    - Auto detect timezone to determine which server for update to use.
    - Select update server manually in Preference.

### Version 3.6.4
----

#### Build 36 on 23.06.2018

- Improvement: Speed up preparation before uploading.
- Fixed Bug: Crash when users try to setup serial port in the More Config Sheet in Serial Monitor.

### Version 3.6.3
----

#### Build 35 on 22.06.2018

- Fix: UI error of Welcome Window on MacBook Air.

### Version 3.6.2
----

#### Build 34 on 22.06.2018

- Improvement: UI adjustment of Welcome Window for old mac machines.
- Fix: Possible crash when checking update with a project opened.

### Version 3.6.1
----

#### Build 33 on 21.06.2018

- New Feature: Open Example button in Welcome Window.
- Improvement: UI adjustment of Welcome Window for old mac machines.

### Version 3.6.0
----

#### Build 32 on 20.06.2018

- New Feature: Online technical support, you can get support now just by opening Feedback window.
- New Feature: Feedback is now available in Help Menu.
- New Feature: Crash report auto collector.
- New Feature: Register Products.
- Improvement: Update examples.

### Version 3.5.2
----

#### Build 31 on 16.06.2018

- Improvement: Auto insert 4 spaces as a tab.
- Update library and documentation.

### Version 3.5.1
----

#### Build 30 on 13.06.2018

- Fix: A compromise to save root program out of the bug of bootloader.
- Fix: Program cannot run when there is no bss section.

### Version 3.5.0
----

#### Build 29 on 13.06.2018

- Fix: Global variables are not initialized properly.
- Fix: Fail to show compiler error / warning messages.

### Version 3.4.4
----

#### Build 28 on 04.06.2018

- Fix: Possible crash when users start the second uploading after the open of Serial Monitor.
- Fix: A bug in ORSSerialPort library: Try to invoke "didReceiveData" function when serial port is closed.
- Improvement: Serial Monitor don't need closing now when users start the uploading.

### Version 3.4.3
----

#### Build 27 on 04.06.2018

- Fix: Some UI constraint errors.
- Improvement: Warnings of using soft float library won't be shown.
- Improvement: soft float library supports double more and stdio_fp library supports 5 fractional digits now.

### Version 3.4.2
----

#### Build 26 on 01.06.2018

- Fix: refues to upload when just some warnings appear during compiling.
- Fix: printf cannot print float variable.
- Improvement: Serial Monitor doesn't affect uploading now.
- Improvement: Soft float library supports double now! This library is renamed to soft_fp.
- New Feature: Detect serial drivers.

### Version 3.4.1
----

#### Build 25 on 31.05.2018

- Fix: crash sometimes when building binary.
- Fix: build binary when the uploading is cancelled.
- Fix: bugs in official library.

### Version 3.4.0
----

#### Build 24 on 27.05.2018

- Improvement: Stabler Uploader.
- New Feature: Official Documentation
- New Feature: Auto-build binary before uploading (It can be canceled in Preference.)
- New Feature: New library! Now some standard C functions like printf is ready!

### Version 3.3.2
----

#### Build 23 on 24.05.2018

- Improvement: Global "Serial Port Connected/DIsconnected" Notification.
- New Feature: Float Point Library Support.
- New Feature: New compiler message window.
- New Feature: Remember the serial port last time when CamelStudioX is opened and connected to a serial port.

### Version 3.3.1
----

#### Build 22 on 22.05.2018

- Fix some mistakes in auto punctuation pair.

### Version 3.3.0
----

#### Build 21 on 22.05.2018

- Fix a bug of wrong undo action.
- New Feature: Auto recognize the folder to add the new file or the new folder.

### Version 3.2.2
----

#### Build 20 on 21.05.2018

- Fix a bug of showing wrong menus for the first item in Project Inspector.
- Fix a bug of no response of rename menu item in Project Inspector.
- New Feature: Auto insert tab and auto insert brace, parenthesis and quotation mark.

### Version 3.2.1
----

#### Build 19 on 21.05.2018

- Fix a bug of failing to cancel upload sheet.

### Version 3.2.0
----

#### Build 18 on 03.05.2018

- Correct some UI mistakes in Help Window
- New Feature: Drag and drop files in Project Inspector
- New Feature: Auto Update

### Version 3.1.2
----

#### Build 16 on 02.05.2018

- Fix a bug of failing to upload binary since the second upload

#### Build 17 on 02.05.2018

- Fix a bug of failing to upload binary after serial monitor is opened
- Fix a bug of "Name disappears" in the project inspector
- Now serial monitor and uploader can remember the last selected serial port

### Version 3.1.1
----

#### Build 15 on 30.04.2018

- Fix a bug of num2Dec in M2 official library
- Fix a bug of modifying files unexpectedly
- Use new uploader, reduce 70% uploading time ( 20s -> 6s )

### Version 3.1.0
----

#### Build 14 on 29.04.2018

- Improve the robutness of processing uploading failure
- Remove debug output

### Version 3.0.3
----

#### Build 13 on 08.04.2018

- Add an option in Project Config Panel to use a customed Makefile
- Use a library of markdown compatible to older system version

### Version 3.0.2
----

#### Build 12 on 06.04.2018

- Use a new file icon, it does work this time! 
- A new looking for the refresh button.
- Fix bug: Unexpected exit when new project button on welcome window is clicked.

### Version 3.0.1
----

#### Build 10 on 05.04.2018

- Fix bug: fail to create directories automatically
- Optimize key equivalent: Use Control(^) as modification of project menus

#### Build 11 on 05.04.2018

- WelcomeWindow has round corner now! It looks more beautiful now.
- Close button of welcome window can be hidden or shown automatically when the mouse enters or exits the left part of the window.

### Version 3.0
----

#### Build 9 on 05.04.2018

- **Recoding Verion**, the whole framewrok is designed again
- Optimize serial monitor user interface: now you can input data to send in the serial data frame
- **USE NEW FILE TYPE: cmsproj**
- Optimize file management: treat the project directory as a package, all files in the project are managed and auto-saved
- Optimize main window, more space to show files
- Add **Data Analyzer**
- Show Hex is moved to data analyzer

### Version 2.2
----

#### Build 8 on 01.04.2018

- Add "Import File" to the menu of side panel
- Automatically generate c file create a new project
- Fix: compiling fail when there is no release directory in project directory

### Version 2.1
----

#### Build 7 on 31.03.2018

- Update mips gcc cross compiler toolchains to 7.3.0, with a smaller size than 7.1.0
- Build with Swift 4.1

### Version 2.0
----

#### Build 6 on 29.03.2018

- Add code highlight, thanks to [raspu](https://github.com/raspu/Highlightr)
- Add preference

### Version 1.2
----

#### Build 5 on 28.03.2018

- Fix a bug of parsing cms file: fail to build when LIBRARY or CUSTOM_LIBRARY is empty
- **Add Data Analyzer in Serial Monitor**, thanks to [alejandro-isaza](https://github.com/alejandro-isaza/PlotKit)
- Optimize url operation
- **Optimize project creation: create a project directory and then save the project file**

### Version 1.1
----

#### Build 4 on 26.03.2018

- Change the logic of saving files
    - Using "Command + S" or the button in the toolbar to save the current file
    - Using "Command + Shit + S" to save the project configuration file
- Replace the line number scheme with LineNumberTextView.framework, thanks to [raphaelhanneken](https://github.com/raphaelhanneken)
    - Now the line number display normally when scrolling back the content in the editing area
- Introduce Markdown to What is new Window to make it easier to read, thanks to [crossroadlabs](https://crossroadlabs.xyz)
- Fix some translation mistakes

### Version 1.0.1
----

#### Build 3 on 25.03.2018

- Change the text color when a file in side panel is selected or unselected
- Add Official Library header files viewer as CamelStudioX Helpq

###  Version 1.0.0
----

#### Build 1 on 23.03.2018

- A new gui compared with CamelStudio
- Intagrate toolchains embeded
- Intagrate driver installer for CH340 and PL2303

#### Build 2 on 24.03.2018

- Fix the bug that CamelStudioX crashs when Upload to board is clicked without project opened
- Fix the bug that CamelStudioX fails to upload binary due to too short wating time
- Add What is new MenuItem


