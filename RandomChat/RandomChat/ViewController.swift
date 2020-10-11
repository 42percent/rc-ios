//
//  ViewController.swift
//  RandomChat
//
//  Created by Kyungmo on 2020/10/11.
//

import UIKit
import Starscream

class ViewController: UIViewController {

    var isConnected: Bool = false
    var socket: WebSocket!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var request = URLRequest(url: URL(string: "ws://172.20.10.4:8080/ws/chat")!)
        request.timeoutInterval = 15
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }


    @IBAction func onClickBtn(_ sender: Any) {
        let value: [String: Any] = [
            "chatRoomId": "19ea34f4-2baa-46ca-b166-5bc5fdadaeed",
            "type": "JOIN",
            "writer": "SUNG"
        ]

        if let json = try? JSONSerialization.data(
            withJSONObject: value,
            options: []), let jsonText = String(data: json, encoding: .ascii) {
            
            print("JSON string = \(jsonText)")
            
            socket.write(string: jsonText) {
                print("onSuccess()")
            }
        }
    }
}

extension ViewController: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
}
