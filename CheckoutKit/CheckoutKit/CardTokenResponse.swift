//
//  CardTokenResponse.swift
//  CheckoutKit
//
//  Created by Manon Henrioux on 17/08/2015.
//  Copyright (c) 2015 Checkout.com. All rights reserved.
//

import Foundation

/** Class used for receiving REST messages, it has the same format as the expected response. We extract the useful information based on this. */


public class CardTokenResponse: Serializable {
    
    public var cardToken: String!
    public var liveMode: Bool!
    public var created: String!
    public var used: Bool!
    
    /**
    Default constructor
    
    @param cardToken String containing the id of the card
    
    @param liveMode boolean, if the request was on a live server or not
    
    @param created String containing time information about the creation of the card token
    
    @param used boolean, if the token has already been used or not
    
    @param card CardToken object containing all the information needed to charge the card
    
    */
    
    public init(cardToken: String, liveMode: Bool, created: String, used: Bool) {
        self.cardToken = cardToken
        self.liveMode = liveMode
        self.created = created
        self.used = used
    }
    
    /**
    
    Convenience constructor
    
    @param data Dictionary [String: AnyObject] containing a JSON representation of a CardTokenResponse instance
    
    */
    
    public required init?(data: [String: AnyObject]) {
        if let ct = data["id"] as? String,
            created = data["created"] as? String,
            lm = data["liveMode"] as? Bool,
            used = data["used"] as? Bool {
                self.cardToken = ct
                self.created = created
                self.liveMode = lm
                self.used = used
        } else {
            return nil
        }
    }
}