//
//  ViewController.swift
//  SQLite-Swift4
//
//  Created by Humberto Puccinelli on 31/03/2018.
//  Copyright © 2018 Humberto Puccinelli. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tabelaDados: UITableView!
    
    var db: OpaquePointer?
    var pessoas = [Pessoa]()
    
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("SQLite-Swift4.sqlite")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabelaDados.delegate = self
        tabelaDados.dataSource = self
        tabelaDados.register(UITableViewCell.self, forCellReuseIdentifier: "celula")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Erro ao abrir banco de daos")
        }else{
            criaTabela()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func criaTabela(){
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Pessoas (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("erro ao criar tabela: \(errmsg)")
        }else{
            retornaDados()
        }
    }
    
    func retornaDados(){
        
        pessoas.removeAll()
        
        let queryString = "SELECT * FROM Pessoas"
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("erro ler dados: \(errmsg)")
            return
        }else{
            while(sqlite3_step(stmt) == SQLITE_ROW){
                let idEncontrado = sqlite3_column_int(stmt, 0)
                let nomeEncontrado = String(cString: sqlite3_column_text(stmt, 1))
                
                pessoas.append(Pessoa(id: Int(idEncontrado), nome: nomeEncontrado))
            }
            tabelaDados.reloadData()
        }
    }
    
    func deletaPessoa(id: Int) {
        
        let queryString = "DELETE FROM Pessoas where id = \(id)"
        executaQuerry(queryString: queryString)
    }
    
    func updatePessoa(id: Int, nome: String) {
        
        let queryString = "UPDATE Pessoas set nome = '\(nome)' WHERE id = \(id)"
        executaQuerry(queryString: queryString)
    }
    
    func insereDados(nomePessoa: String) {
        
        let queryString = "INSERT INTO Pessoas (nome) VALUES ('\(nomePessoa)')"
        executaQuerry(queryString: queryString)
    }
    
    func executaQuerry(queryString: String){
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("erro a preparar dados: \(errmsg)")
        }else{
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("falha ao atualizar pessoa: \(errmsg)")
            }else{
                retornaDados()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pessoas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celulaTabela = tableView.dequeueReusableCell(withIdentifier: "celula", for:indexPath)
        let pessoaListada: Pessoa = pessoas[indexPath.row]
        celulaTabela.textLabel?.text = pessoaListada.nome
        
        return celulaTabela
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let pessoaListada: Pessoa = pessoas[indexPath.row]
            deletaPessoa(id: pessoaListada.id)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var nomePessoa = ""
        let pessoaListada: Pessoa = pessoas[indexPath.row]
        nomePessoa = pessoaListada.nome
        
        let alerta = UIAlertController(title: "Editar nome",
                                       message: nomePessoa,
                                       preferredStyle: .alert)
        
        let salvarNovoNome = UIAlertAction(title: "salvar",
                                           style: .default) {
                                            [unowned self] action in
                                            
                                            guard let textField = alerta.textFields?.first,  let nomeSalvar = textField.text else {
                                                
                                                return
                                            }
                                            self.updatePessoa(id: pessoaListada.id, nome: nomeSalvar)
        }
        
        let cancelar = UIAlertAction(title: "cancelar", style: .default)
        
        alerta.addTextField()
        
        alerta.addAction(salvarNovoNome)
        alerta.addAction(cancelar)
        
        present(alerta, animated: true)
        
    }
    
    @IBAction func addPessoa(_ sender: UIBarButtonItem) {
        let alerta = UIAlertController(title: "Novo nome",
                                       message: "Add novo nome",
                                       preferredStyle: .alert)
        
        let salvarNovoNome = UIAlertAction(title: "salvar",
                                           style: .default) {
                                            [unowned self] action in
                                            
                                            guard let textField = alerta.textFields?.first,
                                                let nomeSalvar = textField.text else {
                                                    return
                                            }
                                            
                                            self.insereDados(nomePessoa:nomeSalvar)
                                            self.tabelaDados.reloadData()
        }
        
        let cancelar = UIAlertAction(title: "cancelar", style: .default)
        
        alerta.addTextField()
        
        alerta.addAction(salvarNovoNome)
        alerta.addAction(cancelar)
        
        present(alerta, animated: true)
    }
}

