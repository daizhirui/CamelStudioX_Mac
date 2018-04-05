//
//  DataAnalyzerViewController.swift
//  CamelStudioX
//
//  Created by 戴植锐 on 2018/4/3.
//  Copyright © 2018年 戴植锐. All rights reserved.
//

import Cocoa
import LineNumberTextView
import PlotKit

class DataAnalyzerViewController: NSViewController {

    @IBOutlet var dataTextView: LineNumberTextView!
    @IBOutlet var hexResultTextView: LineNumberTextView!
    @IBOutlet weak var beginLineTextField: NSTextField!
    @IBOutlet weak var prefixTextField: NSTextField!
    @IBOutlet weak var suffixTextField: NSTextField!
    @IBOutlet weak var separatorPopButton: NSPopUpButton!
    @IBOutlet weak var hexToDecButton: NSButton!
    @IBOutlet weak var dataTableView: NSTableView!
    @IBOutlet weak var dataPlotView: PlotView!
    @IBOutlet weak var headerNameTextField: NSTextField!
    @IBOutlet weak var setButton: NSButton!
    @IBOutlet weak var plotXComboBox: NSComboBox!
    @IBOutlet weak var plotYComboBox: NSComboBox!
    @IBOutlet weak var plotButton: NSButton!
    /// For dataTableView
    var datas = [[String : Double]]()
    /// For dataPlotView
    var datasToDraw = [String : [Double]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataTextView.gutterBackgroundColor = NSColor.white
        self.dataTextView.gutterForegroundColor = NSColor.gray
        self.hexResultTextView.gutterForegroundColor = NSColor.gray
        self.hexResultTextView.gutterBackgroundColor = NSColor.white
    }
    
    override func viewWillAppear() {
        self.setupHexResultTextView()
    }
    
    func setupHexResultTextView() {
        let hexString = self.dataTextView.string.toHex()
        print("hexString")
        self.hexResultTextView.string = hexString
    }
    
    @IBAction func analyzeAction(_ sender: Any) {
        var beginLine = 1
        if let value = Int(self.beginLineTextField.stringValue) {
            beginLine = value
        }
        var maxColumn = 0
        var hexToDec: Bool = true
        var headerNames = [String]()
        switch self.hexToDecButton.state {
        case .on:
            hexToDec = true
        case .off:
            hexToDec = false
        default:
            hexToDec = false
        }
        let lines = self.dataTextView.string.components(separatedBy: CharacterSet.newlines)
        if let separatorName = self.separatorPopButton.selectedItem?.title, separatorName.count > 0 {
            let separator: String
            if separatorName == "Tab" {
                separator = "\t"
            } else if separatorName == "Space" {
                separator = " "
            } else {
                return
            }
            self.datas.removeAll()
            var row = 0
            for line in lines {
                if beginLine > 1 {
                    beginLine -= 1
                    continue
                }
                if line.count <= 0 {
                    continue
                }
                self.datas.append([String : Double]())
                let items = line.components(separatedBy: CharacterSet(charactersIn: separator))
                
                var column = 0
                for item in items {
                    var finalString: String = item
                    // remove prefix and suffix
                    let prefix = self.prefixTextField.stringValue
                    let suffix = self.suffixTextField.stringValue
                    if item.hasPrefix(prefix) {
                        finalString.removeFirst(prefix.count)
                    }
                    if item.hasSuffix(suffix) {
                        finalString.removeLast(suffix.count)
                    }
                    // convert to double
                    self.datas[row]["\(column)"] = finalString.toDouble(isHex: hexToDec) ?? 0.0
                    // next column
                    column += 1
                }
                if column >= maxColumn {
                    maxColumn = column
                } else {
                    for index in ( column..<maxColumn ) {
                        self.datas[row]["\(index)"] = 0
                    }
                }
                row += 1
            }
            // empty table
            for column in self.dataTableView.tableColumns {
                self.dataTableView.removeTableColumn(column)
            }
            // add column
            for _ in ( 0..<maxColumn ) {
                self.dataTableView.addTableColumn(NSTableColumn())
            }
            // set column width and title
            let columnWidth = self.dataTableView.bounds.width / CGFloat(self.dataTableView.numberOfColumns)
            var tag = 0
            for column in self.dataTableView.tableColumns {
                column.identifier = NSUserInterfaceItemIdentifier(rawValue: "\(tag)")
                column.width = columnWidth
                tag += 1
                column.title = "Column\(tag)"
                headerNames.append(column.title)
            }
            self.dataTableView.reloadData()
            self.setButton.isEnabled = true
            self.headerNameTextField.stringValue = headerNames.joined(separator: ",")
        }
    }
    
