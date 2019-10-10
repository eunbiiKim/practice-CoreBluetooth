//
//  ViewController.swift
//  HandsOnCoreBluetooth
//
//  Created by 김은비 on 08/10/2019.
//  Copyright © 2019 김은비. All rights reserved.
//

import UIKit
import CoreBluetooth
import os

class ViewController: UIViewController {

    var centralManager: CBCentralManager!
    var peripheralArr: [CBPeripheral] = []
    var peripheralSet: Set<CBPeripheral> = []
    var prefix = ["Hu", "Te"]
    let serviceUUID: String = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    var writeChar: CBCharacteristic!

    var h: Float = 0.0
    var t: Float = 0.0

    @IBOutlet var btableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Bluetooth List View Controller's viewDidLoad")
        self.btableView.delegate = self
        self.btableView.dataSource = self
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        //self.btableView.reloadData()

    }


}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch centralManager.state {
        case .poweredOn:
            os_log("poweredOn")
            self.peripheralArr.removeAll()
            self.peripheralSet.removeAll()

            self.centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])

            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
                self.centralManager.stopScan()
                self.peripheralArr = Array(self.peripheralSet)
                self.btableView.reloadData()
            }

        case .poweredOff:
            os_log("poweredOff")
            let alert = UIAlertController(title: "알림", message: "블루투스가 꺼져있습니다. 블루투스를 켜주세요", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        case .unknown:
            os_log("unknown")
        case .resetting:
            os_log("resetting")
        case .unsupported:
            os_log("unsupported")
        case .unauthorized:
            os_log("unauthorized")
        @unknown default:
            fatalError()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.name ?? "No Name")
        print(RSSI)
        if peripheral.name != nil {
            self.peripheralSet.insert(peripheral)
            print(peripheral.identifier)
            print(peripheral.hash)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        print("Connected.")
        self.dismiss(animated: true, completion: nil)

    }

    //    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
    //        let alert = UIAlertController(title: "알림", message: "연결되었습니다.", preferredStyle: .alert)
    //        let alertAction = UIAlertAction(title: "확인", style: .default) { (alertA) in
    //            self.dismiss(animated: true, completion: nil)
    //        }
    //        alert.addAction(alertAction)
    //    }
}

extension ViewController: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for ser: CBService in peripheral.services! {
            print("Service : \(ser.uuid.uuidString)")
            if ser.uuid.uuidString == serviceUUID {
                peripheral.discoverCharacteristics(nil, for: ser)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for ch in service.characteristics! {
            print("Char : \(ch)")
            if ch.uuid.uuidString == serviceUUID {
                peripheral.setNotifyValue(true, for: ch)
            } else if ch.uuid.uuidString == serviceUUID {
                self.writeChar = ch
            }
        }
    }


    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueFor")

        if let error = error {
            print("\(error)")
        } else {
            if let value = characteristic.value {
                var str = String(data: value, encoding: .utf8)
                str = str != nil ? str: "nil"
                if (str?.hasPrefix("Hu"))! {
                    self.h = (String(str!.split(separator: ":")[1]) as NSString).floatValue
                    self.prefix[0] = String(self.h)
                    print(h)
                } else if (str?.hasPrefix("Te"))! {
                    self.t = (String(str!.split(separator: ":")[1]) as NSString).floatValue
                    self.prefix[1] = String(self.t)
                    print(t)
                } else {
                    print("unknown data")
                }
            }
        }

    }



}

extension ViewController: UITableViewDelegate ,UITableViewDataSource {


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Table view have \(peripheralArr.count)cells.")
        return peripheralArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = btableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = peripheralArr[indexPath.row].name
        print("cell is :\(indexPath.row)")

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //  let bleDevice = self.peripheralArr[indexPath.row]
        self.centralManager.connect(peripheralArr[indexPath.row], options: nil)
        print("cell: Connected.")
    }


}

