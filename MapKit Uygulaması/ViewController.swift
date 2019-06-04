//
//  ViewController.swift
//  MapKit Uygulaması
//
//  Created by Furkan Sabaz on 4.06.2019.
//  Copyright © 2019 Furkan Sabaz. All rights reserved.
//

import UIKit
import MapKit
class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager  = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    
    func konumServisKontrol() {
        
        if CLLocationManager.locationServicesEnabled() {
            // konum servisi açılmıştır
            ayarlaLocationManager()
            izinKontrol()
        } else {
            
        }
    }

    func ayarlaLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func izinKontrol() {
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedAlways :
            //Kullanıcı daima kullanmamız için izin vermiştir
            break
        case .authorizedWhenInUse :
            //uygulama sadece kullanım esnasında konum bilgisine erişebilir
            break
        case .denied :
            //kullanıcı izin isteğimizi reddetmiştir veya henüz izin vermemiştir
            break
        case .notDetermined :
            //kullanıcı henüz karar vermemiştir
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted :
            //uygulamamızın durumu kısıtlanmıştır.
            break
            
        }
        
    }
}

extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Konum güncellenirse tetiklenir
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //Konuma verilen izin değiştirilirse
    }
    
}
