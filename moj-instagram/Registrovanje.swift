//
//  Registrovanje.swift
//  moj-instagram
//
//  Created by Vuk on 7/25/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices

class Registrovanje: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var kutija2: UIView!
    @IBOutlet weak var poljeIme: UITextField!
    @IBOutlet weak var poljeEmail: UITextField!
    @IBOutlet weak var poljeŠifra: UITextField!
    @IBOutlet weak var poljeSlike: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setovanjeSwipea()
        setovanjeKutije2()
        setovanjeTapa()
        self.poljeIme.text = ""
        self.poljeEmail.text = ""
        self.poljeŠifra.text = ""
    }
    
    func setovanjeTapa(){
        let tapNaSliku = UITapGestureRecognizer(target: self, action: #selector(Registrovanje.tapPoSlici(_:)))
        poljeSlike.addGestureRecognizer(tapNaSliku)
        poljeSlike.isUserInteractionEnabled = true
        poljeSlike.contentMode = UIViewContentMode.scaleAspectFit
    }
    
    func tapPoSlici(_ gesture: UITapGestureRecognizer){
        poljeSlike.isUserInteractionEnabled = true
        //gesture.numberOfTapsRequired = 1
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            let fotoZapis = UIImagePickerController()
            fotoZapis.delegate = self
            fotoZapis.sourceType = UIImagePickerControllerSourceType.photoLibrary
            fotoZapis.mediaTypes = [kUTTypeImage as String]
            fotoZapis.allowsEditing = false
            self.present(fotoZapis, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let vrstaMedie = info[UIImagePickerControllerMediaType] as! NSString
        self.dismiss(animated: true, completion: nil)
        if vrstaMedie.isEqual(to: kUTTypeImage as String){
            let slika = info[UIImagePickerControllerOriginalImage] as! UIImage
            poljeSlike.image = slika
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setovanjeSwipea() {
        let desniSwipe = UISwipeGestureRecognizer(target: self, action: #selector(Registrovanje.swipeUDesno(_:)))
        desniSwipe.direction = .right
        view.addGestureRecognizer(desniSwipe)
    }
    
    func swipeUDesno(_ gesture: UISwipeGestureRecognizer){
        let prelazakNaLogovanje = storyboard?.instantiateViewController(withIdentifier: "LogovanjeStoryboard")
        present(prelazakNaLogovanje!, animated: false, completion: nil)
    }
    
    func setovanjeKutije2() {
        kutija2.layer.cornerRadius = 6
        kutija2.layer.masksToBounds = true
    }
    
    @IBAction func dugmeRegistrujSe(_ sender: AnyObject) {
        if poljeIme.text == "" || poljeEmail.text == "" || poljeŠifra.text == "" {
            let upozorenje = UIAlertController(title: "Važno!!!", message: "Sva polja moraju biti popunjena!", preferredStyle: UIAlertControllerStyle.alert)
            let isključiUpozorenje = UIAlertAction(title: "U redu!", style: UIAlertActionStyle.cancel, handler: nil)
            upozorenje.addAction(isključiUpozorenje)
            present(upozorenje, animated: true, completion: nil)
        }//ovde je gotov deo kojim se ne dozoljava da se polja ostave prazna
        else{
            FIRAuth.auth()?.createUser(withEmail: poljeEmail.text!, password: poljeŠifra.text!, completion: { (nekiKorisnik, nekaGreška) in
                if nekaGreška != nil{
                    let upozorenje = UIAlertController(title: "Važno!!!", message: nekaGreška?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let isključiUpozorenje = UIAlertAction(title: "U redu!", style: UIAlertActionStyle.cancel, handler: nil)
                    upozorenje.addAction(isključiUpozorenje)
                    self.present(upozorenje, animated: true, completion: nil)
                }//ovde je gotov deo koji će dizati ALERT ukoliko nešto nije u redu sa registrovanjem
                else{
                    //UPLOAD podataka u bazu
                    let korisnikovID = nekiKorisnik?.uid
                    let jedinstvenoImeSlike = UUID().uuidString //ovako se formira jedinstveno ime u opštem slučaju, sad ću ga iskoristiti za sliku
                    let mestoZaČuvanjeNaFirebaseu = FIRStorage.storage().reference().child("profilneSlike").child("\(jedinstvenoImeSlike).png")
                    if let uploadovanaSlika = UIImagePNGRepresentation(self.poljeSlike.image!){
                        mestoZaČuvanjeNaFirebaseu.put(uploadovanaSlika, metadata: nil, completion: { (nekiPodatak, nekaGreška2) in
                            if nekaGreška2 != nil{
                                let upozorenje2 = UIAlertController(title: "Važno!!!", message: nekaGreška2?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                let isključiUpozorenje2 = UIAlertAction(title: "U redu!", style: UIAlertActionStyle.cancel, handler: nil)
                                upozorenje2.addAction(isključiUpozorenje2)
                                self.present(upozorenje2, animated: true, completion: nil)
                            }//ovde je gotov deo koji će dizati ALERT ukoliko nešto nije u redu sa registrovanjem    
                            else{
                                if let profilnaSlikaURL = nekiPodatak?.downloadURL()?.absoluteString{
                                    let vrednosti: [String:AnyObject] = ["korisničkoIme":self.poljeIme.text! as AnyObject, "email":self.poljeEmail.text! as AnyObject, "profilnaSlika":profilnaSlikaURL as AnyObject]//ovde je važno naglasiti da je rečnik VREDNOSTI tipa String:AnyObject zbog donje f-je registrujKorisnikaUBazuSaUID koja u sebi ima completionHandler koji je rečnik tipa NSObject:AnyObject i on je kompatibilan sa tipom String:AnyObject
                                    self.registrujKorisnikaUBazuSaUID(korisnikovID!,rečnik: vrednosti)
                                }
                            }
                        })
                    }
                    let prelazakNaLogovanje = self.storyboard?.instantiateViewController(withIdentifier: "LogovanjeStoryboard")
                    self.present(prelazakNaLogovanje!, animated: false, completion: nil)
                }
            })
        }
    }
    
    fileprivate func registrujKorisnikaUBazuSaUID(_ korisnik: String, rečnik:[String:AnyObject]){
        let refUnos = FIRDatabase.database().reference(fromURL: "https://moj-instagram.firebaseio.com/")
        let korisnikovUnos = refUnos.child("korisnici").child(korisnik)
        korisnikovUnos.updateChildValues(rečnik) { (nekaGreška, nekaReferenca) in
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
