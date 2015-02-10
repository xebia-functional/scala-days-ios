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

import MapKit

extension MKMapView {
    
    // This should be an internal function to zoomToFitMapAnnotations, but Swift compiler won't allow a local function to reference itself for some reason...    
    func findCornerCoordinatesInListOfAnnotations(listOfAnnotations: [MKAnnotation], cornerCoordinates: (topLeftCoord: CLLocationCoordinate2D, bottomRightCoord: CLLocationCoordinate2D)) -> (topLeftCoord: CLLocationCoordinate2D, bottomRightCoord: CLLocationCoordinate2D) {
        if let currentAnnotation = listOfAnnotations.first {
            let restOfAnnotations : [MKAnnotation] = Array(dropFirst(listOfAnnotations))
            
            let topLeftCoordLongitude = fmin(cornerCoordinates.topLeftCoord.longitude, currentAnnotation.coordinate.longitude)
            let topLeftCoordLatitude = fmax(cornerCoordinates.topLeftCoord.latitude, currentAnnotation.coordinate.latitude)
            let bottomRightCoordLongitude = fmax(cornerCoordinates.bottomRightCoord.longitude, currentAnnotation.coordinate.longitude)
            let bottomRightCoordLatitude = fmin(cornerCoordinates.bottomRightCoord.latitude, currentAnnotation.coordinate.latitude)
            
            return findCornerCoordinatesInListOfAnnotations(restOfAnnotations, cornerCoordinates: (CLLocationCoordinate2D(latitude: topLeftCoordLatitude, longitude: topLeftCoordLongitude), CLLocationCoordinate2D(latitude: bottomRightCoordLatitude, longitude: bottomRightCoordLongitude)))
        }
        return (cornerCoordinates.topLeftCoord, cornerCoordinates.bottomRightCoord)
    }
    
    func zoomToFitMapAnnotations() {
        
        if self.annotations.count == 0 {
            return
        }
        
        let kZoomOutRatio = 50.0
        let startingTopLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        let startingBottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        let cornerCoordinates = findCornerCoordinatesInListOfAnnotations(self.annotations as [MKAnnotation], cornerCoordinates: (startingTopLeftCoord, startingBottomRightCoord))
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: cornerCoordinates.topLeftCoord.latitude - (cornerCoordinates.topLeftCoord.latitude - cornerCoordinates.bottomRightCoord.latitude) * 0.5,
                                        longitude: cornerCoordinates.topLeftCoord.longitude + (cornerCoordinates.bottomRightCoord.longitude - cornerCoordinates.topLeftCoord.longitude) * 0.5),
                                        span: MKCoordinateSpan(latitudeDelta: fabs(cornerCoordinates.topLeftCoord.latitude - cornerCoordinates.bottomRightCoord.latitude) * kZoomOutRatio, longitudeDelta: fabs(cornerCoordinates.topLeftCoord.latitude - cornerCoordinates.bottomRightCoord.latitude) * kZoomOutRatio))
        self.setRegion(region, animated: true)
    }
    
}