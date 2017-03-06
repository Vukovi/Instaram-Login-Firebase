//
//  Logovanje.swift
//  moj-instagram
//
//  Created by Vuk on 7/25/16.
//  Copyright © 2016 User. All rights reserved.
//

import UIKit
import Firebase

class Logovanje: UIViewController {

    @IBOutlet weak var kutija: UIView!
    @IBOutlet weak var unosEmaila: UITextField!
    @IBOutlet weak var unosŠifre: UITextField!
    
    var brojPokušajaLogovanja = 0
    var indikatorAktivnosti = UIActivityIndicatorView()
    

    override func viewDidAppear(_ animated: Bool) {
        if FIRAuth.auth()?.currentUser != nil{
            let prelazakNaUlogovanogKorisnika = storyboard?.instantiateViewController(withIdentifier: "UlogovanKorisnikStoryboard")
            present(prelazakNaUlogovanogKorisnika!, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setovanjeSwipe()
        setovanjeKutije()
        
    }
    
    func setovanjeSwipe() {
        let leviSwipe = UISwipeGestureRecognizer(target: self, action: #selector(Logovanje.swipeULevo(_:)))
        leviSwipe.direction = .left
        view.addGestureRecognizer(leviSwipe)
    }
    
    func swipeULevo(_ gesture: UISwipeGestureRecognizer){
        let prelazakNaRegistrovanje = storyboard?.instantiateViewController(withIdentifier: "RegistrovanjeStoryboard")
        present(prelazakNaRegistrovanje!, animated: false, completion: nil)
    }
    
    func setovanjeKutije() {
        kutija.layer.cornerRadius = 6
        kutija.layer.masksToBounds = true
        kutija.addSubview(unosEmaila)
        kutija.addSubview(unosŠifre)
    }

    @IBAction func ulogujSe(_ sender: AnyObject) {
        let xKoordinata = view.frame.width/2 - 50
        let yKoordinata = view.frame.height/2 + 100
        indikatorAktivnosti = UIActivityIndicatorView(frame: CGRect(x: xKoordinata, y: yKoordinata, width: 100, height: 100))
        indikatorAktivnosti.hidesWhenStopped = true
        indikatorAktivnosti.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(indikatorAktivnosti)
        indikatorAktivnosti.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        if unosEmaila.text == "" || unosŠifre.text == "" {
            let upozorenje = UIAlertController(title: "Važno!!!", message: "Sva polja moraju biti popunjena!", preferredStyle: UIAlertControllerStyle.alert)
            let isključiUpozorenje = UIAlertAction(title: "U redu!", style: UIAlertActionStyle.cancel, handler: nil)
            upozorenje.addAction(isključiUpozorenje)
            present(upozorenje, animated: true, completion: nil)
            indikatorAktivnosti.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }//ovde je gotov deo kojim se ne dozoljava da se polja ostave prazna
        else{
            FIRAuth.auth()?.signIn(withEmail: unosEmaila.text!, password: unosŠifre.text!, completion: { (nekiKorisnik, nekaGreška) in
                if nekaGreška != nil {
                    let upozorenje = UIAlertController(title: "Važno!!!", message: nekaGreška?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let isključiUpozorenje = UIAlertAction(title: "U redu!", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                        print(self.brojPokušajaLogovanja)
                        if self.brojPokušajaLogovanja == 3{
                            let prelazakNaRegistrovanje = self.storyboard?.instantiateViewController(withIdentifier: "RegistrovanjeStoryboard")
                            self.present(prelazakNaRegistrovanje!, animated: true, completion: nil)
                            self.brojPokušajaLogovanja = 0
                            self.indikatorAktivnosti.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                        }
                    })
                    upozorenje.addAction(isključiUpozorenje)
                    self.present(upozorenje, animated: true, completion: nil)
                    self.brojPokušajaLogovanja = self.brojPokušajaLogovanja + 1
                    self.unosEmaila.text = ""
                    self.unosŠifre.text = ""
                    self.indikatorAktivnosti.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }//ako postoji neka greška kod logovanje ne propuštaj dalje, ovaj if else unutar FIRAuth-a
                else{
                    let prelazakNaUlogovanogKorisnika = self.storyboard?.instantiateViewController(withIdentifier: "UlogovanKorisnikStoryboard")
                    self.present(prelazakNaUlogovanogKorisnika!, animated: true, completion: nil)
                    self.unosEmaila.text = ""
                    self.unosŠifre.text = ""
                    self.indikatorAktivnosti.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            })
        }
    }
    

}
