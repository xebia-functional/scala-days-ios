/*
* Copyright (C) 2015 47 Degrees, LLC http://47deg.com hello@47deg.com
*
* Licensed under the Apache License, Version 2.0 (the "License"); you may
* not use this file except in compliance with the License. You may obtain
* a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit
import MapKit

class SDPlacesViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapPlaces: MKMapView!
    lazy var selectedConference : Conference? = DataManager.sharedInstance.currentlySelectedConference
    let kMapDefaultDistanceInMeters : CLLocationDistance = 10000
    let kMapReuseIdentifier = "SDPlacesViewControllerMapAnnotation"
    var didShowFirstVenue = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setNavigationBarItem()
        self.title = NSLocalizedString("places", comment: "Places")
        mapPlaces.delegate = self
        if let conference = selectedConference {
            drawMapPushPinsForVenues(conference.venues)
        }
    }
    
    // MARK: - Map handling
    
    func drawMapPushPinsForVenues(venues: Array<Venue>) {
        let geocoder = CLGeocoder()
        
        var currentRegion = mapPlaces.region
        
        for venue in venues {
            let coordinate = CLLocationCoordinate2D(latitude: (venue.latitude as NSString).doubleValue, longitude: (venue.longitude as NSString).doubleValue)
            let annotation = SDMapAnnotation(title: venue.name, subtitle: venue.address, coordinate: coordinate)
            self.mapPlaces.addAnnotation(annotation)
        }
        mapPlaces.zoomToFitMapAnnotations()
    }
    
    // MARK: - MKMapViewDelegate protocol implementation
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKUserLocation {
            return nil
        } else {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(kMapReuseIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: kMapReuseIdentifier)
            }
            annotationView!.canShowCallout = true
            annotationView.image = UIImage(named: "map_pushpin")
            annotationView.annotation = annotation
            return annotationView
        }
    }
}
