//
//  HeatmapViewController.swift
//  crumbs
//
//  Created by Kevin Li on 11/14/22.
//

import Foundation
import MapboxMaps
import FirebaseFirestore

public class HeatmapViewController: UIViewController {
    
    private let deviceLocation: DeviceLocationService = DeviceLocationService.shared
    internal var mapView: MapView!
    internal var lastTrimOffset = 0.0
    
    public override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1Ijoia2V2aW5hbGk2NCIsImEiOiJja3Y2MzBmY245NnV3MzJuemdnYXh5Z3M5In0.ZPVXUs25CfcIkGWEdLSleg")
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions, styleURI: .dark)
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            
            let db = Firestore.firestore()
            db.collection("posts").getDocuments() { (querySnapshot, error) in
                guard error == nil else {
                    print("error fetching posts")
                    return
                }
                let posts: [Post] = querySnapshot!.documents.map { Post(snapshot: $0) }
                self.showHeatmap(posts: posts)
                let coord = self.deviceLocation.getLocation()
                let lat = coord?.coordinate.latitude
                let lon = coord?.coordinate.longitude
                
                // Set the center coordinate and zoom level.
                let centerCoordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
                let camera = CameraOptions(center: centerCoordinate, zoom: 15.0)
                self.mapView.mapboxMap.setCamera(to: camera)
            }
        }
    }
    
    internal func showHeatmap(posts: [Post]) {
        
        let geojson: [String: Any] = [
            "type": "FeatureCollection",
            "features": posts.map {[
                "type": "Feature",
                "geometry": [
                    "type": "Point",
                    "coordinates": [
                        $0.longitude,
                        $0.latitude
                    ]
                ]
            ]}
        ]
        let data = try! JSONSerialization.data(withJSONObject: geojson, options: .prettyPrinted)
        let featureCollection = try! JSONDecoder().decode(FeatureCollection.self, from: data)
        let geoJSONDataSourceIdentifier = "posts-source"
        
        // Create a GeoJSON data source.
        var geoJSONSource = GeoJSONSource()
        geoJSONSource.data = .featureCollection(featureCollection)
        
        // Create a line layer
        var heatmapLayer = HeatmapLayer(id: "posts-heatmap-layer")
        
        // Setting the source
        heatmapLayer.source = geoJSONDataSourceIdentifier
        
        // Styling the line
        heatmapLayer.heatmapColor = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.heatmapDensity)
                0
                UIColor.clear
                0.2
                UIColor.systemBlue
                0.4
                UIColor.green
                0.6
                UIColor.yellow
                0.8
                UIColor.orange
                1.0
                UIColor.red
        })
        
        // Add the source and style layer to the map style.
        try! mapView.mapboxMap.style.addSource(geoJSONSource, id: geoJSONDataSourceIdentifier)
        try! mapView.mapboxMap.style.addLayer(heatmapLayer, layerPosition: nil)
    }
}
