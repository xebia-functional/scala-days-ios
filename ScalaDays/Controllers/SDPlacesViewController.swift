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
import SVProgressHUD

class SDPlacesViewController: UIViewController, MKMapViewDelegate, SDErrorPlaceholderViewDelegate, SDMenuControllerItem {

    @IBOutlet weak var mapPlaces: MKMapView!
    var selectedConference : Conference?
    let kMapDefaultDistanceInMeters : CLLocationDistance = 10000
    let kMapReuseIdentifier = "SDPlacesViewControllerMapAnnotation"
    let kDefaultTagForAnnotations = 666
    var didShowFirstVenue = false
    
    var errorPlaceholderView : SDErrorPlaceholderView!
    var isDataLoaded = false
    private let analytics: Analytics
    
    init(analytics: Analytics) {
        self.analytics = analytics
        super.init(nibName: String(describing: SDPlacesViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNavigationBarItem()
        self.title = NSLocalizedString("places", comment: "Places")
        
        errorPlaceholderView = SDErrorPlaceholderView(frame: screenBounds)
        errorPlaceholderView.delegate = self
        self.view.addSubview(errorPlaceholderView)
        
        mapPlaces.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isDataLoaded { loadData() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.logScreenName(.places, class: SDPlacesViewController.self)
    }
    
    // MARK: - Data loading
    
    func loadData() {
        SVProgressHUD.show()
        DataManager.sharedInstance.loadDataJson() {
            (bool, error) -> () in
            
            if let badError = error {
                self.errorPlaceholderView.show(NSLocalizedString("error_message_no_data_available", comment: ""))
                SVProgressHUD.dismiss()
            } else {
                self.selectedConference = DataManager.sharedInstance.currentlySelectedConference
                self.isDataLoaded = true
                
                SVProgressHUD.dismiss()
            
                if let conference = self.selectedConference {
                    if conference.venues.count == 0 {
                        self.errorPlaceholderView.show(NSLocalizedString("error_insufficient_content", comment: ""), isGeneralMessage: true)
                    } else {
                        self.errorPlaceholderView.hide()
                        self.drawMapPushPinsForVenues(conference.venues)
                    }                    
                } else {
                    self.errorPlaceholderView.show(NSLocalizedString("error_message_no_data_available", comment: ""))
                }
            }
        }
    }
    
    // MARK: - Map handling
    
    func drawMapPushPinsForVenues(_ venues: Array<Venue>) {
        let geocoder = CLGeocoder()
        
        self.mapPlaces.removeAnnotations(self.mapPlaces.annotations)
        for venue in venues {
            let coordinate = CLLocationCoordinate2D(latitude: venue.latitude!, longitude: venue.longitude!)
            let annotation = SDMapAnnotation(title: venue.name, subtitle: venue.address, coordinate: coordinate)
            self.mapPlaces.addAnnotation(annotation)
        }
        mapPlaces.zoomToFitMapAnnotations()
    }
    
    // MARK: - MKMapViewDelegate protocol implementation
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView! {
        if annotation is MKUserLocation {
            return nil
        } else {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: kMapReuseIdentifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: kMapReuseIdentifier)
            }
            annotationView!.canShowCallout = true
            annotationView!.image = UIImage(named: "map_pushpin")
            annotationView!.annotation = annotation
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SDPlacesViewController.didTapCallout(_:))))
    }
    
    @objc func didTapCallout(_ sender: UITapGestureRecognizer) {
        let annotationView = sender.view as! MKAnnotationView
        if annotationView.isSelected {
            let annotation = annotationView.annotation as! SDMapAnnotation
            
            // It seems there's a bug in Swift that provokes EXC_BAD_ACCESS exceptions while trying to access properties of the annotation,
            // it matches this situation: http://stackoverflow.com/questions/25194944/why-accessing-a-class-instance-member-gives-an-exc-bad-access-xcode-beta-5
            // So while this is fixed in a future XCode version, we have to access the venue's location and address from the conference object in a more cumbersome way:
            if let annotations = self.mapPlaces.annotations as? [SDMapAnnotation] {
                if let indexOfVenue = annotations.firstIndex(of: annotation) {
                    if let conference = selectedConference {
                        if conference.venues.count > indexOfVenue {
                            let venue = conference.venues[indexOfVenue]
                            let urlString = "http://maps.apple.com/?ll=\(venue.latitude),\(venue.longitude)&daddr=\(venue.address.removeWhitespace().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))"
                            if let mapUrl = URL(string: urlString) {
                                analytics.logEvent(screenName: .places, category: .navigate, action: .goToMap, label: venue.name)
                                launchSafariToUrl(mapUrl)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: SDErrorPlaceholderViewDelegate protocol implementation
    
    func didTapRefreshButtonInErrorPlaceholder() {
        loadData()
    }
    
}
