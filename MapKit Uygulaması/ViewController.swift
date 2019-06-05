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
    @IBOutlet weak var lblAdres: UILabel!
    
    @IBOutlet weak var btnGit: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager  = CLLocationManager()
    let bolgeBuyukluk : Double = 12000
    var oncekiKonum : CLLocation?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        konumServisKontrol()
        btnGit.layer.cornerRadius = 20
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
           kullaniciTakip()
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
    func kullaniciTakip() {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        konumOdaklan()
        oncekiKonum = merkezKordinatlariGetir(mapView: mapView)
    }
    func konumOdaklan() {
        
        if let konum = locationManager.location?.coordinate {
            let bolge = MKCoordinateRegion.init(center: konum, latitudinalMeters: bolgeBuyukluk, longitudinalMeters: bolgeBuyukluk)
            mapView.setRegion(bolge, animated: true)
        }
    }
    func merkezKordinatlariGetir(mapView : MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    @IBAction func btnGitTikla(_ sender: Any) {
        rotaBelirle()
    }
    
    func rotaBelirle(){
        
        guard let baslangicKoordinat = locationManager.location?.coordinate else { return }
        
        let istek = istekOlustur(baslangicKoordinat: baslangicKoordinat)
        let rotalar = MKDirections(request: istek)
        
        rotalar.calculate { (cevap, hata) in
            
            guard let cevap = cevap else {return}
            
            for rota in cevap.routes {
                self.mapView.addOverlay(rota.polyline)
                self.mapView.setVisibleMapRect(rota.polyline.boundingMapRect, animated: true)
                
            }
        }
        
    }
    
    func istekOlustur(baslangicKoordinat : CLLocationCoordinate2D) -> MKDirections.Request {
        
        let hedefKoordinat = merkezKordinatlariGetir(mapView: mapView).coordinate
        let baslangicNoktasi = MKPlacemark(coordinate: baslangicKoordinat)
        
        let hedefNoktasi = MKPlacemark(coordinate: hedefKoordinat)
        
        let istek = MKDirections.Request()
        
        istek.source = MKMapItem(placemark: baslangicNoktasi)
        istek.destination = MKMapItem(placemark: hedefNoktasi)
        istek.transportType = .automobile
        istek.requestsAlternateRoutes = true
        
        return istek
    }
    
}

extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Konum güncellenirse tetiklenir
        guard let konum = locations.last else { return}
        let merkez = CLLocationCoordinate2D(latitude: konum.coordinate.latitude, longitude: konum.coordinate.longitude)
        let bolge = MKCoordinateRegion.init(center: merkez, latitudinalMeters: bolgeBuyukluk, longitudinalMeters: bolgeBuyukluk)
        mapView.setRegion(bolge, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //Konuma verilen izin değiştirilirse
        izinKontrol()
        
    }
    
}
extension ViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let merkez = merkezKordinatlariGetir(mapView: mapView)
        
        guard let oncekiKonum = self.oncekiKonum else { return }
        if merkez.distance(from: oncekiKonum) < 50 {return}
        self.oncekiKonum = merkez
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(merkez) { (yerIsaretleri, hata) in
            if let _ = hata {
                print("Hata Meydana Geldi")
                return
            }
            guard let isaret = yerIsaretleri?.first else {
                return
            }
            
            let sokakNumarasi = isaret.subThoroughfare ?? "Yok"
            let sokakAdi = isaret.thoroughfare ?? "Yok"
            let ulkeAdi = isaret.country ?? "Yok"
            let ilAdi = isaret.administrativeArea ?? "Yok"
            let ilceAdi = isaret.locality ?? "Yok"
            
            
            DispatchQueue.main.async {
                self.lblAdres.text = "\(ilceAdi) / \(ilAdi) / \(ulkeAdi)"
                print("Sokak Numarası : \(sokakNumarasi)")
                print("Sokak Adı : \(sokakAdi)")
            }
            
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 8
        renderer.lineCap = .square
        return renderer
        
    }
}
