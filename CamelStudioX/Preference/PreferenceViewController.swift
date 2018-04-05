//
//  preferenceViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/3/28.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa
import Highlightr

class PreferenceViewController: NSViewController {

    @IBOutlet weak var codeThemeBox: NSComboBox!
    var mainVC: DocumentViewController!
    
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
        }
    }
    
    @IBAction func okAction(_ sender: Any) {
        self.applyAction(sender)
        self.view.window?.close()
    }
    
    @IBAction func applyAction(_ sender: Any) {
        let theme = self.codeThemeBox.stringValue
        if let vc = self.mainVC {
            vc.hignlightr.setTheme(to: theme)
            vc.setFileTextViewColor()
            // save setup to Preference.plist
            if let path = Bundle.main.path(forResource: "Preference", ofType: "plist") {
                if let resourceFileDictionary = NSMutableDictionary(contentsOfFile: path) {
                    resourceFileDictionary["CodeTheme"] = theme
                    resourceFileDictionary.write(toFile: path, atomically: true)
                }
            }
        }
    }
    /// cancel setup
    @IBAction func cancelAction(_ sender: Any) {
        self.view.window?.close()
    }
}
