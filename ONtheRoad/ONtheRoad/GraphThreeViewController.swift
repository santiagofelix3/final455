//
//  GraphThreeViewController.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-03-28.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit
import Charts

class GraphThreeViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    var kilometers: [String]!
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kilometers = ["0"]
        let efficiency = ["1"]
        
        setBackground()
        setChart(dataPoints: kilometers, values: efficiency)
        
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(GraphThreeViewController.newEfficiencyValue), userInfo: nil, repeats: true)
    }
    
    // MARK: Functions
    
    func newEfficiencyValue() {
        
        let efficiency = ["5.0", "10.0", "15.0", "20.0", "25.0", "30.0", "35.0", "40.0", "45.0", "50.0"]
        
        if counter < 20 {
            kilometers.insert(generateRandomNumbers(), at: counter)
            counter += 1
        } else {
            kilometers.remove(at: 0)
            kilometers.insert(generateRandomNumbers(), at: 20)
        }
        
        setChart(dataPoints: kilometers, values: efficiency)
    }
    
    func setChart(dataPoints: [String], values: [String]) {
        lineChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for (i, j) in dataPoints.enumerated() {
            let dataEntry = BarChartDataEntry()
            dataEntry.x = Double(i)
            dataEntry.y = Double(j)!
            
            dataEntries.append(dataEntry)
        }
        
        let targetLine = ChartLimitLine(limit: 14.0, label: "Ideal")
        
        targetLine.lineWidth = 1
        targetLine.valueTextColor = UIColor.white
        
        let noZeroFormatter = NumberFormatter()
        noZeroFormatter.zeroSymbol = ""
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Efficiency")
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        
        lineChartDataSet.valueFormatter = DefaultValueFormatter(formatter: noZeroFormatter)
        
        lineChartView.data = lineChartData
        lineChartView.chartDescription?.text = ""
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.labelTextColor = Palette.InfoText
        lineChartView.xAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.labelTextColor = Palette.InfoText
        //lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        
        lineChartView.leftAxis.addLimitLine(targetLine)
        lineChartView.leftAxis.axisMaximum = 30.0
        lineChartView.rightAxis.axisMinimum = 0.0
        lineChartView.rightAxis.axisMaximum = 30.0
        lineChartView.leftAxis.axisMinimum = 0.0

        lineChartView.backgroundColor = UIColor.clear
        lineChartView.leftAxis.drawLabelsEnabled = true
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.axisLineColor = UIColor.clear
        lineChartView.rightAxis.axisLineColor = UIColor.clear
        lineChartView.xAxis.axisLineColor = UIColor.clear
        lineChartView.legend.enabled = false
        
        lineChartDataSet.setCircleColor(UIColor.clear)
        lineChartDataSet.drawCircleHoleEnabled = true
        lineChartDataSet.circleHoleColor = Palette.InfoText
        lineChartDataSet.circleHoleRadius = 3.0
        lineChartDataSet.valueTextColor = .clear
        lineChartDataSet.setColor(UIColor.white.withAlphaComponent(0.5))
        lineChartDataSet.lineWidth = 2
        
        
        let gradientColors = [UIColor.white.cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        lineChartDataSet.drawFilledEnabled = true
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
