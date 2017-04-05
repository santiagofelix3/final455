//
//  GraphTwoViewController.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-03-28.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit
import Charts

class GraphTwoViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var barChartView: BarChartView!
    
    var kilometers: [String]!
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kilometers = ["0"]
        let efficiency = ["1"]
        
        setBackground()
        setChart(dataPoints: kilometers, values: efficiency)
        
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(GraphTwoViewController.newEfficiencyValue), userInfo: nil, repeats: true)
    }
    
    // MARK: Functions
    
    func newEfficiencyValue() {
        
        let efficiency = ["5.0", "10.0", "15.0", "20.0", "25.0", "30.0", "35.0", "40.0", "45.0", "50.0"]
        
        if counter < 10 {
            kilometers.insert(generateRandomNumbers(), at: counter)
            counter += 1
        } else {
            kilometers.remove(at: 0)
            kilometers.insert(generateRandomNumbers(), at: 10)
        }
        setChart(dataPoints: kilometers, values: efficiency)
    }
    
    func setChart(dataPoints: [String], values: [String]) {
        barChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for (i, j) in dataPoints.enumerated() {
            let dataEntry = BarChartDataEntry()
            dataEntry.x = Double(i)
            dataEntry.y = Double(j)!
            
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Efficiency")
        let chartData = BarChartData(dataSet: chartDataSet)
        let targetLine = ChartLimitLine(limit: 14.0, label: "Ideal")
        
        targetLine.lineWidth = 1
        targetLine.valueTextColor = UIColor.white
        
        let noZeroFormatter = NumberFormatter()
        noZeroFormatter.zeroSymbol = ""
        chartDataSet.valueFormatter = DefaultValueFormatter(formatter: noZeroFormatter)
        
        barChartView.data = chartData
        barChartView.chartDescription?.text = ""
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.labelTextColor = Palette.InfoText
        barChartView.xAxis.drawLabelsEnabled = false
        barChartView.leftAxis.labelTextColor = Palette.InfoText
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        
        barChartView.leftAxis.addLimitLine(targetLine)
        barChartView.leftAxis.axisMaximum = 30.0
        barChartView.rightAxis.axisMinimum = 0.0
        barChartView.rightAxis.axisMaximum = 30.0
        barChartView.leftAxis.axisMinimum = 0.0
        
        barChartView.backgroundColor = UIColor.clear
        barChartView.leftAxis.drawLabelsEnabled = true
        barChartView.rightAxis.drawLabelsEnabled = false
        barChartView.leftAxis.axisLineColor = UIColor.clear
        barChartView.rightAxis.axisLineColor = UIColor.clear
        barChartView.xAxis.axisLineColor = UIColor.clear
        barChartView.legend.enabled = false
        
        chartDataSet.valueTextColor = .clear
        chartDataSet.setColor(.white, alpha: 0.8)
        chartDataSet.highlightEnabled = false
    }
    
    func generateRandomNumbers() -> String {
        let rand = Double(arc4random_uniform(UInt32(28.0)))
        let randStr = "\(rand)"
        
        return randStr
    }
    
    func setBackground() {
        let topColor = UIColor(red: 99/255.0, green: 175/255.0, blue: 213/255.0, alpha: 1.0)
        let bottomColor = UIColor(red: 5/255.0, green: 54/255.0, blue: 106/255.0, alpha: 1.0)
        
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

class Palette {
    static let Background = UIColor(red: 17/255.0, green: 59/255.0, blue: 114/255.0, alpha: 1.0)
    static let InfoText = UIColor.white
    static let Text = UIColor(red: 36/255.0, green: 129/255.0, blue: 255/255.0, alpha: 1.0)
    static let Xgrid = UIColor.white
}
