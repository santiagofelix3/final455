//
//  GraphThreeViewController.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-03-28.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit
import Charts
import Foundation

class GraphThreeViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    var time: [String]!
    var increment: Double?
    var counter = 0.0
    var counter2 = 1.0
    var tracker = 1
    var effTemp = 0.0
    var efficiency: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        time = ["0"]
        efficiency = ["0"]
        
        setBackground()
        setChart(dataPoints: time, values: efficiency)
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GraphThreeViewController.newEfficiencyValue), userInfo: nil, repeats: true)
    }
    
    // MARK: Functions
    
    func newEfficiencyValue() {
        
        if (GlobalTripDataInstance.globalTrip?.started != nil) {
            increment = (GlobalTripDataInstance.globalTrip?.tripLength)! / 15
            if (increment! > 1.0*counter2) {
                counter2 += 1
                for location in tracker ..< (GlobalTripDataInstance.globalTrip?.tripLocationData.count)! {
                    effTemp += (GlobalTripDataInstance.globalTrip?.tripLocationData[location].efficiencyRatio)!
                    counter += 1
                }
                self.efficiency.append(String((effTemp / counter)*6.2))
                print ("e: ", (effTemp / counter)*6.2)
                counter = 0
                tracker = (GlobalTripDataInstance.globalTrip?.tripLocationData.count)!
                
                if Int(counter2-2) < 10 {
                    time.insert(String(describing: increment), at: Int(counter2-2))
                } else {
                    time.remove(at: 0)
                    time.insert(String(describing: increment), at: 10)
                }
                
                effTemp = 0.0
                
                setChart(dataPoints: time, values: efficiency)
            }
        }
    }
    
    func setChart(dataPoints: [String], values: [String]) {
        lineChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for (i, j) in dataPoints.enumerated() {
            let dataEntry = BarChartDataEntry()
            dataEntry.x = Double(i)
            dataEntry.y = Double(j)! / 2
            
            dataEntries.append(dataEntry)
        }
        
        let targetLine = ChartLimitLine(limit: (GlobalTripDataInstance.globalTrip?.vehicleActual)!, label: "Ideal")
        
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
        lineChartView.leftAxis.axisMaximum = ((GlobalTripDataInstance.globalTrip?.vehicleActual)!*3)
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
