//
//  UlogovanKorisnik.swift
//  moj-instagram
//
//  Created by Vuk on 7/25/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices

class UlogovanKorisnik: UIViewController, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate {

    var noviZapis: Bool?
    var slika: UIImage?
    
    var rečnikDodatihSlika = [:]
    var nizJedinstvenihNazivaSlika = [String]()
    var nizSlika = [String]()
    var nizVremenaDodavnjaSlika = [String]()
    var nizBezOptionala = [String]()
    var nizSlika2 = [String]()
    var nizBezOptionala2 = [String]()
    var nizVremenaDodavnjaSlika2 = [String]()
    var foto: UIImage?
    var nizFotografija = [UIImage]()
    var matricaFotografija = Array<Array<UIImage>>()
    var nizFotografijaOdPoTriFotografije = [UIImage]()
    
    var indeksSlike: Int?
    
    
    @IBOutlet weak var korisnikovMeni: UIView!
    @IBOutlet weak var korisnikovoIme: UILabel!
    @IBOutlet weak var korisnikovaSlika: UIImageView!
    @IBOutlet weak var tabela: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        korisnikovMeni.addSubview(korisnikovoIme)
        korisnikovMeni.addSubview(korisnikovaSlika)
        prikazivanjeKorisnikovihPodataka()
        
    }
    
    func prikazivanjeKorisnikovihPodataka(){ //vađenje podataka iz FIREBASE-a
        let korisnikovID = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("korisnici").child(korisnikovID!).observeSingleEvent(of: FIRDataEventType.value, with: { (podatak) in
            if let rečnik = podatak.value as? [String:AnyObject]{
                self.korisnikovoIme.text = rečnik["korisničkoIme"] as? String //ovde je podešen label u žutom polju
                if let slikaIzBaze = rečnik["profilnaSlika"] as? String{ // ovo je sve za podešavanje slike u žutom polju, ali klasičan prikaz slike skinute sa interneta je kod do kraja ove funkcije
                    if let urlSlike = URL(string: slikaIzBaze){
                        if let slikaData = try? Data(contentsOf: urlSlike){
                            let slikaProfila = UIImage(data: slikaData)
                            self.korisnikovaSlika.image = slikaProfila
                            self.korisnikovaSlika.contentMode = UIViewContentMode.scaleAspectFill
                            self.korisnikovaSlika.layer.cornerRadius = 19
                            self.korisnikovaSlika.layer.masksToBounds = true
                        }
                    }
                }
                if rečnik["dodateSlike"] != nil{
                self.rečnikDodatihSlika = (rečnik["dodateSlike"] as? NSDictionary!)! as! [AnyHashable : Any]
                self.nizJedinstvenihNazivaSlika = self.rečnikDodatihSlika.allKeys as! [String]
                for i in self.nizJedinstvenihNazivaSlika{
                    self.nizSlika.append(String(self.rečnikDodatihSlika[i]!["slika"]!))
                    self.nizVremenaDodavnjaSlika.append(String(self.rečnikDodatihSlika[i]!["vreme"]!))
                }
                for j in 0...self.nizSlika.count - 1{
                    self.nizBezOptionala.append(self.nizSlika[j].components(separatedBy: "Optional(")[1])
                }
                for k in self.nizBezOptionala{
                    self.nizSlika2.append(k.components(separatedBy: ")")[0])
                }
                for j in 0...self.nizVremenaDodavnjaSlika.count - 1{
                    self.nizBezOptionala2.append(self.nizVremenaDodavnjaSlika[j].components(separatedBy: "Optional(")[1])
                }
                for k in self.nizBezOptionala2{
                    self.nizVremenaDodavnjaSlika2.append(k.components(separatedBy: ")")[0])
                }
                for adresa in self.nizSlika2{
                    if let urlSlike = URL(string: adresa){
                        if let podatakSlike = try? Data(contentsOf: urlSlike){
                            self.foto = UIImage(data: podatakSlike)
                            self.nizFotografija.append(self.foto!)
                            //self.tabela.reloadData()
                        }
                    }
                }
                var brojač = 0
                
                for i in self.nizFotografija{
                    if brojač < 3{
                        var član = self.nizFotografija.removeFirst()
                        self.nizFotografijaOdPoTriFotografije.append(član)
                        brojač = brojač + 1
                    }
                    if brojač == 3{
                        self.matricaFotografija.append(self.nizFotografijaOdPoTriFotografije)
                        self.nizFotografijaOdPoTriFotografije = []
                        brojač = 0
                    }
                    
                }
                if self.nizFotografijaOdPoTriFotografije != []{
                    self.matricaFotografija.append(self.nizFotografijaOdPoTriFotografije)
                    self.tabela.reloadData()
                }
                }//kraj if rečnik["dodateSlike"] == nil
               self.tabela.reloadData()
            }
        }, withCancel: nil)
    }
    
    @IBAction func dugmeOdjava(_ sender: AnyObject) {
        try! FIRAuth.auth()?.signOut()
    }
    
    @IBAction func slikanje(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            let fotoZapis = UIImagePickerController()
            fotoZapis.delegate = self
            fotoZapis.sourceType = UIImagePickerControllerSourceType.camera
            fotoZapis.mediaTypes = [kUTTypeImage as String]
            fotoZapis.allowsEditing = false
            self.present(fotoZapis, animated: true, completion: nil)
            noviZapis = true
        }
    }
    
    @IBAction func ulazUGaleriju(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            let fotoZapis = UIImagePickerController()
            fotoZapis.delegate = self
            fotoZapis.sourceType = UIImagePickerControllerSourceType.photoLibrary
            fotoZapis.mediaTypes = [kUTTypeImage as String]
            fotoZapis.allowsEditing = false
            self.present(fotoZapis, animated: true, completion: nil)
            noviZapis = false
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let vrstaMedie = info[UIImagePickerControllerMediaType] as! NSString
        self.dismiss(animated: true, completion: nil)
        if vrstaMedie.isEqual(to: kUTTypeImage as String){
            slika = info[UIImagePickerControllerOriginalImage] as? UIImage
            //nizSlika.append(slika!) ovde sam pomoću nizaSlika testirao da li na ovom mestu mogu da dodam kod za FireBase. Pošto se niz punio samo u ovoj funkciji od svih f-ja imagePickera dodao sam kod za FireBase.
            let jedinstveniNazivFotografija = String(describing: Date())//NSUUID().UUIDString
            let korisnikovID = FIRAuth.auth()?.currentUser?.uid
            let unosUStorage = FIRStorage.storage().reference().child("korisničkeSlike").child(korisnikovID!).child("\(jedinstveniNazivFotografija).png")
            if let uploadSlika = UIImagePNGRepresentation(slika!){/////////////////ovde stavi kompresiju slike
                unosUStorage.put(uploadSlika, metadata: nil, completion: { (nekiPodatak, nekaGreška) in
                    if nekaGreška != nil {
                        let alert = UIAlertController(title: "Pažnja!", message: nekaGreška?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        let otkazivanjeAlerta = UIAlertAction(title: "U redu!", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(otkazivanjeAlerta)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        if let urlUploadovaneSlike = nekiPodatak?.downloadURL()?.absoluteString{
                            let vrednosti: [String:AnyObject] = ["slika": urlUploadovaneSlike as AnyObject, "vreme": String(Date())]
                            let refUnos = FIRDatabase.database().reference(fromURL: "https://moj-instagram.firebaseio.com/")
                            let korisnikovUnos = refUnos.child("korisnici").child(korisnikovID!).child("dodateSlike").child(jedinstveniNazivFotografija)
                            korisnikovUnos.updateChildValues(vrednosti) { (nekaGreška, nekaReferenca) in
                                if nekaGreška != nil {
                                    let upozorenje = UIAlertController(title: "Važno!!!", message: nekaGreška?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                    let isključiUpozorenje = UIAlertAction(title: "U redu!", style: UIAlertActionStyle.cancel, handler: nil)
                                    upozorenje.addAction(isključiUpozorenje)
                                    self.present(upozorenje, animated: true, completion: nil)
                                }
                                else{
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                })
            }//ovde sam završio sa kodom FireBase
            if noviZapis == true{
                UIImageWriteToSavedPhotosAlbum(slika!, self, Selector("image:didFinishSavingWitherror:contextInfo"), nil)
            }
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWitherror error: NSErrorPointer?, contextInfo: UnsafeRawPointer){
        if error != nil {
            let alert = UIAlertController(title: "Pažnja!", message: "Čuvanje slike nije uspelo!", preferredStyle: UIAlertControllerStyle.alert)
            let otkazivanjeAlerta = UIAlertAction(title: "U redu!", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(otkazivanjeAlerta)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func provera(_ sender: AnyObject) {
        print(nizJedinstvenihNazivaSlika)
        print(matricaFotografija)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if matricaFotografija.count == 0{
            return 0
        }
        else {
            return matricaFotografija.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celija", for: indexPath) as! C_elijana
        
        
        if matricaFotografija[indexPath.row].indices.contains(0) == true && matricaFotografija[indexPath.row].indices.contains(1) == false && matricaFotografija[indexPath.row].indices.contains(2) == false{
            cell.prvaSlika.image = matricaFotografija[indexPath.row][0]
            cell.prvaSlika.contentMode = UIViewContentMode.scaleToFill
            cell.drugaSlika.image = UIImage(named: "moj-instagram.png")
            cell.trecaSlika.image = UIImage(named: "moj-instagram.png")
        }
        if matricaFotografija[indexPath.row].indices.contains(0) == true && matricaFotografija[indexPath.row].indices.contains(1) == true && matricaFotografija[indexPath.row].indices.contains(2) == false {
            cell.prvaSlika.image = matricaFotografija[indexPath.row][0]
            cell.prvaSlika.contentMode = UIViewContentMode.scaleToFill
            cell.drugaSlika.image = matricaFotografija[indexPath.row][1]
            cell.drugaSlika.contentMode = UIViewContentMode.scaleToFill
            cell.trecaSlika.image = UIImage(named: "moj-instagram.png")
        }
        if matricaFotografija[indexPath.row].indices.contains(0) == true && matricaFotografija[indexPath.row].indices.contains(1) == true && matricaFotografija[indexPath.row].indices.contains(2) == true {
            cell.prvaSlika.image = matricaFotografija[indexPath.row][0]
            cell.prvaSlika.contentMode = UIViewContentMode.scaleToFill
            cell.drugaSlika.image = matricaFotografija[indexPath.row][1]
            cell.drugaSlika.contentMode = UIViewContentMode.scaleToFill
            cell.trecaSlika.image = matricaFotografija[indexPath.row][2]
            cell.trecaSlika.contentMode = UIViewContentMode.scaleToFill
        }
        
        let dugiStisak = UILongPressGestureRecognizer(target: self, action: #selector(UlogovanKorisnik.dugo(_:)))
        cell.addGestureRecognizer(dugiStisak)
        
        return cell
    }
    
    func dugo(_ gesture: UILongPressGestureRecognizer){
        gesture.minimumPressDuration = 2
        if gesture.state == UIGestureRecognizerState.began{
            let tačka: CGPoint = gesture.location(in: tabela)
            let mojIndeks = tabela.indexPathForRow(at: tačka)!
            let mojaTačka = String(describing: mojIndeks)
            var niz1 = mojaTačka.components(separatedBy: "{length = 2, path = 0 - ")
            var niz2 = niz1[1].components(separatedBy: "}")
            let indeks = Int(niz2[0])
            let xKoordinataStisnutogMesta = tačka.x
            var pozicijaSlike: Int?
            if xKoordinataStisnutogMesta < view.bounds.width / 3 {
                pozicijaSlike = 0
            }
            else if xKoordinataStisnutogMesta >= view.bounds.width / 3 && xKoordinataStisnutogMesta < 2 * view.bounds.width / 3 {
                pozicijaSlike = 1
            }
            else if xKoordinataStisnutogMesta >= 2 * view.bounds.width / 3 {
                pozicijaSlike = 2
            }
            indeksSlike = 3 * indeks! + pozicijaSlike!
            print(indeksSlike)
            let korisnikovID = FIRAuth.auth()?.currentUser?.uid
            let nazivSlike: String = nizJedinstvenihNazivaSlika[indeksSlike!]
            FIRDatabase.database().reference().child("korisnici").child(korisnikovID!).child("dodateSlike").child(nazivSlike).removeValue(completionBlock: { (greska, referenca) in
                if greska != nil {
                    print(greska?.localizedDescription)
                }
                self.nizJedinstvenihNazivaSlika.remove(at: self.indeksSlike!)
                self.matricaFotografija[indeks!].remove(at: pozicijaSlike!)
                self.tabela.reloadData()
            })
    
        }
    }
 
}
