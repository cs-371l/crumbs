//
//  HeatmapViewController.swift
//  crumbs
//
//  Created by Kevin Li on 11/14/22.
//

import UIKit
import MapboxMaps

class HeatmapViewController: UIViewController {

    internal var mapView: MapView!
     
    override public func viewDidLoad() {
        super.viewDidLoad()
         
        // Create a map view.
        let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1Ijoia2V2aW5hbGk2NCIsImEiOiJja3Y2MzBmY245NnV3MzJuemdnYXh5Z3M5In0.ZPVXUs25CfcIkGWEdLSleg")
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions)
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)

        // Center the map camera over Stockholm.
        mapView.mapboxMap.setCamera(
            to: CameraOptions(
            center: CLLocationCoordinate2D(
            latitude: 59.31,
            longitude: 18.06
            ),
            zoom: 9.0
            )
        )
         
        // Add the map.
        self.view.addSubview(mapView)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