    @IBAction func setHeaderAction(_ sender: Any) {
        let headerNames = self.headerNameTextField.stringValue.components(separatedBy: ",")
        var tag = 0
        for column in self.dataTableView.tableColumns {
            if tag < headerNames.count {
                column.title = headerNames[tag]
            } else {
                column.title = "Untitled"
            }
            tag += 1
        }
        self.dataTableView.needsDisplay = true
        self.dataTableView.headerView?.needsDisplay = true
    }
    
    @IBAction func plotAction(_ sender: Any) {
        if let x = self.datasToDraw[self.plotXComboBox.stringValue], let y = self.datasToDraw[self.plotYComboBox.stringValue], x.count > 0, y.count > 0 {
            self.dataPlotView.removeAllPlots()
            self.dataPlotView.removeAllAxes()
            // create and add axis
            let font = NSFont(name: "Optima", size: 12)!
            // xAxis
            var distance = 0.0
            var length = x.max()! - x.min()!
            if length > 10 {
                distance = length / 20
            } else {
                distance = 0.5
            }
            var xAxis = Axis(orientation: .horizontal, ticks: .distance(distance))
            xAxis.position = .value(y.min()!)
            xAxis.labelAttributes = [NSAttributedStringKey.font: font]
            self.dataPlotView.addAxis(xAxis)
            // yAxis
            length = y.max()! - y.min()!
            if length > 10 {
                distance = length / 20
            } else {
                distance = 0.5
            }
            var yAxis = Axis(orientation: .vertical, ticks: .distance(distance))
            //var yAxis = Axis(orientation: .vertical, ticks: .list(yTicks))
            yAxis.position = .value(x.min()!)
            yAxis.labelAttributes = [NSAttributedStringKey.font: font]
            self.dataPlotView.addAxis(yAxis)
            // points
            let pointSet = PointSet(points: (0..<x.count).map{ Point(x: x[$0], y: y[$0]) })
            self.dataPlotView.addPointSet(pointSet, title: "\(self.plotYComboBox.stringValue) - \(self.plotXComboBox.stringValue)")
        }
    }
}

// ******** For Data Convert ***********
extension String {
    func toDouble(isHex: Bool) -> Double? {
        if isHex {
            return Double.init("0X"+self)
        } else {
            return Double.init(self)
        }
    }
    func toHex() -> String {
        var hexString = ""
        var lastValue: UInt32 = 0
        for unicodeValue in self.unicodeScalars {
            let value = unicodeValue.value
            if value >= 0 && value <= 255 {
                if value == 10 { //"\n" or "\r\n"
                    hexString.append(String(format:"%02X ",value))
                    hexString.append("\n")
                } else if lastValue == 13 { // "\r"
                    hexString.append("\n")
                    hexString.append(String(format:"%02X ",value))
                } else {
                    hexString.append(String(format:"%02X ",value))
                }
                lastValue = value
            }
        }
        return hexString
    }
}

// *************** For Data Table *******************
extension DataAnalyzerViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.datas.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let data = self.datas[row]
        // 表格列的标识
        let key = (tableColumn?.identifier.rawValue)!
        //print(key)
        // 单元格数据
        if data.keys.contains(key) {
            return data[key]
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        let key = tableColumn?.identifier.rawValue
        let value = object as? String
        self.datas[row][key!] = Double(value!)
    }
}

extension DataAnalyzerViewController: NSTabViewDelegate {
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        print("tabView title: \(String(describing: tabViewItem?.label)) identifier: \(String(describing: tabViewItem?.identifier))")
        let title = (tabViewItem?.label)!
        if title == "Diagram" || title == "图"{
            // prepare combo boxes and dataToDraw
            self.plotXComboBox.removeAllItems()
            self.plotYComboBox.removeAllItems()
            self.plotXComboBox.addItem(withObjectValue: "None")
            self.plotYComboBox.addItem(withObjectValue: "None")
            var noneDoubleList = [Double]()
            for value in ( 0..<self.datas.count ) {
                noneDoubleList.append(Double(value))
            }
            self.datasToDraw["None"] = noneDoubleList
            for column in self.dataTableView.tableColumns {
                self.plotXComboBox.addItem(withObjectValue: column.title)
                self.plotYComboBox.addItem(withObjectValue: column.title)
                var thisColumnData = [Double]()
                let key = column.identifier.rawValue
                for rowData in self.datas {
                    thisColumnData.append(rowData[key] ?? 0.0)
                }
                self.datasToDraw[column.title] = thisColumnData
            }
            
            self.plotXComboBox.selectItem(at: 0)
            self.plotYComboBox.selectItem(at: 0)
            self.plotButton.isEnabled = true
            self.plotXComboBox.isEnabled = true
            self.plotYComboBox.isEnabled = true
        } else {
            self.plotButton.isEnabled = false
            self.plotXComboBox.isEnabled = false
            self.plotYComboBox.isEnabled = false
        }
    }
}
