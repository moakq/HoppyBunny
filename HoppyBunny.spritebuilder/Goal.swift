//
//  Goal.swift
//  HoppyBunny
//
//  Created by Muhammed Othman on 6/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class Goal: CCNode
{
    func didLoadFromCCB()
    {
        physicsBody.sensor = true
    }
}