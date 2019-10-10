

import UIKit
import CoreBluetooth

class DataViewController: UIViewController {

    var centralManager: CBCentralManager!

    @IBOutlet weak var hLabel: UILabel!
    @IBOutlet weak var pLabel: UILabel!

    var viewCon = ViewController()

    var peripheralArr: [CBPeripheral] = []
    var peripheralSet: Set<CBPeripheral> = []
    var prefix = ["Hu", "Te"]
    let serviceUUID: String = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    var writeChar: CBCharacteristic!

    var h: Float = 0.0
    var t: Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Data View Controller's viewDidLoad")
        self.hLabel.text = String(self.viewCon.h)
        self.pLabel.text = String(self.viewCon.t)
        print("\(String(describing: hLabel?.text ?? "nil"))")
        print("\(String(describing: pLabel?.text ?? "nil"))")
    }
}
