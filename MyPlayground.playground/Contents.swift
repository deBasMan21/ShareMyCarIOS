import UIKit

class Car {
    var name : String
    
    init(name : String) {
        self.name = name
    }
    
    func printName(){
        print(name)
    }
}

var auto = Car(name : "Volkswagen Golf")
auto.printName()

