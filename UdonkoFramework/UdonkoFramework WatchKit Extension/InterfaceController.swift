//
//  InterfaceController.swift
//  UdonkoFramework WatchKit Extension
//
//  Created by UDONKONET on 2016/07/18.
//  Copyright © 2016年 UDONKONET. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit


class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate {
    
    @IBOutlet var label: WKInterfaceLabel!
    @IBOutlet var button: WKInterfaceButton!
    
    let healthStore = HKHealthStore()
    var workoutSession:HKWorkoutSession?
    //修正START 2015/12/12
    var heartRateQuery:HKQuery?
    //修正END
    //追加START 2015/12/12
    let heartRateUnit = HKUnit(fromString: "count/min")
    //追加END
    
    var isRunning = false
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        if HKHealthStore.isHealthDataAvailable() != true {
            print("not available")
            return
        }
        
        let typesToRead = Set([
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!,
            ])
        
        //HealthKitへのアクセス許可をユーザーへ求める
        self.healthStore.requestAuthorizationToShareTypes(nil, readTypes: typesToRead) { success, error in
            print("requestAuthorizationToShareTypes: \(success)")
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func btnTapped() {
        //測定スタート
        if isRunning == false {
            //workoutSessionを作成
            self.workoutSession = HKWorkoutSession(activityType: HKWorkoutActivityType.Other, locationType: HKWorkoutSessionLocationType.Unknown)
            self.workoutSession!.delegate = self
            
            //修正START 2015/12/12
            //workoutSessionをスタート。
            self.healthStore.startWorkoutSession(self.workoutSession!)
            //修正END
            
            //測定ストップ
        }else if isRunning == true {
            //修正START 2015/12/12
            //workoutSessionをストップ。
            self.healthStore.endWorkoutSession(self.workoutSession!)
            //修正END
        }
    }
    
    /* デリゲートメソッド */
    //workoutSessionの状態が変化した時に呼ばれる
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        //修正START 2015/12/12
        switch toState {
        //開始
        case .Running:
            print("workoutSession: .Running")
            self.heartRateQuery = createHeartRateStreamingQuery(date)
            self.healthStore.executeQuery(self.heartRateQuery!)
            self.button.setTitle("STOP")
            self.isRunning = true
        //終了
        case .Ended:
            print("workoutSession: .Ended")
            self.healthStore.stopQuery(self.heartRateQuery!)
            self.label.setText("---")
            self.button.setTitle("START")
            self.isRunning = false
        default:
            print("Unexpected workout session state \(toState)")
        }
        //修正END
    }
    
    //エラーが発生した時に呼ばれる
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        //...
    }
    
    //追加START 2015/12/12
    //クエリーを作成
    func createHeartRateStreamingQuery(workoutStartDate: NSDate) ->HKQuery{
        let sampleType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        /*
         let heartRateQuery = HKAnchoredObjectQuery(type: sampleType!, predicate: nil, anchor: 0, limit: 0) { (query, sampleObjects,  newAnchor, error) -> Void in
         self.updateHeartRate(sampleObjects)
         }
         */
        let heartRateQuery = HKAnchoredObjectQuery(type: sampleType!, predicate: nil, anchor: nil, limit: 0) { (query, sampleObjects, DelObjects, newAnchor, error) -> Void in
            //self.updateHeartRate(sampleObjects)
        }
        //アップデートハンドラーを設定
        //心拍数情報が更新されると呼ばれる
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.updateHeartRate(samples)
        }
        
        return heartRateQuery
    }
    //追加END
    
    //追加START 2015/12/12
    //アップデートハンドラー
    func updateHeartRate(samples: [HKSample]?){
        //心拍数を取得
        guard let heartRateSamples = samples as?[HKQuantitySample] else {return}
        let sample = heartRateSamples.first
        let value = Int(sample!.quantity.doubleValueForUnit(self.heartRateUnit))
        label.setText(String(value))
    }
    //追加END
    
}