//
//  SDZBarSymbolSet-Enumeration.swift
//  ScalaDays
//
//  Created by Javier de Silóniz Sandino on 06/02/15.
//  Copyright (c) 2015 Ana. All rights reserved.
//

import Foundation

extension ZBarSymbolSet: SequenceType {
    public func generate() -> NSFastGenerator {
        return NSFastGenerator(self)
    }
}