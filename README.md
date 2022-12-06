# Crumbs Final Release

### Group number: 1
### Team members: Amog Iska, Tristan Blake, Kevin Li, Philo Lin
### Name of project: Crumbs
### Dependencies: Xcode 14.0, Swift 5

## Special Dependencies (name : version)
- abseil : 0.20220203.2
- BoringSSL-GRPC : 0.9.1
- DZNEmptyDataSet : master
- Firebase : 9.6.0
- GoogleAppMeasurement : 9.6.0
- GoogleDataTransport : 9.2.0
- GoogleUtilities : 7.9.0
- gRPC : 1.44.3-grpc
- GTMSessionFetcher : 2.1.0
- leveldb : 1.22.2
- MapboxCommon : 23.2.0-beta.1
- MapboxCoreMaps : 10.10.0-beta-1
- MapboxMaps : main
- nanopb 2.30909.0
- Promises 2.1.1
- SDWebImage 5.14.2
- SwiftProtobuf 1.20.2
- Turf 2.6.0

## Special Instructions
- First, add .netrc file into ~/ (home) directory before opening project in XCode
- Use iPhone 14 Pro Max Simulator
- Please Allow "crumbs" to use your location
- Got to this location to see previously populated posts (longitude: 31.286256, latitude: 95.736628)
- To zoom in on map, use two fingers then drag up, opposite for zoom out.

## To change Location
Features -> Location -> Custom Location...

| Feature     | Description | Release Planned     | Release Actual  | Deviations (if any)     | Who/Percentage worked on     | 
|    :---:  |    :----:   |          :---: |         :---: |         :---: |         :---: |
| Loading Screen      | Camera animation starting screen when loading into the app       | Beta   | Beta   | None  | Philo - 100 |
| Login Page          | Users can login using email and password    | Alpha   | Alpha   | Did not implement Apple account login  | Kevin/Tristan/Philo - 40/40/20 |
| Sign-up Page    | Users can sign-up for an account, has many checks to create a valid account     | Alpha   | Alpha   | None  |  Tristan/Kevin - 70/30 |
| Settings Page    | Change account information, delete account, turn on/off notifications, dark mode    | Alpha   | Beta   | Do not have notifications implemented becuase the notifications that are desired for this app are remote, which requires a paid Apple Developer account  | Tristan/Philo/Amog - 20/20/60 |
| Home Page      | Initial screen when users open the app. Discover feed that shows posts in close proximity of user. Follow feed that shows posts that the user has followed.      | Alpha   | Alpha   | None  | Kevin/Tristan - 50/50 |
| Post View Page     | Shows post details, comments, likes, views  | Alpha   | Alpha  | No threaded comments due to difficulty  | Kevin - 100 |
| User Page      | Shows user's username, karma, number of posts, date account was created , and bio. Links to created posts | Alpha  | Beta/Final   | None  | Kevin/Amog/Tristan - 40/40/20 |
| Create Post Page     | Allows users to title the post, and add picture, and add description     | Alpha   | Alpha   | No polls  | Philo - 100 |
| Location Support     | Posts have a placed at current location    | Beta   | Beta   | None  |  Tristan - 100 |
| UI     | Colors, buttons, logo     | Alpha   | Final   | None  |  Philo - 100 |
| Multimedia Support     | Allows upload of images to posts and displaying of image, Lightbox integration | Stretch   | Final   | None  | Kevin - 100 |
| Heat Map     | Heatmap of areas with high frequency posts. Interactable for more granular locations     | Stretch   | Final   | None  | Kevin/Tristan - 20/80|
| Commenting System     | Page to add comments, display comments, upvote and downvote with persistence    | Beta   | Final   | None  | Kevin/Tristan - 40/60|


