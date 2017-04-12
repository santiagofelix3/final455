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
    var increment = 0.0
    var counter = 0.0
    var counter2 = 1.0
    var tracker = 1
    var effTemp = 0.0
    var efficiency: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Working variables
        time = ["0"]
        efficiency = ["0"]
        //Start displaying charts
        setBackground()
        setChart(dataPoints: time, values: efficiency)
        //Starting update interval
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GraphThreeViewController.newEfficiencyValue), userInfo: nil, repeats: true)
    }
    
    // MARK: Functions
    
    //Grabs the new value for the chart
    //EffRatio over Time
    func newEfficiencyValue() {
        if (GlobalTripDataInstance.globalTrip?.started != nil) {
            //This chart goes off of 1 minute increments, checking to see if we need to had a new item.
            increment = (GlobalTripDataInstance.globalTrip?.tripLength)! / 60
            if (increment > counter2) {
                counter2 += 1
                //Tallying up the effRatio for the users last min of driving
                for location in tracker ..< (GlobalTripDataInstance.globalTrip?.tripLocationData.count)! {
                    effTemp += (GlobalTripDataInstance.globalTrip?.tripLocationData[location].efficiencyRatio)!
                    counter += 1
                }
                //Updating tracker to refelect the new starting point for the next km
                tracker = (GlobalTripDataInstance.globalTrip?.tripLocationData.count)!
                //Getting the avg and applying to vehicleActual to get a value to display
                effTemp = ((effTemp / (counter+1)) * (GlobalTripDataInstance.globalTrip?.vehicleActual)!)
                self.efficiency.append(String(effTemp))
                
                //Inserting latest value on to the bar chart in the correct location.
                if Int(counter2-2) < 10 {
                    time.insert(String(effTemp), at: Int(counter2-2))
                } else {
                    time.remove(at: 0)
                    time.insert(String(effTemp), at: 9)
                }
                
                //Reseting for next item
                effTemp = 0.0
                counter = 0.0
                
                setChart(dataPoints: time, values: efficiency)
            }
        }
    }
    
    //Displays the current chart
    func setChart(dataPoints: [String], values: [String]) {
        lineChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for (i, j) in dataPoints.enumerated() {
            let dataEntry = BarChartDataEntry()
            dataEntry.x = Double(i)
            dataEntry.y = Double(j)!
            
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
        lineChartView.leftAxis.axisMaximum = ((GlobalTripDataInstance.globalTrip?.vehicleActual)!*2.5)
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
