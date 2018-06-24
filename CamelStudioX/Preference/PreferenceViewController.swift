//
//  preferenceViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/3/28.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa
import Highlightr
import Sparkle

class PreferenceViewController: NSViewController {

    @IBOutlet weak var codeThemeBox: NSComboBox!
    var mainVC: DocumentViewController!
    @IBOutlet weak var autoBuild: NSButton!
    @IBOutlet weak var autoUpdate: NSButton!
    @IBOutlet weak var autoDownload: NSButton!
    @IBOutlet weak var updateCheckInterval: NSPopUpButton!
    @IBOutlet weak var updateServer: NSPopUpButton!
    let updater = AppDelegate.shared.updater
    
    let themes: [String] = {
        let themesString =
        """
        agate
        androidstudio
        arduino-light
        arta
        atelier-cave-dark
        atelier-cave-light
        atelier-dune-dark
        atelier-dune-light
        atelier-estuary-dark
        atelier-estuary-light
        atelier-forest-dark
        atelier-forest-light
        atelier-heath-dark
        atelier-heath-light
        atelier-lakeside-dark
        atelier-lakeside-light
        atelier-plateau-dark
        atelier-plateau-light
        atelier-savanna-light
        atelier-seaside-dark
        atelier-seaside-light
        atelier-sulphurpool-dark
        atelier-sulphurpool-light
        atom-one-dark
        atom-one-light
        codepen-embed
        color-brewer
        dark
        default
        docco
        dracula
        far
        foundation
        github
        grayscale
        gruvbox-dark
        gruvbox-light
        hopscotch
        idea
        ir-black
        kimbie.dark
        kimbie.light
        magula
        monokai
        monokai-sublime
        ocean
        paraiso-dark
        paraiso-light
        pojoaque
        atelier-savanna-dark
        purebasic
        qtcreator_dark
        qtcreator_light
        railscasts
        rainbow
        routeros
        solarized-dark
        solarized-light
        sunburst
        tomorrow-night
        tomorrow-night-blue
        tomorrow-night-eighties
        vs2015
        xcode
        xt256
        zenburn
        """
        /*"""
        arduino-light
        atom-one-light
        dark
        github
        tomorrow-night-blue
        tomorrow-night-eighties
        vs2015
        xcode
        xt256
        zenburn
        """*/
        return themesString.components(separatedBy: .newlines)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadSetup()
    }
    /**
     Load preference stored in Preference.plist
    */
    func loadSetup() {
        // prepare codeThemeBox
        self.codeThemeBox.removeAllItems()
        self.codeThemeBox.addItems(withObjectValues: themes)
        /*
        // load setup from Preference.plist
        if let path = Bundle.main.path(forResource: "Preference", ofType: "plist") {
            let resourceFileDictionary = NSMutableDictionary(contentsOfFile: path)
            // load codeTheme
            if let themeName = resourceFileDictionary?.object(forKey: "CodeTheme") as? String {
                for index in ( 0..<self.themes.count ) {
                    if self.themes[index] == themeName {
                        self.codeThemeBox.selectItem(at: index)
                    }
                }
            }
        }*/
        let defaults = UserDefaults.standard
        let themeName: String
        if let temp = defaults.string(forKey: "CodeTheme") {
            themeName = temp
        } else {
            themeName = "xcode"
        }
        for index in ( 0..<self.themes.count ) {
            if self.themes[index] == themeName {
                self.codeThemeBox.selectItem(at: index)
            }
        }
        if let state = defaults.value(forKey: "AutoBuild") as? NSControl.StateValue {
            self.autoBuild.state = state
        } else {
            self.autoBuild.state = .on
            defaults.set(NSControl.StateValue.on as Any, forKey: "AutoBuild")
        }
        if let state = defaults.value(forKey: "AutoUpdate") as? NSControl.StateValue {
            self.autoUpdate.state = state
        } else {
            self.autoUpdate.state = .on
            defaults.set(NSControl.StateValue.on as Any, forKey: "AutoUpdate")
        }
        if let state = defaults.value(forKey: "AutoDownload") as? NSControl.StateValue {
            self.autoUpdate.state = state
        } else {
            self.autoUpdate.state = .on
            defaults.set(NSControl.StateValue.on as Any, forKey: "AutoDownload")
        }
        if let tag = defaults.value(forKey: "UpdateCheckInterval") as? Int {
            self.updateCheckInterval.selectItem(withTag: tag)
        } else {
            self.updateCheckInterval.selectItem(withTag: 86400)
            defaults.set(self.updateCheckInterval.selectedTag() as Any, forKey: "UpdateCheckInterval")
        }
        if let location = defaults.object(forKey: "ServerLocation") as? String {
            self.updateServer.selectItem(withTitle: location)
        } else {
            if TimeZone.current.secondsFromGMT() / 3600 == 8 {
                self.updateServer.selectItem(withTitle: "China")
            } else {
                self.updateServer.selectItem(withTitle: "International")
            }
        }
    }
    
    @IBAction func okAction(_ sender: Any) {
        self.applyAction(sender)
        self.view.window?.close()
    }
    
    @IBAction func applyAction(_ sender: Any) {
        let theme = self.codeThemeBox.stringValue
        // save setup to Preference.plist
        let defaults = UserDefaults.standard
        defaults.set(theme, forKey: "CodeTheme")
        defaults.set(self.autoBuild.state as Any, forKey: "AutoBuild")
        
        defaults.set(self.autoUpdate.state as Any, forKey: "AutoUpdate")
        self.updater?.automaticallyChecksForUpdates = (self.autoUpdate.state == .on)
        
        defaults.set(self.autoDownload.state as Any, forKey: "AutoDownload")
        self.updater?.automaticallyDownloadsUpdates = (self.autoDownload.state == .on)
        
        defaults.set(self.updateCheckInterval.selectedTag() as Any, forKey: "UpdateCheckInterval")
        self.updater?.updateCheckInterval = TimeInterval(self.updateCheckInterval.selectedTag())
        
        defaults.set(self.updateServer.selectedItem!.title, forKey: "ServerLocation")
        if self.updateServer.selectedItem?.title == "China" {
            self.updater?.updateFeedURL(URL(string: "https://camelmicro.oss-cn-beijing.aliyuncs.com/appcast.xml"))
        } else {
            self.updater?.updateFeedURL(URL(string: "https://raw.githubusercontent.com/daizhirui/CamelStudioX_Mac/master/appcast.xml"))
        }
        
        // update editor
        for window in NSApp.windows {
            if let vc = window.contentViewController as? DocumentViewController {
                vc.hignlightr.setTheme(to: theme)
                vc.setFileTextViewColor()
            }
        }
    }
    /// cancel setup
    @IBAction func cancelAction(_ sender: Any) {
        self.view.window?.close()
    }
}
