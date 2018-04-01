//
//  Pessoa.swift
//  SQLite-Swift4
//
//  Created by Humberto Puccinelli on 01/04/2018.
//  Copyright © 2018 Humberto Puccinelli. All rights reserved.
//

import UIKit

class Pessoa: NSObject {
    
    var id: Int
    var nome: String
    
    init(id: Int, nome: String){
        self.id = id
        self.nome = nome
    }

}
