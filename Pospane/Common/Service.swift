//
//  Service.swift
//  Pospane
//
//  Created by Karol Stępień on 25/09/2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import Foundation
import AzureIoTHubClient

class Service {
    static let sharedInstance = Service()
    //Put you connection string here
    private let connectionString = "HostName=Pospane.azure-devices.net;DeviceId=Pospane-iOS;SharedAccessKey=Qb5fitcNMka/NpNdjvvPv9v9C+UGpnDwHOu+/tzH4l8="
    
    // Select your protocol of choice: MQTT_Protocol, AMQP_Protocol or HTTP_Protocol
    // Note: HTTP_Protocol is not currently supported
    private let iotProtocol: IOTHUB_CLIENT_TRANSPORT_PROVIDER = MQTT_Protocol
    
    // IoT hub handle
    private var iotHubClientHandle: IOTHUB_CLIENT_LL_HANDLE!;
    var timerDoWork: Timer!
    
    init() {
        iotHubClientHandle = IoTHubClient_LL_CreateFromConnectionString(connectionString, iotProtocol)
        
        if (iotHubClientHandle == nil) {
            showError(message: "Failed to create IoT handle", startState: true, stopState: false)
            
            return
        }
        
        // Mangle my self pointer in order to pass it as an UnsafeMutableRawPointer
        let that = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        // Set up the message callback
        if (IOTHUB_CLIENT_OK != (IoTHubClient_LL_SetMessageCallback(iotHubClientHandle, myReceiveMessageCallback, that))) {
            showError(message: "Failed to establish received message callback", startState: true, stopState: false)
            
            return
        }
        timerDoWork = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dowork), userInfo: nil, repeats: true)
    }
    
    deinit {
        destroy()
    }
    
    func destroy() {
        IoTHubClient_LL_Destroy(iotHubClientHandle)
        timerDoWork?.invalidate()
    }
    /// Sends a message to the IoT hub
    @objc func sendMessage(rr: Double) {

//        let data: [String: String] = ["rr": String(format: "%.0f", rr)]
        let data = String(format: "{\"rr\": %.0f}", rr)
//        updateTelem()
        var messageString = data.description
        // This the message
//        messageString = randomTelem
//        lblLastSent.text = messageString
        
        
        // Construct the message
        let messageHandle: IOTHUB_MESSAGE_HANDLE = IoTHubMessage_CreateFromByteArray(messageString, messageString.utf8.count)
        
        if (messageHandle != OpaquePointer.init(bitPattern: 0)) {
            
            // Manipulate my self pointer so that the callback can access the class instance
            let that = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            
            if (IOTHUB_CLIENT_OK == IoTHubClient_LL_SendEventAsync(iotHubClientHandle, messageHandle, mySendConfirmationCallback, that)) {
//                incrementSent()
                print("sent \(messageString)")
            }
        }
        
        dowork()
    }
    
    /// Check for waiting messages and send any that have been buffered
    @objc func dowork() {
        IoTHubClient_LL_DoWork(iotHubClientHandle)
    }
    
    
    func showError(message: String, startState: Bool, stopState: Bool) {
//        btnStart.isEnabled = startState
//        btnStop.isEnabled = stopState
        print(message)
    }
    
    // This function will be called when a message confirmation is received
    //
    // This is a variable that contains a function which causes the code to be out of the class instance's
    // scope. In order to interact with the UI class instance address is passed in userContext. It is
    // somewhat of a machination to convert the UnsafeMutableRawPointer back to a class instance
    let mySendConfirmationCallback: IOTHUB_CLIENT_EVENT_CONFIRMATION_CALLBACK = { result, userContext in
        
//        var mySelf: ViewController = Unmanaged<ViewController>.fromOpaque(userContext!).takeUnretainedValue()
        
        if (result == IOTHUB_CLIENT_CONFIRMATION_OK) {
            print("confirmed")
        }
        else {
            print("failed")
        }
    }
    
    // This function is called when a message is received from the IoT hub. Once again it has to get a
    // pointer to the class instance as in the function above.
    let myReceiveMessageCallback: IOTHUB_CLIENT_MESSAGE_CALLBACK_ASYNC = { message, userContext in
        
//        var mySelf: ViewController = Unmanaged<ViewController>.fromOpaque(userContext!).takeUnretainedValue()
        
        var messageId: String!
        var correlationId: String!
        var size: Int = 0
        var buff: UnsafePointer<UInt8>?
        var messageString: String = ""
        
        messageId = String(describing: IoTHubMessage_GetMessageId(message))
        correlationId = String(describing: IoTHubMessage_GetCorrelationId(message))
        
        if (messageId == nil) {
            messageId = "<nil>"
        }
        
        if correlationId == nil {
            correlationId = "<nil>"
        }
        
//        mySelf.incrementRcvd()
        
        // Get the data from the message
        var rc: IOTHUB_MESSAGE_RESULT = IoTHubMessage_GetByteArray(message, &buff, &size)
        
        if rc == IOTHUB_MESSAGE_OK {
            // Print data in hex
            for i in 0 ..< size {
                let out = String(buff![i], radix: 16)
                print("0x" + out, terminator: " ")
            }
            
            print()
            
            // This assumes the received message is a string
            let data = Data(bytes: buff!, count: size)
            messageString = String.init(data: data, encoding: String.Encoding.utf8)!
            
            print("Message Id:", messageId, " Correlation Id:", correlationId)
            print("Message:", messageString)
//            mySelf.lblLastRcvd.text = messageString
        }
        else {
            print("Failed to acquire message data")
//            mySelf.lblLastRcvd.text = "Failed to acquire message data"
        }
        return IOTHUBMESSAGE_ACCEPTED
    }
    
    /// Called when the start button is clicked on the UI. Starts sending messages.
    ///
    /// - parameter sender: The clicked button
    public func startSend() {
        
        // Dialog box to show action received
        //    btnStart.isEnabled = false
        //    btnStop.isEnabled = true
        //    cntSent = 0
        //    lblSent.text = String(cntSent)
        //    cntGood = 0
        //    lblGood.text = String(cntGood)
        //    cntBad = 0
        //    lblBad.text = String(cntBad)
        
        // Create the client handle
        iotHubClientHandle = IoTHubClient_LL_CreateFromConnectionString(connectionString, iotProtocol)
        
        if (iotHubClientHandle == nil) {
            showError(message: "Failed to create IoT handle", startState: true, stopState: false)
            
            return
        }
        
        // Mangle my self pointer in order to pass it as an UnsafeMutableRawPointer
        let that = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        // Set up the message callback
        if (IOTHUB_CLIENT_OK != (IoTHubClient_LL_SetMessageCallback(iotHubClientHandle, myReceiveMessageCallback, that))) {
            showError(message: "Failed to establish received message callback", startState: true, stopState: false)
            
            return
        }
        
        //    // Timer for message sends and timer for message polls
        //    timerMsgRate = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(sendMessage), userInfo: nil, repeats: true)
        //    timerDoWork = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dowork), userInfo: nil, repeats: true)
    }
    
    /// Called when the stop button is clicked on the UI. Stops sending messages and cleans up.
    ///
    /// - parameter sender: The clicked button
    public func stopSend() {
        
        //    timerMsgRate?.invalidate()
        //    timerDoWork?.invalidate()
        IoTHubClient_LL_Destroy(iotHubClientHandle)
        //    btnStart.isEnabled = true
        //    btnStop.isEnabled = false
    }

}
