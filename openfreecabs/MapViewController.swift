

import UIKit
import CoreLocation
import GoogleMaps
import Kingfisher

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var myMarkerOnMap: UIImageView!
    @IBOutlet weak var findMeButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2DMake(0, 0)
    
    var driversMarker: [GMSMarker] = []
    var companiesModel: [CompaniesModel] = []
    var driversModel: [DriversModel] = []
    var isAutorized = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        mapView.delegate = self
        mapView.settings.rotateGestures = false
        mapView.settings.tiltGestures = false
        mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
        mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2DMake(42.876041, 74.603458), zoom: 10, bearing: 0, viewingAngle: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Bishkek Taxi"
    }
    
    func checkLocationManagerAuthorization() {
        print("checkLocationManagerAuthorization")
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            isAutorized = true
        case .notDetermined:
            isAutorized = false
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            break
        case .restricted:
            break
        case .denied:
            break
        default:
            break
        }
        
        if (locationManager.location == nil) {
            mapView.animate(to: GMSCameraPosition(target: CLLocationCoordinate2DMake(42.876041, 74.603458), zoom: 15, bearing: 0, viewingAngle: 0))
        } else {
            mapView.animate(to: GMSCameraPosition(target: locationManager.location!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0))
        }
        if (isAutorized) {
            myMarkerOnMap.isHidden = false
        } else {
            myMarkerOnMap.isHidden = true
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus")
        checkLocationManagerAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        
        userLocation = locationObj.coordinate
        locationManager.stopUpdatingLocation()
        
        mapView.animate(to: GMSCameraPosition(target: userLocation, zoom: 15, bearing: 0, viewingAngle: 0))
        getTaxiList(locationManager.location!.coordinate.latitude, lng: locationManager.location!.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError")
        locationManager.stopUpdatingLocation()
    }
    
    //Markers on map
    func showMarkerOnMap(_ coord: CLLocationCoordinate2D, markerImage: UIImage, animated: Bool) -> GMSMarker {
        
        let marker : GMSMarker = GMSMarker(position: coord)
        if (animated) {
            marker.appearAnimation = GMSMarkerAnimation.pop
        }
        marker.icon = markerImage
        marker.map = mapView
        return marker
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if (isAutorized) {
            getTaxiList(position.target.latitude, lng: position.target.longitude)
        }
    }
    
    func getTaxiList(_ lat: Double, lng: Double) {
        OpenFreeCabsApiClient.sharedInstance.getTaxiList("\(lat)", lng: "\(lng)") { (response) in
            print("getTaxiList \(String(describing: response.response))")
            if (response.result.isSuccess) {
                if (response.result.value!.success) {
                    self.companiesModel = response.result.value!.companies
                    self.companiesModel.sort { (l, r) -> Bool in
                        return l.drivers.count > r.drivers.count
                    }
                    
                    for i in 0 ..< self.driversMarker.count {
                        self.driversMarker[i].map = nil
                    }
                    self.driversMarker = []
                    
                    for j in 0..<response.result.value!.companies.count {
                        self.driversModel = response.result.value!.companies[j].drivers
                        
                        let fullUrl = URL(string: "\(String(describing: response.result.value!.companies[j].iconURL))") as URL?
                        KingfisherManager.shared.retrieveImage(with: fullUrl!, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
                            for i in 0 ..< self.driversModel.count {
                                
                                let coord = CLLocationCoordinate2D(latitude: self.driversModel[i].lat, longitude: self.driversModel[i].lng)
                                
                                if image != nil {
                                    self.driversMarker.append(self.showMarkerOnMap(coord, markerImage: image!, animated: true))
                                } else {
                                    let placeHolderImage = UIImage(named: "driverMarker")
                                    self.driversMarker.append(self.showMarkerOnMap(coord, markerImage: placeHolderImage!, animated: true))
                                }
                                
                                if (self.driversModel[i].lat != 0 && self.driversModel[i].lng != 0) {
                                    self.driversMarker[i].map = self.mapView
                                } else {
                                    self.driversMarker[i].map = nil
                                }
                            }
                        })
                    }
                } else {
                }
            } else {
            }
        }
    }
    
    @IBAction func CallCab(_ sender: UIBarButtonItem) {
        let phoneURLOne = NSURL(string: "tel:+996559976000")!
        let phoneURLTwo = NSURL(string: "tel:+996551061236")!
        
        let alert = UIAlertController(title: "Call", message: nil, preferredStyle: .actionSheet)
        let actionOne = UIAlertAction(title: "Namba Taxi", style: .default) { (action) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(phoneURLOne as URL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
        let actionTwo = UIAlertAction(title: "SMS Taxi", style: .default) { (action) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(phoneURLTwo as URL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
        alert.addAction(actionOne)
        alert.addAction(actionTwo)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func findMeAction(_ sender: UIBarButtonItem) {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse) {
            if (CLLocationManager.locationServicesEnabled() && locationManager.location != nil) {
                mapView.animate(to: GMSCameraPosition(target: locationManager.location!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0))
            } else {
            }
        } else {
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

