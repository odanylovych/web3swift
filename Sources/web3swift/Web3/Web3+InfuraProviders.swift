//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//
import Foundation
import Starscream

/// Custom Web3 HTTP provider of Infura nodes.
public final class InfuraProvider: Web3HttpProvider {
    public init?(_ net:Networks, accessToken token: String? = nil) {
        var requestURLstring = "https://" + net.name + Constants.infuraHttpScheme
        requestURLstring += token != nil ? token! : Constants.infuraToken
        let providerURL = URL(string: requestURLstring)
        super.init(providerURL!, network: net)
    }
}

/// Custom Websocket provider of Infura nodes.
public final class InfuraWebsocketProvider: WebsocketProvider {
    public init?(_ network: Networks,
                 delegate: Web3SocketDelegate? = nil,
                 projectId: String? = nil) {
        guard network == Networks.Kovan
            || network == Networks.Rinkeby
            || network == Networks.Ropsten
            || network == Networks.Mainnet else {return nil}
        let networkName = network.name
        let urlString = "wss://" + networkName + Constants.infuraWsScheme
        guard URL(string: urlString) != nil else {return nil}
        super.init(urlString,
                   delegate: delegate,
                   projectId: projectId,
                   network: network)
    }
    
    public init?(_ endpoint: String,
                 delegate: Web3SocketDelegate? = nil,
                 projectId: String? = nil) {
        guard URL(string: endpoint) != nil else {return nil}
        super.init(endpoint,
                   delegate: delegate,
                   projectId: projectId)
    }
    
    public init?(_ endpoint: URL,
                 delegate: Web3SocketDelegate? = nil,
                 projectId: String? = nil) {
        super.init(endpoint,
                   delegate: delegate,
                   projectId: projectId)
    }
    
    override public class func connectToSocket(_ endpoint: String,
                                               delegate: Web3SocketDelegate? = nil,
                                               projectId: String? = nil,
                                               network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = InfuraWebsocketProvider(endpoint,
                                                           delegate: delegate,
                                                           projectId: projectId) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }
    
    override public class func connectToSocket(_ endpoint: URL,
                                               delegate: Web3SocketDelegate? = nil,
                                               projectId: String? = nil,
                                               network net: Networks? = nil) -> WebsocketProvider? {
        guard let socketProvider = InfuraWebsocketProvider(endpoint,
                                                           delegate: delegate,
                                                           projectId: projectId) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }
    
    public static func connectToInfuraSocket(_ network: Networks,
                                             delegate: Web3SocketDelegate,
                                             projectId: String? = nil) -> InfuraWebsocketProvider? {
        guard let socketProvider = InfuraWebsocketProvider(network,
                                                           delegate: delegate,
                                                           projectId: projectId) else {return nil}
        socketProvider.connectSocket()
        return socketProvider
    }
    
    public func subscribeOnNewHeads() throws {
        let method = JSONRPCmethod.subscribe
        let params = ["newHeads"]
        try writeMessage(method: method, params: params)
    }
    
    public func subscribeOnLogs(addresses: [EthereumAddress]? = nil, topics: [String]? = nil) throws {
        let method = JSONRPCmethod.subscribe
        var stringAddresses = [String]()
        if let addrs = addresses {
            for addr in addrs {
                stringAddresses.append(addr.address)
            }
        }
//        let ts = topics == nil ? nil : [topics!]
        let filterParams = EventFilterParameters(fromBlock: nil, toBlock: nil, topics: [topics], address: stringAddresses)
        try writeMessage(method: method, params: ["logs", filterParams])
    }
    
    public func subscribeOnNewPendingTransactions() throws {
        let method = JSONRPCmethod.subscribe
        let params = ["newPendingTransactions"]
        try writeMessage(method: method, params: params)
    }
    
    public func subscribeOnSyncing() throws {
        guard network != Networks.Kovan else {
            throw Web3Error.inputError(desc: "Can't sync on Kovan")
        }
        let method = JSONRPCmethod.subscribe
        let params = ["syncing"]
        try writeMessage(method: method, params: params)
    }
}
