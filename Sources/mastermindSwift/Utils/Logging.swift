import SwiftyBeaver
import Foundation

let log = SwiftyBeaver.self

func setupLog() {
    let file = FileDestination()
    file.logFileURL = URL(fileURLWithPath: "./app.log")
    file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d [$L] $M $X"

    log.addDestination(file)
}

