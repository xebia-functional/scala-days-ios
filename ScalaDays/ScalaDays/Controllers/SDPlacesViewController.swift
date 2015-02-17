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
    let kDefaultTagForAnnotations = 666
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
        
        for venue in venues {
            let coordinate = CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
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
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "map_pushpin")
            annotationView.annotation = annotation
            return annotationView
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "didTapCallout:"))
    }
    
    func didTapCallout(sender: UITapGestureRecognizer) {
        let annotationView = sender.view as MKAnnotationView
        let annotation = annotationView.annotation as SDMapAnnotation
        
        // It seems there's a bug in Swift that provokes EXC_BAD_ACCESS exceptions while trying to interpolate certain strings,
        // (in this case, while trying to access annotation's subtitle and coordinate properties, which aren't optional and 
        // should come with a valid value). So while we find a better solution we have to access the venue's location and address
        // from the conference object in a more cumbersome way:
        if let annotations = self.mapPlaces.annotations as? [SDMapAnnotation] {
            if let indexOfVenue = find(annotations, annotation) {
                if let conference = selectedConference {
                    if conference.venues.count > indexOfVenue {
                        let venue = conference.venues[indexOfVenue]
                        let urlString = "http://maps.apple.com/?ll=\(venue.latitude),\(venue.longitude)&daddr=\(venue.address.removeWhitespace().stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)"
                        if let mapUrl = NSURL(string: urlString) {
                            if UIApplication.sharedApplication().canOpenURL(mapUrl) {
                                UIApplication.sharedApplication().openURL(mapUrl)
                            }
                        }
                    }                    
                }
            }
        }
    }
}
