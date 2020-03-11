/*
* Copyright (C) 2015 47 Degrees, LLC http://47deg.com hello@47deg.com
*
* Licensed under the Apache License, Version 2.0 (the "License"); you may
* not use this file except in compliance with the License. You may obtain
* a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/


import MapKit

extension MKMapView {
    
    // TODO: the ideal approach to this would be to use a recursive function to calculate the middle point of
    // our map's annotations in order to avoid mutability. But sadly it seems that while Swift uses tail call
    // optimization *sometimes*, it won't guarantee that in any way.
    //
    // You can find more information about this in this blog post from Natasha The Robot:
    // http://natashatherobot.com/functional-swift-tail-recursion/
    
    func zoomToFitMapAnnotations() {
        guard self.annotations.count != 0 else { return }
        
        let kZoomOutRatio = 50.0
        var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        for annotation in self.annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
        }
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5,
            longitude: topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5),
            span: MKCoordinateSpan(latitudeDelta: fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * kZoomOutRatio, longitudeDelta: fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * kZoomOutRatio))
        
        let regionFits = self.regionThatFits(region)
        guard !regionFits.isInvalid else { return }
        self.setRegion(regionFits, animated: true)
    }
}


// MARK: - Helpers
extension MKCoordinateRegion {
    var isInvalid: Bool { span.isInvalid }
}

extension MKCoordinateSpan {
    var isInvalid: Bool { latitudeDelta.isNaN || longitudeDelta.isNaN }
}
