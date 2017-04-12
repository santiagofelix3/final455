//
//  GraphTwoViewController.swift
//  ONtheRoad
//
//  Created by Santiago Félix Cárdenas on 2017-03-28.
//  Copyright © 2017 Santiago Félix Cárdenas. All rights reserved.
//

import UIKit
import Charts
import Foundation

class GraphTwoViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var barChartView: BarChartView!
    
    var kilometers: [String]!
    var increment = 0.0
    var counter = 0.0
    var counter2 = 1.0
    var tracker = 1
    var effTemp = 0.0
    var efficiency: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init working vars
        kilometers = ["0"]
        efficiency = ["0"]
        //Starts the chart
        setBackground()
        setChart(dataPoints: kilometers, values: efficiency)
        //Controling update intervals
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GraphTwoViewController.newEfficiencyValue), userInfo: nil, repeats: true)
    }
    
    // MARK: Functions
    
    //Grabbing the new value for the chart
    //EffRatio over distance
    func newEfficiencyValue() {
        
        if (GlobalTripDataInstance.globalTrip?.started != nil) {
            //Doesn't create a new bar until the user has traveled 1km
            increment = (GlobalTripDataInstance.globalTrip?.tripDistance)! / 1000
            //Usinging this to check for 1km increments, counter2 tracks km ranges
            if (increment > counter2) {
                counter2 += 1
                //Tallying up the effRatio for the users last km of driving
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
                    kilometers.insert(String(effTemp), at: Int(counter2-2))
                } else {
                    kilometers.remove(at: 0)
                    kilometers.insert(String(effTemp), at: 9)
                }
                //Reseting for the next bar
                counter = 0.0
                effTemp = 0.0
                
                setChart(dataPoints: kilometers, values: efficiency)
                
            }
        }
    }
    
    //Displays the current chart
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
        let targetLine = ChartLimitLine(limit: (GlobalTripDataInstance.globalTrip?.vehicleActual)!, label: "Ideal")
        
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
        barChartView.leftAxis.axisMaximum = ((GlobalTripDataInstance.globalTrip?.vehicleActual)!*2.5)
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
